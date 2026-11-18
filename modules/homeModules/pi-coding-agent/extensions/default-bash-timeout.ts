/**
 * Default bash timeout
 *
 * Pi has no setting for a default bash timeout. A bash call without `timeout`
 * runs with no limit. This extension sets `timeout` to 120 seconds when the
 * model leaves it out, and limits an explicit timeout to 120 seconds.
 */
import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_TIMEOUT_SECONDS = 120;

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (!isToolCallEventType("bash", event)) return;
    const { timeout } = event.input;
    event.input.timeout =
      timeout == null ? MAX_TIMEOUT_SECONDS : Math.min(timeout, MAX_TIMEOUT_SECONDS);
  });
}
