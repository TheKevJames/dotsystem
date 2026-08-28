/**
 * notify-on-done
 *
 * Posts a native macOS notification when a pi session settles and is waiting
 * for input, so you can step away and get pinged when pi needs you.
 *
 * Scope: macOS + Terminal.app inside tmux (one pi session per tmux pane).
 * The notification is delivered via `osascript display notification`, which
 * shows under the "Script Editor" identity. Set that app to "Banners" in
 * System Settings > Notifications for a transient, button-free banner.
 *
 * Suppression: a notification is skipped only when you are already looking at
 * this pi session, i.e. Terminal.app is frontmost AND this pi process's tmux
 * pane is the active pane of the active window. Any weaker focus (different
 * app, different tmux window/pane) still notifies.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const SOUND = "Ping";
const BODY = "Ready for Input";

// Captured at session_start; the pane that owns this pi process. tmux keeps
// $TMUX_PANE stable for the process lifetime, so reading it once is correct.
let tmuxPane: string | undefined;

// AppleScript string literals only need backslash and double-quote escaped.
function asString(value: string): string {
  return value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async () => {
    tmuxPane = process.env.TMUX_PANE;
  });

  pi.on("agent_settled", async (_event, ctx) => {
    if (ctx.mode !== "tui" || process.platform !== "darwin") return;

    const title = pi.getSessionName() || "Pi";
    const notifyCmd = `display notification "${asString(BODY)}" with title "${asString(title)}" sound name "${SOUND}"`;

    try {
      if (await isThisPaneFocused()) {
        // Pane is focused: only notify if the user has tabbed away from
        // Terminal.app. Combined into one osascript call to avoid a second
        // subprocess for the frontmost-app check.
        const script = [
          "tell application \"System Events\"",
          "if (name of first application process whose frontmost is true) is not \"Terminal\" then",
          notifyCmd,
          "end if",
          "end tell",
        ].join("\n");
        await pi.exec("osascript", ["-e", script]);
      } else {
        // Not looking at this pane (different tmux window/pane): always notify.
        await pi.exec("osascript", ["-e", notifyCmd]);
      }
    } catch {
      // Notifications are best-effort; never disrupt the session on failure.
    }
  });

  async function isThisPaneFocused(): Promise<boolean> {
    if (!tmuxPane) return false;
    const result = await pi.exec("tmux", [
      "display-message",
      "-p",
      "-t",
      tmuxPane,
      "#{pane_active}#{window_active}",
    ]);
    return result.stdout.trim() === "11";
  }
}
