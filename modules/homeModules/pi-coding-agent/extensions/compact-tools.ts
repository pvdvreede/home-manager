/**
 * Compact Tool Renderer
 *
 * Re-registers Pi's built-in tools (read, bash, edit, write, find, grep, ls)
 * with the same behavior but quieter rendering:
 *
 * - Collapsed (default): shows the tool call plus a one-line summary
 *   prefixed by a status marker:
 *     spinner  while the tool is running
 *     green ●  on success
 *     red   ●  on failure
 * - Expanded (`ctrl+o`): additionally shows a truncated preview of the output.
 *
 * Execution is delegated to the original built-in tools, so behavior and the
 * model-facing content are unchanged. Only the transcript display differs.
 *
 * How the spinner works: the TUI calls `renderResult` again every time the
 * render context's `invalidate()` runs. While a tool is partial we keep a
 * per-tool interval (stored on `context.state`) calling `ctx.invalidate()`, and
 * derive the frame from wall-clock time (same pattern as Pi's bash renderer).
 */

import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import {
	createBashTool,
	createEditTool,
	createFindTool,
	createGrepTool,
	createLsTool,
	createReadTool,
	createWriteTool,
	generateDiffString,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { readFile } from "node:fs/promises";
import { join, resolve } from "node:path";
import { homedir } from "os";

const PREVIEW_LINES = 20;
const MAX_DIFF_LINES = 60;
const FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const FRAME_MS = 80;

interface SpinState {
	timer?: ReturnType<typeof setInterval>;
}

interface RenderCtx {
	invalidate: () => void;
	state: SpinState;
	isError?: boolean;
}

/**
 * Status marker: animated spinner while running, else a green (success) or red
 * (failure) dot. The frame is derived from wall-clock time so it advances at a
 * steady rate regardless of how often the TUI re-renders. While running we keep
 * a per-tool interval alive that calls `ctx.invalidate()` to drive re-renders.
 */
function marker(theme: Theme, ctx: RenderCtx, isPartial: boolean, ok?: boolean): string {
	const state = ctx.state;
	if (isPartial) {
		state.timer ??= setInterval(() => ctx.invalidate(), FRAME_MS);
		const frame = FRAMES[Math.floor(Date.now() / FRAME_MS) % FRAMES.length];
		return theme.fg("accent", frame) + " ";
	}
	if (state.timer) {
		clearInterval(state.timer);
		state.timer = undefined;
	}
	const success = ok ?? !ctx.isError;
	return theme.fg(success ? "success" : "error", "●") + " ";
}

function shortenPath(path: string): string {
	const home = homedir();
	return path.startsWith(home) ? `~${path.slice(home.length)}` : path;
}

/** First text content block, or "" when there is none (e.g. images). */
function textOf(result: { content: Array<{ type: string; text?: string }> }): string {
	const block = result.content.find((c) => c.type === "text");
	return block && block.type === "text" ? (block.text ?? "") : "";
}

/** Render a capped preview of `output` when expanded, else "". */
function preview(output: string, theme: Theme): string {
	const lines = output.trim().split("\n");
	if (!lines.length || (lines.length === 1 && !lines[0])) return "";
	const shown = lines.slice(0, PREVIEW_LINES);
	let text = "\n" + shown.map((l) => theme.fg("toolOutput", l)).join("\n");
	if (lines.length > PREVIEW_LINES) {
		text += `\n${theme.fg("muted", `... ${lines.length - PREVIEW_LINES} more lines`)}`;
	}
	return text;
}

/**
 * Pi's edit and write tools emit a line-numbered unified diff with one line per
 * change: `+N content`, `-N content`, ` N content`, and ` ...` for skipped runs.
 */
function colorDiffLine(line: string, theme: Theme): string {
	if (line.startsWith("+")) return theme.fg("success", line);
	if (line.startsWith("-")) return theme.fg("error", line);
	return theme.fg("dim", line);
}

function diffStats(diff: string): { add: number; del: number } {
	let add = 0;
	let del = 0;
	for (const line of diff.split("\n")) {
		if (line.startsWith("+")) add++;
		else if (line.startsWith("-")) del++;
	}
	return { add, del };
}

/** Render a diff capped at MAX_DIFF_LINES, prefixed with a leading newline. */
function renderDiffLines(diff: string, theme: Theme): string {
	const lines = diff.split("\n");
	const shown = lines.slice(0, MAX_DIFF_LINES);
	let text = shown.map((line) => `\n${colorDiffLine(line, theme)}`).join("");
	if (lines.length > MAX_DIFF_LINES) {
		text += `\n${theme.fg("muted", `⋯ ${lines.length - MAX_DIFF_LINES} more diff lines`)}`;
	}
	return text;
}

/**
 * Mirror the path normalization Pi's write tool applies (Unicode spaces to ASCII,
 * strip a leading "@", expand "~"): the preview must read the same file the tool
 * overwrites. `resolveToCwd`/`normalizePath` are not public exports, so this is local.
 */
function resolveWritePath(cwd: string, path: string): string {
	const normalized = path.replace(/[\u00a0\u2000-\u200a\u202f\u205f\u3000]/g, " ").replace(/^@/, "");
	let resolved = normalized;
	if (normalized === "~") resolved = homedir();
	else if (normalized.startsWith("~/")) resolved = join(homedir(), normalized.slice(2));
	// resolve() lets an absolute path win over cwd, matching resolveToCwd.
	return resolve(cwd, resolved);
}

/** Previous contents for the write diff; "" when unreadable (e.g. new file). */
async function readBefore(cwd: string, path: string): Promise<string> {
	try {
		return await readFile(resolveWritePath(cwd, path), "utf8");
	} catch {
		return "";
	}
}

// Built-in tool instances are cwd-dependent; cache per directory.
const toolCache = new Map<string, ReturnType<typeof createBuiltInTools>>();

function createBuiltInTools(cwd: string) {
	return {
		read: createReadTool(cwd),
		bash: createBashTool(cwd),
		edit: createEditTool(cwd),
		write: createWriteTool(cwd),
		find: createFindTool(cwd),
		grep: createGrepTool(cwd),
		ls: createLsTool(cwd),
	};
}

function getBuiltInTools(cwd: string) {
	let tools = toolCache.get(cwd);
	if (!tools) {
		tools = createBuiltInTools(cwd);
		toolCache.set(cwd, tools);
	}
	return tools;
}

export default function (pi: ExtensionAPI) {
	// --- read: path (+ line range), summary = line count --------------------
	pi.registerTool({
		name: "read",
		label: "read",
		description: getBuiltInTools(process.cwd()).read.description,
		parameters: getBuiltInTools(process.cwd()).read.parameters,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			return getBuiltInTools(ctx.cwd).read.execute(toolCallId, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			let text = theme.fg("toolTitle", theme.bold("read "));
			text += theme.fg("accent", shortenPath(args.path || "..."));
			if (args.offset || args.limit) {
				const start = args.offset ?? 1;
				const end = args.limit !== undefined ? start + args.limit - 1 : "";
				text += theme.fg("dim", `:${start}${end ? `-${end}` : ""}`);
			}
			return new Text(text, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme, ctx) {
			const dot = marker(theme, ctx, isPartial);
			if (isPartial) return new Text(dot + theme.fg("warning", "reading..."), 0, 0);
			const output = textOf(result);
			if (!output) return new Text(dot, 0, 0);
			const lineCount = output.split("\n").length;
			let text = dot + theme.fg("success", `${lineCount} lines`);
			if (expanded) text += preview(output, theme);
			return new Text(text, 0, 0);
		},
	});

	// --- bash: command, summary = done/exit + line count --------------------
	pi.registerTool({
		name: "bash",
		label: "bash",
		description: getBuiltInTools(process.cwd()).bash.description,
		parameters: getBuiltInTools(process.cwd()).bash.parameters,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			return getBuiltInTools(ctx.cwd).bash.execute(toolCallId, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			const cmd = (args.command || "...") as string;
			const shown = cmd.length > 100 ? `${cmd.slice(0, 97)}...` : cmd;
			let text = theme.fg("toolTitle", theme.bold("$ ")) + theme.fg("accent", shown);
			if (args.timeout) text += theme.fg("dim", ` (timeout ${args.timeout}s)`);
			return new Text(text, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme, ctx) {
			const output = textOf(result);
			// Pi's bash tool throws on failure, appending "Command exited with code N"
			// and setting ctx.isError. Fall back to isError when no exit code is present
			// (e.g. timeouts/aborts) so failures are never shown as success.
			const exitMatch = output.match(/exited with code (\d+)/);
			const exitCode = exitMatch ? parseInt(exitMatch[1], 10) : null;
			const ok = exitCode !== null ? exitCode === 0 : !ctx.isError;
			const dot = marker(theme, ctx, isPartial, ok);
			if (isPartial) return new Text(dot + theme.fg("warning", "running..."), 0, 0);
			const lineCount = output.split("\n").filter((l) => l.trim()).length;
			let text = dot;
			text += ok
				? theme.fg("success", "done")
				: theme.fg("error", exitCode !== null ? `exit ${exitCode}` : "failed");
			text += theme.fg("dim", ` (${lineCount} lines)`);
			if (expanded) text += preview(output, theme);
			return new Text(text, 0, 0);
		},
	});

	// --- edit: path, summary = diff stats -----------------------------------
	pi.registerTool({
		name: "edit",
		label: "edit",
		description: getBuiltInTools(process.cwd()).edit.description,
		parameters: getBuiltInTools(process.cwd()).edit.parameters,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			return getBuiltInTools(ctx.cwd).edit.execute(toolCallId, params, signal, onUpdate);
		},
		renderCall(args, theme) {
			return new Text(
				theme.fg("toolTitle", theme.bold("edit ")) +
					theme.fg("accent", shortenPath(args.path || "...")),
				0,
				0,
			);
		},
		renderResult(result, { expanded, isPartial }, theme, ctx) {
			const output = textOf(result);
			const errored = output.startsWith("Error") || ctx.isError === true;
			const dot = marker(theme, ctx, isPartial, !errored);
			if (isPartial) return new Text(dot + theme.fg("warning", "editing..."), 0, 0);
			if (errored) return new Text(dot + theme.fg("error", output.split("\n")[0] || "failed"), 0, 0);
			const details = result.details as { diff?: string; firstChangedLine?: number } | undefined;
			const diff = details?.diff;
			if (!diff) return new Text(dot + theme.fg("success", "applied"), 0, 0);
			const { add, del } = diffStats(diff);
			let text = dot + theme.fg("success", `+${add}`) + theme.fg("dim", "/") + theme.fg("error", `-${del}`);
			if (typeof details?.firstChangedLine === "number") {
				text += theme.fg("dim", ` @ L${details.firstChangedLine}`);
			}
			if (expanded) text += renderDiffLines(diff, theme);
			return new Text(text, 0, 0);
		},
	});

	// --- write: path + line count, summary = written ------------------------
	pi.registerTool({
		name: "write",
		label: "write",
		description: getBuiltInTools(process.cwd()).write.description,
		parameters: getBuiltInTools(process.cwd()).write.parameters,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			const before = await readBefore(ctx.cwd, params.path);
			const result = await getBuiltInTools(ctx.cwd).write.execute(toolCallId, params, signal, onUpdate);
			if (result.isError) return result;
			const { diff, firstChangedLine } = generateDiffString(before, String(params.content ?? ""));
			return { ...result, details: { ...(result.details ?? {}), diff, firstChangedLine } };
		},
		renderCall(args, theme, ctx) {
			let text = theme.fg("toolTitle", theme.bold("write "));
			text += theme.fg("accent", shortenPath(args.path || "..."));
			const content = (args.content as string) || "";
			const lineCount = content.split("\n").length;
			text += theme.fg("dim", ` (${lineCount} lines)`);
			if (ctx.expanded && content) text += preview(content, theme);
			return new Text(text, 0, 0);
		},
		renderResult(result, { expanded, isPartial }, theme, ctx) {
			const output = textOf(result);
			const errored = output.startsWith("Error") || ctx.isError === true;
			const dot = marker(theme, ctx, isPartial, !errored);
			if (isPartial) return new Text(dot + theme.fg("warning", "writing..."), 0, 0);
			if (errored) return new Text(dot + theme.fg("error", output.split("\n")[0] || "failed"), 0, 0);
			const diff = (result.details as { diff?: string } | undefined)?.diff;
			if (!diff) return new Text(dot + theme.fg("success", "written"), 0, 0);
			const { add, del } = diffStats(diff);
			let text = dot + theme.fg("success", `+${add}`);
			// del === 0 means the file did not previously exist (or was pure appends).
			if (del > 0) text += theme.fg("dim", "/") + theme.fg("error", `-${del}`);
			if (expanded) text += renderDiffLines(diff, theme);
			return new Text(text, 0, 0);
		},
	});

	// --- find / grep / ls: generic "N results" summary ----------------------
	const tools = getBuiltInTools(process.cwd());

	pi.registerTool({
		name: "find",
		label: "find",
		description: tools.find.description,
		parameters: tools.find.parameters,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			return getBuiltInTools(ctx.cwd).find.execute(toolCallId, params, signal, onUpdate);
		},
		renderCall: (args, theme) => renderSearchCall("find", args, theme),
		renderResult: renderSearchResult,
	});

	pi.registerTool({
		name: "grep",
		label: "grep",
		description: tools.grep.description,
		parameters: tools.grep.parameters,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			return getBuiltInTools(ctx.cwd).grep.execute(toolCallId, params, signal, onUpdate);
		},
		renderCall: (args, theme) => renderSearchCall("grep", args, theme),
		renderResult: renderSearchResult,
	});

	pi.registerTool({
		name: "ls",
		label: "ls",
		description: tools.ls.description,
		parameters: tools.ls.parameters,
		async execute(toolCallId, params, signal, onUpdate, ctx) {
			return getBuiltInTools(ctx.cwd).ls.execute(toolCallId, params, signal, onUpdate);
		},
		renderCall: (args, theme) => renderSearchCall("ls", args, theme),
		renderResult: renderSearchResult,
	});
}

function renderSearchCall(name: string, args: Record<string, unknown>, theme: Theme): Text {
	const parts = Object.entries(args)
		.filter(([, v]) => v !== undefined && v !== null && v !== "")
		.map(([k, v]) => `${k}=${typeof v === "string" ? shortenPath(v) : v}`);
	return new Text(
		theme.fg("toolTitle", theme.bold(`${name} `)) + theme.fg("accent", parts.join(" ")),
		0,
		0,
	);
}

function renderSearchResult(
	result: { content: Array<{ type: string; text?: string }> },
	{ expanded, isPartial }: { expanded: boolean; isPartial: boolean },
	theme: Theme,
	ctx: { invalidate: () => void; state: SpinState; isError?: boolean },
): Text {
	const dot = marker(theme, ctx, isPartial);
	if (isPartial) return new Text(dot + theme.fg("warning", "searching..."), 0, 0);
	const output = textOf(result);
	const trimmed = output.trim();
	if (!trimmed || /^no (matches|results|files)/i.test(trimmed)) {
		return new Text(dot + theme.fg("dim", "no results"), 0, 0);
	}
	const lineCount = trimmed.split("\n").length;
	let text = dot + theme.fg("success", `${lineCount} results`);
	if (expanded) text += preview(output, theme);
	return new Text(text, 0, 0);
}
