/**
 * Applies a default timeout to bash tool calls that omit one.
 *
 * pi's built-in bash tool has no default timeout, so a command the model runs
 * without an explicit `timeout` can hang indefinitely. This patches the tool
 * arguments in place before execution instead of replacing the bash tool, so
 * pi's own bash implementation (and its `shellPath` / `shellCommandPrefix`
 * settings) stays intact.
 */

import {
  isToolCallEventType,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

const DEFAULT_TIMEOUT_SECONDS = 300;

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    if (isToolCallEventType("bash", event)) {
      event.input.timeout ??= DEFAULT_TIMEOUT_SECONDS;
    }
  });
}
