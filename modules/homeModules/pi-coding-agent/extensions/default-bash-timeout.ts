/**
 * Default bash timeout
 *
 * Pi has no setting for a default bash timeout. A bash call without `timeout`
 * runs with no limit. This extension sets `timeout` to 120 seconds when the
 * model leaves it out. An explicit timeout from the model is kept.
 */
import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DEFAULT_TIMEOUT_SECONDS = 120;

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (isToolCallEventType("bash", event) && event.input.timeout == null) {
      event.input.timeout = DEFAULT_TIMEOUT_SECONDS;
    }
  });
}
