// This file is vendored, run ./vendor to update it.
// Last Update: 2026-03-04
// Commit Hash: c2b61fb69718b73e88be9ee766e5d7b6e7292854
//
/**
 * oh-pi Safe Guard Extension
 *
 * Combines destructive command confirmation + protected paths in one extension.
 */
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export const DANGEROUS_PATTERNS = [
  /\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*-rf\b|.*--force\b)/,
  /\bsudo\s+rm\b/,
  /\b(DROP|TRUNCATE|DELETE\s+FROM)\b/i,
  /\bchmod\s+777\b/,
  /\bmkfs\b/,
  /\bdd\s+if=/,
  />\s*\/dev\/sd[a-z]/,
];

// TODO(thekevjames): un-vendor this script
export const PROTECTED_PATHS = [".env", ".git/", "node_modules/", "id_rsa", ".ssh/"];

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    // Check bash commands for dangerous patterns
    if (event.toolName === "bash") {
      const cmd = (event.input as { command?: string }).command ?? "";
      const match = DANGEROUS_PATTERNS.find((p) => p.test(cmd));
      if (match && ctx.hasUI) {
        const ok = await ctx.ui.confirm("⚠️ Dangerous Command", `Execute: ${cmd}?`);
        if (!ok) return { block: true, reason: "Blocked by user" };
      }
    }

    // Check write/edit for protected paths
    if (event.toolName === "write" || event.toolName === "edit") {
      const path = (event.input as { path?: string }).path ?? "";
      const hit = PROTECTED_PATHS.find((p) => path.includes(p));
      if (hit) {
        if (ctx.hasUI) {
          const ok = await ctx.ui.confirm("🛡️ Protected Path", `Allow write to ${path}?`);
          if (!ok) return { block: true, reason: `Protected path: ${hit}` };
        } else {
          return { block: true, reason: `Protected path: ${hit}` };
        }
      }
    }
  });
}
