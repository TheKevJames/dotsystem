/**
 * Docs-First Extension
 *
 * Intercepts tool calls and injects a reminder into the system prompt
 * to check documentation (via Context7 or tool-specific docs) before
 * attempting workarounds or guessing at API behavior.
 *
 * This prevents trial-and-error cycles like:
 * - Trying regex for truncation when stage.truncate exists
 * - Guessing at RE2 repeat count limits
 * - Assuming __gcp_* labels survive forwarding
 * - Guessing at Terraform ignore_changes syntax
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function docsFirst(pi: ExtensionAPI) {
    pi.on("before_agent_start", async (event) => {
        return {
            systemPrompt:
                event.systemPrompt +
                `

## Docs-First Principle

Before implementing a workaround, building a regex hack, or guessing at tool/framework API behavior:

1. **Search documentation first.** Use the context7 skill or read official docs to check whether a built-in feature already solves the problem. Load the context7 skill with the read tool if it is not already loaded.
2. **Verify assumptions.** Do not assume system state, API limits, or framework behavior — look it up or test it. If you cannot verify, say so explicitly rather than guessing.
3. **Prefer built-in features.** If a framework provides a purpose-built solution (e.g., stage.truncate, lifecycle ignore_changes), always prefer it over custom workarounds.
4. **Admit uncertainty.** When you don't know something, say "I'm not sure — let me check" rather than confidently stating something that might be wrong.

Examples of what this prevents:
- Using complex nested regex when a built-in truncation stage exists
- Assuming labels survive component forwarding without checking docs
- Guessing at regex engine limits instead of looking them up
- Fabricating theories about system state (e.g., "there must be a PubSub backlog") without data
`,
        };
    });
}
