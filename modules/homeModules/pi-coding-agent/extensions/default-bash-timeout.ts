/**
 * Default bash timeout
 *
 * Pi has no setting for a default bash timeout. A bash call without `timeout`
 * runs with no limit. This extension sets `timeout` to 120 seconds when the
 * model leaves it out, and limits an explicit timeout to 120 seconds.
 *
 * The transcript keeps the model's original tool arguments, so the built-in
 * renderer would show the uncapped number. A tool renderer resolver rewrites
 * the arguments it draws, so the header always shows the enforced timeout.
 */
import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_TIMEOUT_SECONDS = 120;

function capTimeout(timeout: number | undefined): number {
  return timeout == null ? MAX_TIMEOUT_SECONDS : Math.min(timeout, MAX_TIMEOUT_SECONDS);
}

type BashArgs = { command?: string; timeout?: number };

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (!isToolCallEventType("bash", event)) return;
    event.input.timeout = capTimeout(event.input.timeout);
  });

  pi.registerToolRenderer((toolName, next) => {
    if (toolName !== "bash") return next();
    const base = next();
    if (!base?.renderCall) return base;
    return {
      ...base,
      renderCall: (args, theme, context) => {
        const bashArgs = args as BashArgs | undefined;
        return base.renderCall!(
          { ...bashArgs, timeout: capTimeout(bashArgs?.timeout) },
          theme,
          context,
        );
      },
    };
  });
}
