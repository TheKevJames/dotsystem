/**
 * tmux-window-name
 *
 * Mirrors the pi session name onto the tmux window that the session lives in, so
 * that running `/name` in pi also renames the surrounding tmux window.
 *
 * The window name is normalized to lowercase snake_case. `rename-window`
 * implicitly disables tmux's `automatic-rename` for that window, so clearing the
 * pi session name re-enables it to restore tmux's default behavior.
 *
 * Scope: only active when pi runs inside a tmux pane (TMUX_PANE is set).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Captured at session_start; the pane that owns this pi process. tmux keeps
// $TMUX_PANE stable for the process lifetime, so reading it once is correct. A
// pane target resolves to its window for window-scoped tmux commands.
let tmuxPane: string | undefined;

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async () => {
    tmuxPane = process.env.TMUX_PANE;
    // Reflect a name that was restored with the session (e.g. /resume).
    await setWindowName(pi, pi.getSessionName());
  });

  pi.on("session_info_changed", async (event) => {
    // event.name is the normalized name, or undefined when the name is cleared.
    await setWindowName(pi, event.name);
  });
}

async function setWindowName(pi: ExtensionAPI, name: string | undefined): Promise<void> {
  if (!tmuxPane) return;
  const windowName = name ? toSnakeCase(name) : "";
  try {
    if (windowName) {
      await pi.exec("tmux", ["rename-window", "-t", tmuxPane, windowName]);
    } else {
      // Hand control back to tmux's own window naming.
      await pi.exec("tmux", ["set-window-option", "-t", tmuxPane, "automatic-rename", "on"]);
    }
  } catch {
    // Window naming is best-effort; never disrupt the session on failure.
  }
}

function toSnakeCase(name: string): string {
  return name
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2") // split camelCase boundaries
    .replace(/[^a-zA-Z0-9]+/g, "_") // non-alphanumeric runs become one underscore
    .replace(/^_+|_+$/g, "")
    .toLowerCase();
}
