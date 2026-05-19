/**
 * Time Awareness Extension
 *
 * Injects the actual current UTC time into the system prompt at the start
 * of each agent turn. This prevents the agent from assuming incorrect times
 * when debugging time-sensitive issues (log queries, freshness filters, etc.)
 *
 * Also injects the local timezone for context.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function timeAwareness(pi: ExtensionAPI) {
    pi.on("before_agent_start", async (event) => {
        const now = new Date();
        const utc = now.toISOString().replace("T", " ").replace(/\.\d+Z$/, " UTC");
        const local = now.toLocaleString("en-US", {
            timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: false,
        });
        const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;

        return {
            systemPrompt:
                event.systemPrompt +
                `

## Current Time
- UTC: ${utc}
- Local (${tz}): ${local}

When working with time-sensitive operations (log queries, freshness filters, cron expressions, timestamps), use the times above as your reference. Do not guess or assume the current time. If significant time has passed since the start of this conversation, verify the current time with \`date -u\` before using it in commands.
`,
        };
    });
}
