/**
 * Bash Default Timeout
 *
 * Pi's built-in bash tool has no default timeout: when the model omits
 * `timeout`, no timer is armed at all and a hung command stalls the run
 * indefinitely. Mutate the tool input so every bash call gets a bounded
 * timeout (in seconds) unless the model asked for a longer one explicitly.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEFAULT_TIMEOUT_SECONDS = 60;

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (event.toolName !== "bash") return undefined;

    const timeout = event.input.timeout;
    if (typeof timeout !== "number" || !Number.isFinite(timeout) || timeout <= 0) {
      event.input.timeout = DEFAULT_TIMEOUT_SECONDS;
    }

    return undefined;
  });
}
