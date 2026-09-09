/**
 * gcloud-auth-check
 *
 * Motivation: an expired or absent gcloud credential surfaces only at the first
 * API call, mid-task, as a "reauthentication required" / "invalid_grant" error —
 * forcing a manual `gcloud auth login` interruption. This checks at session
 * start whether the active account already has a usable credential and warns up
 * front so it can be refreshed before any gcloud-dependent work.
 *
 * Probe: `gcloud auth print-access-token`, which mints an access token from the
 * cached refresh credential without any interactive prompt. It succeeds iff a
 * valid credential is present (refreshing silently if needed) and returns
 * non-zero otherwise. This answers exactly "will a gcloud API call succeed
 * without blocking?" without side effects.
 *
 * Scope: user Application Default / gcloud account credentials. Re-check any
 * time with /gcloud-check.
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileP = promisify(execFile);
const STATUS_KEY = "gcloud-auth";
const PROBE_TIMEOUT_MS = 10000;

async function gcloudPath(): Promise<string | undefined> {
  try {
    await execFileP("gcloud", ["--version"], { timeout: PROBE_TIMEOUT_MS });
    return "gcloud";
  } catch {
    return undefined;
  }
}

async function activeAccount(gcloud: string): Promise<string | undefined> {
  try {
    const { stdout } = await execFileP(
      gcloud,
      ["auth", "list", "--filter=status:ACTIVE", "--format=value(account)"],
      { timeout: PROBE_TIMEOUT_MS },
    );
    return stdout.trim() || undefined;
  } catch {
    return undefined;
  }
}

// Resolves true only if a token can be minted without prompting (creds valid).
async function isAuthenticated(gcloud: string): Promise<boolean> {
  try {
    const { stdout } = await execFileP(gcloud, ["auth", "print-access-token"], {
      timeout: PROBE_TIMEOUT_MS,
    });
    return stdout.trim().length > 0;
  } catch {
    return false;
  }
}

async function checkAndReport(ctx: ExtensionContext, announceAuthed: boolean): Promise<void> {
  if (!ctx.hasUI) return;

  const clear = () => ctx.ui.setStatus(STATUS_KEY, undefined);

  const gcloud = await gcloudPath();
  if (!gcloud) return clear();

  const account = await activeAccount(gcloud);

  // No active account is a different (setup) problem, not an expiry; skip.
  if (!account) return clear();

  if (await isAuthenticated(gcloud)) {
    clear();
    if (announceAuthed) ctx.ui.notify(`gcloud account ${account} is authenticated.`, "info");
    return;
  }

  ctx.ui.setStatus(STATUS_KEY, "⚠ gcloud auth expired");
  ctx.ui.notify(
    `gcloud account ${account} has no usable credential; gcloud API calls will ` +
      `fail until you reauthenticate. In a terminal run:  gcloud auth login   then /gcloud-check.`,
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

  pi.registerCommand("gcloud-check", {
    description: "Re-check whether the active gcloud account is authenticated",
    handler: async (_args, ctx) => {
      await checkAndReport(ctx, true);
    },
  });
}
