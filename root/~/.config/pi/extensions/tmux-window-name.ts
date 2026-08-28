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
 * pi only renames windows it owns: a window is owned when tmux's
 * `automatic-rename` is still on (tmux is auto-naming it, so no manual name is
 * present) or when the window's current name matches the last name pi applied.
 * If the user has manually renamed the window, pi backs off and leaves it alone.
 *
 * Scope: only active when pi runs inside a tmux pane (TMUX_PANE is set).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Captured at session_start; the pane that owns this pi process. tmux keeps
// $TMUX_PANE stable for the process lifetime, so reading it once is correct. A
// pane target resolves to its window for window-scoped tmux commands.
let tmuxPane: string | undefined;

// The last snake_case name pi applied to the window. Used to detect manual
// renames: `rename-window` turns tmux's `automatic-rename` off, so that option
// alone can't tell a pi-set name from a user-set one once pi has renamed once.
let lastSetName: string | undefined;

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async () => {
    tmuxPane = process.env.TMUX_PANE;
    // A name restored with the session (e.g. /resume) may already be on the
    // window from a prior run; adopt it as pi-owned so later manual renames are
    // still detected instead of being treated as a clobberable auto name.
    const restored = pi.getSessionName();
    if (restored) {
      const state = await getWindowState(pi);
      if (state && !state.automaticRename && state.name === toSnakeCase(restored)) {
        lastSetName = state.name;
      }
    }
    await setWindowName(pi, restored);
  });

  pi.on("session_info_changed", async (event) => {
    // event.name is the normalized name, or undefined when the name is cleared.
    await setWindowName(pi, event.name);
  });
}

async function setWindowName(pi: ExtensionAPI, name: string | undefined): Promise<void> {
  if (!tmuxPane) return;
  // Respect a name the user set manually: only touch windows pi owns.
  if (!(await weOwnWindow(pi))) return;
  const windowName = name ? toSnakeCase(name) : "";
  try {
    if (windowName) {
      await pi.exec("tmux", ["rename-window", "-t", tmuxPane, windowName]);
      lastSetName = windowName;
    } else {
      // Hand control back to tmux's own window naming.
      await pi.exec("tmux", ["set-window-option", "-t", tmuxPane, "automatic-rename", "on"]);
      lastSetName = undefined;
    }
  } catch {
    // Window naming is best-effort; never disrupt the session on failure.
  }
}

// pi owns the window when tmux is still auto-naming it, or when its current name
// is the one pi last applied. Any other name means the user renamed it by hand.
async function weOwnWindow(pi: ExtensionAPI): Promise<boolean> {
  const state = await getWindowState(pi);
  if (!state) return true; // Can't read state; fall back to prior best-effort behavior.
  if (state.automaticRename) return true;
  return state.name === lastSetName;
}

async function getWindowState(
  pi: ExtensionAPI,
): Promise<{ automaticRename: boolean; name: string } | undefined> {
  if (!tmuxPane) return undefined;
  try {
    // `#{automatic-rename}` renders as "1"/"0"; split on the first tab so window
    // names containing tabs (unusual, but possible) don't corrupt the flag.
    const result = await pi.exec("tmux", [
      "display-message",
      "-p",
      "-t",
      tmuxPane,
      "#{automatic-rename}\t#{window_name}",
    ]);
    if (result.code !== 0) return undefined;
    const [flag, ...rest] = result.stdout.replace(/\n$/, "").split("\t");
    return { automaticRename: flag === "1", name: rest.join("\t") };
  } catch {
    return undefined;
  }
}

function toSnakeCase(name: string): string {
  return name
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2") // split camelCase boundaries
    .replace(/[^a-zA-Z0-9]+/g, "_") // non-alphanumeric runs become one underscore
    .replace(/^_+|_+$/g, "")
    .toLowerCase();
}
