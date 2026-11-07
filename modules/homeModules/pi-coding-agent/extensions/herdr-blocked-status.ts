/**
 * Herdr blocked status for questionnaires
 *
 * Herdr reads an agent's state from OSC 7501 (see `~/.config/herdr-app/AGENTS.md`:
 * agents are terminals whose program reports `working`/`blocked`/`idle`/`done`).
 * Pi reports `blocked` only for dialogs it pushes with a blocked descriptor:
 * `showExtensionSelector`, `showExtensionInput`, `showExtensionEditor` and login.
 * `ui.custom()` passes none — the inline branch calls `pushExtensionDialog(c)`
 * with no status, and the overlay branch (`showOverlay`) never reports. So
 * `@juicesharp/rpiv-ask-user-question`, which mounts through `ui.custom()`, kept
 * Herdr on the stale `working` state while the questionnaire waited for an answer.
 *
 * This extension listens to the plugin's public `rpiv:ask-user:*` events and
 * writes the status itself, then restores `working` when the questionnaire ends.
 *
 * Gated on `HC_TERMINAL_ID`: only herdr-core terminals are known to answer the
 * OSC 7501 support query, and an unsupported terminal would print the sequence.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { formatProgramStatus, type ProgramStatus } from "@earendil-works/pi-tui";

const ASK_USER_PROMPT_EVENT = "rpiv:ask-user:prompt";
const ASK_USER_BLOCKED_EVENT = "rpiv:ask-user:blocked";

interface AskUserPromptPayload {
	toolCallId?: string;
	questions?: ReadonlyArray<{ header?: string; question?: string }>;
}

interface AskUserBlockedPayload {
	active?: boolean;
	toolCallId?: string;
}

/** Fallback label when the prompt event carried no usable question text. */
const DEFAULT_BLOCKED_MESSAGE = "Waiting for your answer";

export default function herdrBlockedStatus(pi: ExtensionAPI): void {
	if (!process.stdout.isTTY || !process.env.HC_TERMINAL_ID) return;

	const labels = new Map<string, string>();
	const waiting = new Set<string>();
	let lastReport = "";

	function write(status: ProgramStatus): void {
		const key = JSON.stringify(status);
		if (key === lastReport) return;
		lastReport = key;
		try {
			process.stdout.write(formatProgramStatus(status));
		} catch {
			// Status reporting is best effort; never break the questionnaire.
		}
	}

	function report(): void {
		const id = [...waiting].at(-1);
		if (id !== undefined) {
			write({state: "blocked", app: "pi", kind: "question", message: labels.get(id) ?? DEFAULT_BLOCKED_MESSAGE});
			return;
		}
		labels.clear();
		// The run is still active after a questionnaire closes, so `working` is the
		// state Pi itself holds; its next report resumes from that state.
		write({state: "working", app: "pi"});
	}

	const unsubscribePrompt = pi.events.on(ASK_USER_PROMPT_EVENT, (data) => {
		const payload = data as AskUserPromptPayload | undefined;
		const id = payload?.toolCallId;
		if (!id) return;
		const text = payload?.questions?.[0]?.header?.trim() || payload?.questions?.[0]?.question?.trim();
		if (text) labels.set(id, text);
	});

	const unsubscribeBlocked = pi.events.on(ASK_USER_BLOCKED_EVENT, (data) => {
		const payload = data as AskUserBlockedPayload | undefined;
		const id = payload?.toolCallId;
		if (!id || typeof payload?.active !== "boolean") return;
		if (payload.active) waiting.add(id);
		else waiting.delete(id);
		report();
	});

	pi.on("session_shutdown", () => {
		unsubscribePrompt();
		unsubscribeBlocked();
	});
}
