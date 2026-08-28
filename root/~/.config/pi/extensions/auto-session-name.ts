/**
 * auto-session-name
 *
 * Automatically names sessions based on the first user message.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let named = false;

  pi.on("session_start", async (_event, ctx) => {
    named = !!pi.getSessionName();
  });

  pi.on("agent_end", async (event) => {
    // Re-check the live name here, not just the session_start snapshot, so a
    // /name set after startup but before the first agent_end is not clobbered.
    if (named || pi.getSessionName()) return;
    const userMsg = event.messages.find((m) => m.role === "user");
    if (!userMsg) return;
    const text = typeof userMsg.content === "string"
      ? userMsg.content
      : userMsg.content.filter((b) => b.type === "text").map((b) => (b as { text: string }).text).join(" ");
    if (!text) return;
    const name = text.slice(0, 60).replace(/\n/g, " ").trim();
    if (name) {
      pi.setSessionName(name);
      named = true;
    }
  });
}
