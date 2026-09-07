/**
 * Bakery Extension
 *
 * Enables control of pi sessions via Unix domain sockets. Every pi session
 * automatically creates a control socket at `<bakery-dir>/<session-id>.sock`
 * that accepts JSON-RPC commands. The socket is driven by the external
 * `bakery` CLI.
 *
 * The bakery dir is $PI_CODING_AGENT_BAKERY_DIR if set, else
 * $PI_CODING_AGENT_DIR/bakery, else ~/.pi/agent/bakery.
 *
 * Features:
 * - Receive user messages from the `bakery` CLI (steer or follow-up delivery)
 * - Retrieve the last assistant messages from a session
 * - Report session status (idle, working, or blocked on user input)
 * - Gracefully shut down a session (only idle by default; force aborts non-idle)
 *
 * RPC Protocol:
 *   Commands are newline-delimited JSON objects with a `type` field:
 *   - { type: "send", message: "...", mode?: "steer"|"follow_up" }
 *   - { type: "get_message" }
 *   - { type: "get_status" }
 *   - { type: "shutdown", force?: boolean }
 *   - { type: "command", name: "new"|"clone"|"reload" }
 *
 *   `command` runs a built-in pi control command that has no headless
 *   equivalent unless routed through a real command handler. It is dispatched
 *   as the internal `/bakery-cmd` command so it runs in an
 *   ExtensionCommandContext, then replies with the resulting session id.
 *
 *   Responses are JSON objects with { type: "response", command, success, data?, error? }
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { promises as fs } from "node:fs";
import * as net from "node:net";
import * as os from "node:os";
import * as path from "node:path";

function getBakeryDir(): string {
  const bakeryOverride = process.env.PI_CODING_AGENT_BAKERY_DIR?.trim();
  if (bakeryOverride) return bakeryOverride;
  const configDir = process.env.PI_CODING_AGENT_DIR?.trim() || path.join(os.homedir(), ".pi", "agent");
  return path.join(configDir, "bakery");
}

const BAKERY_DIR = getBakeryDir();
const SOCKET_SUFFIX = ".sock";

// ============================================================================
// RPC Types
// ============================================================================

interface RpcResponse {
  type: "response";
  command: string;
  success: boolean;
  error?: string;
  data?: unknown;
  id?: string;
}

// Unified command structure
interface RpcSendCommand {
  type: "send";
  message: string;
  mode?: "steer" | "follow_up";
  id?: string;
}

interface RpcGetMessageCommand {
  type: "get_message";
  id?: string;
}

interface RpcGetStatusCommand {
  type: "get_status";
  id?: string;
}

interface RpcShutdownCommand {
  type: "shutdown";
  force?: boolean;
  id?: string;
}

interface RpcControlCommand {
  type: "command";
  name: string;
  id?: string;
}

type RpcCommand =
  | RpcSendCommand
  | RpcGetMessageCommand
  | RpcGetStatusCommand
  | RpcShutdownCommand
  | RpcControlCommand;

// Built-in pi commands routed through `/bakery-cmd`. Each has an
// ExtensionCommandContext method but no headless dispatch of its own.
const BUILTIN_COMMANDS = new Set(["new", "clone", "reload"]);

// ============================================================================
// Socket State
// ============================================================================

interface SocketState {
  server: net.Server | null;
  socketPath: string | null;
  context: ExtensionContext | null;
  alias: string | null;
  aliasTimer: ReturnType<typeof setInterval> | null;
  // Depth of open blocking UI prompts (confirm/select/input/editor/custom).
  promptDepth: number;
  // Client connection awaiting a `command` reply, filled in by the deferred
  // `/bakery-cmd` handler once the resulting session id is known.
  pendingCommand: { socket: net.Socket; id?: string } | null;
}

// ============================================================================
// Utilities
// ============================================================================

const STATUS_KEY = "session-control";

function isErrnoException(error: unknown): error is NodeJS.ErrnoException {
  return typeof error === "object" && error !== null && "code" in error;
}

function getSocketPath(sessionId: string): string {
  return path.join(BAKERY_DIR, `${sessionId}${SOCKET_SUFFIX}`);
}

function isSafeAlias(alias: string): boolean {
  return !alias.includes("/") && !alias.includes("\\") && !alias.includes("..") && alias.length > 0;
}

function getAliasPath(alias: string): string {
  return path.join(BAKERY_DIR, `${alias}.alias`);
}

function getSessionAlias(ctx: ExtensionContext): string | null {
  const sessionName = ctx.sessionManager.getSessionName();
  const alias = sessionName ? sessionName.trim() : "";
  if (!alias || !isSafeAlias(alias)) return null;
  return alias;
}

async function ensureControlDir(): Promise<void> {
  await fs.mkdir(BAKERY_DIR, { recursive: true });
}

async function removeSocket(socketPath: string | null): Promise<void> {
  if (!socketPath) return;
  try {
    await fs.unlink(socketPath);
  } catch (error) {
    if (isErrnoException(error) && error.code !== "ENOENT") {
      throw error;
    }
  }
}

// TODO: add GC for stale sockets/aliases older than 7 days.
async function removeAliasesForSocket(socketPath: string | null): Promise<void> {
  if (!socketPath) return;
  try {
    const entries = await fs.readdir(BAKERY_DIR, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isSymbolicLink()) continue;
      const aliasPath = path.join(BAKERY_DIR, entry.name);
      let target: string;
      try {
        target = await fs.readlink(aliasPath);
      } catch {
        continue;
      }
      const resolvedTarget = path.resolve(BAKERY_DIR, target);
      if (resolvedTarget === socketPath) {
        await fs.unlink(aliasPath);
      }
    }
  } catch (error) {
    if (isErrnoException(error) && error.code === "ENOENT") return;
    throw error;
  }
}

async function createAliasSymlink(sessionId: string, alias: string): Promise<void> {
  if (!alias || !isSafeAlias(alias)) return;
  const aliasPath = getAliasPath(alias);
  const target = `${sessionId}${SOCKET_SUFFIX}`;
  try {
    await fs.unlink(aliasPath);
  } catch (error) {
    if (isErrnoException(error) && error.code !== "ENOENT") {
      throw error;
    }
  }
  try {
    await fs.symlink(target, aliasPath);
  } catch (error) {
    if (isErrnoException(error) && error.code !== "EEXIST") {
      throw error;
    }
  }
}

async function syncAlias(state: SocketState, ctx: ExtensionContext): Promise<void> {
  if (!state.server || !state.socketPath) return;
  const alias = getSessionAlias(ctx);
  if (alias && alias !== state.alias) {
    await removeAliasesForSocket(state.socketPath);
    await createAliasSymlink(ctx.sessionManager.getSessionId(), alias);
    state.alias = alias;
    return;
  }
  if (!alias && state.alias) {
    await removeAliasesForSocket(state.socketPath);
    state.alias = null;
  }
}

function writeResponse(socket: net.Socket, response: RpcResponse): void {
  try {
    socket.write(`${JSON.stringify(response)}\n`);
  } catch {
    // Socket may be closed
  }
}

function parseCommand(line: string): { command?: RpcCommand; error?: string } {
  try {
    const parsed = JSON.parse(line) as RpcCommand;
    if (!parsed || typeof parsed !== "object") {
      return { error: "Invalid command" };
    }
    if (typeof parsed.type !== "string") {
      return { error: "Missing command type" };
    }
    return { command: parsed };
  } catch (error) {
    return { error: error instanceof Error ? error.message : "Failed to parse command" };
  }
}

// ============================================================================
// Message Extraction
// ============================================================================

interface ExtractedMessage {
  role: "user" | "assistant";
  content: string;
  timestamp: number;
}

function getTextMessages(ctx: ExtensionContext): ExtractedMessage[] {
  const messages: ExtractedMessage[] = [];
  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "message") continue;
    const msg = entry.message;
    if (!("role" in msg) || (msg.role !== "user" && msg.role !== "assistant")) continue;
    const content = Array.isArray(msg.content) ? msg.content : [{ type: "text", text: msg.content }];
    const textParts = content
      .filter((c): c is { type: "text"; text: string } => c.type === "text")
      .map((c) => c.text);
    if (textParts.length > 0) {
      messages.push({ role: msg.role, content: textParts.join("\n"), timestamp: msg.timestamp });
    }
  }
  return messages;
}

// ============================================================================
// Command Handlers
// ============================================================================

function sessionStatus(state: SocketState, ctx: ExtensionContext): string {
  if (state.promptDepth > 0) return "blocked";
  if (!ctx.isIdle()) return "working";
  return "idle";
}

// Reply to the connection that issued the `command` RPC. The `new`/`clone`
// replies fire from a `withSession` callback that runs after the old session
// has been torn down, so this writes to the captured socket directly.
function settlePendingCommand(
  state: SocketState,
  success: boolean,
  data?: unknown,
  error?: string,
): void {
  const pending = state.pendingCommand;
  state.pendingCommand = null;
  if (!pending) return;
  writeResponse(pending.socket, {
    type: "response",
    command: "command",
    success,
    data,
    error,
    id: pending.id,
  });
}

async function runBuiltinCommand(
  state: SocketState,
  ctx: ExtensionCommandContext,
  name: string,
): Promise<void> {
  const withSession = async (replaced: ExtensionCommandContext) => {
    settlePendingCommand(state, true, { sessionId: replaced.sessionManager.getSessionId() });
  };

  if (name === "reload") {
    // Reply before reload tears this runtime down; ctx.reload() is terminal.
    settlePendingCommand(state, true, { sessionId: ctx.sessionManager.getSessionId() });
    await ctx.reload();
    return;
  }
  if (name === "new") {
    const result = await ctx.newSession({ withSession });
    if (result.cancelled) settlePendingCommand(state, false, undefined, "new session cancelled");
    return;
  }
  if (name === "clone") {
    const leafId = ctx.sessionManager.getLeafId();
    // Forking a session with no message history at its header entry tears
    // down the headless process instead of resolving, so refuse it.
    const hasHistory = ctx.sessionManager.getBranch().some((e) => e.type === "message");
    if (!leafId || !hasHistory) {
      settlePendingCommand(state, false, undefined, "nothing to clone yet");
      return;
    }
    const result = await ctx.fork(leafId, { position: "at", withSession });
    if (result.cancelled) settlePendingCommand(state, false, undefined, "clone cancelled");
    return;
  }
  settlePendingCommand(state, false, undefined, `unsupported command: ${name}`);
}

async function handleCommand(
  pi: ExtensionAPI,
  state: SocketState,
  command: RpcCommand,
  socket: net.Socket,
): Promise<void> {
  const id = "id" in command && typeof command.id === "string" ? command.id : undefined;
  const respond = (success: boolean, commandName: string, data?: unknown, error?: string) => {
    if (state.context) {
      void syncAlias(state, state.context);
    }
    writeResponse(socket, { type: "response", command: commandName, success, data, error, id });
  };

  const ctx = state.context;
  if (!ctx) {
    respond(false, command.type, undefined, "Session not ready");
    return;
  }

  void syncAlias(state, ctx);

  // Report status
  if (command.type === "get_status") {
    respond(true, "get_status", { status: sessionStatus(state, ctx) });
    return;
  }

  // Graceful shutdown
  if (command.type === "shutdown") {
    const status = sessionStatus(state, ctx);
    if (status !== "idle") {
      if (!command.force) {
        respond(false, "shutdown", undefined, `Session is ${status}, not idle (use --force)`);
        return;
      }
      // Interrupt the running turn / prompt so the deferred shutdown can fire.
      ctx.abort();
    }
    respond(true, "shutdown", { shuttingDown: true });
    // Defer so the response flushes before the process tears down.
    setTimeout(() => ctx.shutdown(), 0);
    return;
  }

  // Get the recent conversation slice plus current status.
  if (command.type === "get_message") {
    const messages = getTextMessages(ctx);
    const status = sessionStatus(state, ctx);

    let lastUserIndex = -1;
    let message: ExtractedMessage | null = null;
    for (let i = messages.length - 1; i >= 0; i--) {
      if (message === null && messages[i].role === "assistant") message = messages[i];
      if (lastUserIndex === -1 && messages[i].role === "user") lastUserIndex = i;
    }

    const prompt = lastUserIndex >= 0 ? messages[lastUserIndex] : null;
    let priorAgent: ExtractedMessage | null = null;
    for (let i = lastUserIndex - 1; i >= 0; i--) {
      if (messages[i].role === "assistant") { priorAgent = messages[i]; break; }
    }
    const agentsSince = lastUserIndex >= 0
      ? messages.slice(lastUserIndex + 1).filter((m) => m.role === "assistant")
      : [];

    respond(true, "get_message", { status, message, prompt, priorAgent, agentsSince });
    return;
  }

  // Send message
  if (command.type === "send") {
    const message = command.message;
    if (typeof message !== "string" || message.trim().length === 0) {
      respond(false, "send", undefined, "Missing message");
      return;
    }

    const mode = command.mode ?? "steer";
    const isIdle = ctx.isIdle();

    // Deliver as a real user message so it behaves exactly as if typed.
    if (isIdle) {
      pi.sendUserMessage(message, { expandPromptTemplates: true });
    } else {
      pi.sendUserMessage(message, {
        deliverAs: mode === "follow_up" ? "followUp" : "steer",
        expandPromptTemplates: true,
      });
    }

    respond(true, "send", { delivered: true, mode: isIdle ? "direct" : mode });
    return;
  }

  // Run a built-in control command via the `/bakery-cmd` handler, which gets
  // the ExtensionCommandContext this socket handler lacks.
  if (command.type === "command") {
    if (!BUILTIN_COMMANDS.has(command.name)) {
      respond(false, "command", undefined, `unsupported command: ${command.name}`);
      return;
    }
    const status = sessionStatus(state, ctx);
    if (status !== "idle") {
      respond(false, "command", undefined, `session is ${status}, not idle`);
      return;
    }
    state.pendingCommand = { socket, id };
    pi.sendUserMessage(`/bakery-cmd ${command.name}`, { expandPromptTemplates: true });
    return;
  }

  const unsupportedType = (command as { type: string }).type;
  respond(false, unsupportedType, undefined, `Unsupported command: ${unsupportedType}`);
}

// ============================================================================
// Server Management
// ============================================================================

async function createServer(pi: ExtensionAPI, state: SocketState, socketPath: string): Promise<net.Server> {
  const server = net.createServer((socket) => {
    socket.setEncoding("utf8");
    let buffer = "";
    socket.on("data", (chunk) => {
      buffer += chunk;
      let newlineIndex = buffer.indexOf("\n");
      while (newlineIndex !== -1) {
        const line = buffer.slice(0, newlineIndex).trim();
        buffer = buffer.slice(newlineIndex + 1);
        newlineIndex = buffer.indexOf("\n");
        if (!line) continue;

        const parsed = parseCommand(line);
        if (parsed.error) {
          if (state.context) {
            void syncAlias(state, state.context);
          }
          writeResponse(socket, {
            type: "response",
            command: "parse",
            success: false,
            error: `Failed to parse command: ${parsed.error}`,
          });
          continue;
        }

        handleCommand(pi, state, parsed.command!, socket);
      }
    });
  });

  // Wait for server to start listening, with error handling
  await new Promise<void>((resolve, reject) => {
    server.once("error", reject);
    server.listen(socketPath, () => {
      server.removeListener("error", reject);
      resolve();
    });
  });

  return server;
}

async function startControlServer(pi: ExtensionAPI, state: SocketState, ctx: ExtensionContext): Promise<void> {
  await ensureControlDir();
  const sessionId = ctx.sessionManager.getSessionId();
  const socketPath = getSocketPath(sessionId);

  if (state.socketPath === socketPath && state.server) {
    state.context = ctx;
    await syncAlias(state, ctx);
    return;
  }

  await stopControlServer(state);
  await removeSocket(socketPath);

  state.context = ctx;
  state.socketPath = socketPath;
  state.server = await createServer(pi, state, socketPath);
  state.alias = null;
  await syncAlias(state, ctx);
}

async function stopControlServer(state: SocketState): Promise<void> {
  if (!state.server) {
    await removeAliasesForSocket(state.socketPath);
    await removeSocket(state.socketPath);
    state.socketPath = null;
    state.alias = null;
    return;
  }

  const socketPath = state.socketPath;
  state.socketPath = null;
  // A pending `command` reply (new/clone) still needs its client connection,
  // which runs after this shutdown; awaiting close() would deadlock on it.
  if (state.pendingCommand) {
    state.server.close();
  } else {
    await new Promise<void>((resolve) => state.server?.close(() => resolve()));
  }
  state.server = null;
  await removeAliasesForSocket(socketPath);
  await removeSocket(socketPath);
  state.alias = null;
}

function updateStatus(ctx: ExtensionContext | null, enabled: boolean): void {
  if (!ctx?.hasUI) return;
  if (!enabled) {
    ctx.ui.setStatus(STATUS_KEY, undefined);
    return;
  }
  const sessionId = ctx.sessionManager.getSessionId();
  ctx.ui.setStatus(STATUS_KEY, ctx.ui.theme.fg("dim", `session ${sessionId}`));
}

// ============================================================================
// Extension Export
// ============================================================================

export default function (pi: ExtensionAPI) {
  const state: SocketState = {
    server: null,
    socketPath: null,
    context: null,
    alias: null,
    aliasTimer: null,
    promptDepth: 0,
    pendingCommand: null,
  };

  pi.registerCommand("bakery-cmd", {
    description: "internal: bakery control-plane command dispatch",
    handler: async (args, ctx) => {
      await runBuiltinCommand(state, ctx, args.trim());
    },
  });

  const refreshServer = async (ctx: ExtensionContext) => {
    await startControlServer(pi, state, ctx);
    if (!state.aliasTimer) {
      state.aliasTimer = setInterval(() => {
        if (!state.context) return;
        void syncAlias(state, state.context);
      }, 1000);
    }
    updateStatus(ctx, true);
  };

  pi.on("session_start", async (_event, ctx) => {
    await refreshServer(ctx);
  });

  pi.on("session_shutdown", async () => {
    if (state.aliasTimer) {
      clearInterval(state.aliasTimer);
      state.aliasTimer = null;
    }
    updateStatus(state.context, false);
    await stopControlServer(state);
  });

  // Track blocking UI prompts so status can report "blocked" on user input.
  pi.on("ui_prompt_start", () => {
    state.promptDepth += 1;
  });
  pi.on("ui_prompt_end", () => {
    state.promptDepth = Math.max(0, state.promptDepth - 1);
  });
}
