/**
 * gpg-unlock-check
 *
 * Motivation: with commit.gpgsign=true, a locked GPG key surfaces only at the
 * first commit, mid-task, as "gpg: signing failed: Timeout" — across sessions
 * this forced ~15 manual "gpg unlocked, continue" interventions. This checks at
 * session start whether the signing key is already cached in gpg-agent and warns
 * up front so the key can be unlocked before any commit.
 *
 * Probe: a real signing operation with `--pinentry-mode error`, which never
 * pops a pinentry prompt — it succeeds iff the passphrase is already cached, and
 * returns non-zero otherwise. This answers exactly "will signing succeed without
 * blocking?" without side effects.
 *
 * Scope: OpenPGP signing only (gpg.format unset/openpgp). SSH/X.509 signing use
 * different mechanisms and are skipped. Re-check any time with /gpg-check.
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFile, spawn } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";

const execFileP = promisify(execFile);
const STATUS_KEY = "gpg-lock";
const PROBE_TIMEOUT_MS = 5000;

// gpg here uses an XDG GNUPGHOME; inherit it, falling back to the XDG default so
// the probe reads the same keyring the shell's commits use.
function gnupgEnv(): NodeJS.ProcessEnv {
  const env = { ...process.env };
  if (!env.GNUPGHOME) {
    const xdg = env.XDG_CONFIG_HOME || join(homedir(), ".config");
    env.GNUPGHOME = join(xdg, "gnupg");
  }
  return env;
}

async function gitConfig(cwd: string, env: NodeJS.ProcessEnv, key: string): Promise<string | undefined> {
  try {
    const { stdout } = await execFileP("git", ["config", "--get", key], { cwd, env, timeout: PROBE_TIMEOUT_MS });
    return stdout.trim() || undefined;
  } catch {
    return undefined;
  }
}

async function insideRepo(cwd: string, env: NodeJS.ProcessEnv): Promise<boolean> {
  try {
    const { stdout } = await execFileP("git", ["rev-parse", "--is-inside-work-tree"], { cwd, env, timeout: PROBE_TIMEOUT_MS });
    return stdout.trim() === "true";
  } catch {
    return false;
  }
}

async function keyExists(gpgProg: string, env: NodeJS.ProcessEnv, key: string): Promise<boolean> {
  try {
    await execFileP(gpgProg, ["--batch", "--list-secret-keys", key], { env, timeout: PROBE_TIMEOUT_MS });
    return true;
  } catch {
    return false;
  }
}

// Resolves true only if signing succeeds without prompting (key cached/unlocked).
function isUnlocked(gpgProg: string, env: NodeJS.ProcessEnv, key: string | undefined): Promise<boolean> {
  return new Promise((resolve) => {
    const args = [
      "--batch",
      "--no-tty",
      "--pinentry-mode",
      "error",
      ...(key ? ["--local-user", key] : []),
      "--sign",
      "-o",
      "/dev/null",
    ];
    const child = spawn(gpgProg, args, { env, stdio: ["pipe", "ignore", "ignore"] });
    const timer = setTimeout(() => {
      child.kill("SIGKILL");
      resolve(false);
    }, PROBE_TIMEOUT_MS);
    child.on("error", () => {
      clearTimeout(timer);
      resolve(false);
    });
    child.on("close", (code) => {
      clearTimeout(timer);
      resolve(code === 0);
    });
    child.stdin.on("error", () => {});
    child.stdin.end("pi-gpg-preflight\n");
  });
}

async function checkAndReport(ctx: ExtensionContext, announceUnlocked: boolean): Promise<void> {
  if (!ctx.hasUI) return;
  const env = gnupgEnv();

  const clear = () => ctx.ui.setStatus(STATUS_KEY, undefined);

  if (!(await insideRepo(ctx.cwd, env))) return clear();
  if ((await gitConfig(ctx.cwd, env, "commit.gpgsign")) !== "true") return clear();
  if (((await gitConfig(ctx.cwd, env, "gpg.format")) || "openpgp") !== "openpgp") return clear();

  const gpgProg = (await gitConfig(ctx.cwd, env, "gpg.program")) || "gpg";
  const key = await gitConfig(ctx.cwd, env, "user.signingkey");

  // A missing configured key is a different (config) problem, not a lock; skip.
  if (key && !(await keyExists(gpgProg, env, key))) return clear();

  if (await isUnlocked(gpgProg, env, key)) {
    clear();
    if (announceUnlocked) ctx.ui.notify(`GPG signing key ${key ?? "(default)"} is unlocked.`, "info");
    return;
  }

  ctx.ui.setStatus(STATUS_KEY, "⚠ gpg signing locked");
  ctx.ui.notify(
    `GPG signing key ${key ?? "(default)"} is locked; signed commits (commit.gpgsign=true) will ` +
      `time out until you unlock it. In a terminal run:  echo x | gpg${key ? ` -u ${key}` : ""} ` +
      `--sign -o /dev/null   then /gpg-check.`,
    "warning",
  );
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    try {
      await checkAndReport(ctx, false);
    } catch {
      // Preflight is best-effort; never disrupt startup.
    }
  });

  pi.registerCommand("gpg-check", {
    description: "Re-check whether the GPG signing key is unlocked",
    handler: async (_args, ctx) => {
      await checkAndReport(ctx, true);
    },
  });
}
