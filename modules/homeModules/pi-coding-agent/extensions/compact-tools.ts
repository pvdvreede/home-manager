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

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	createBashTool,
	createEditTool,
	createFindTool,
	createGrepTool,
	createLsTool,
	createReadTool,
	createWriteTool,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { homedir } from "os";

const PREVIEW_LINES = 20;
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

type Theme = { fg: (slot: string, s: string) => string };

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
			const exitMatch = output.match(/exit code: (\d+)/);
			const exitCode = exitMatch ? parseInt(exitMatch[1], 10) : null;
			const ok = exitCode === null || exitCode === 0;
			const dot = marker(theme, ctx, isPartial, ok);
			if (isPartial) return new Text(dot + theme.fg("warning", "running..."), 0, 0);
			const lineCount = output.split("\n").filter((l) => l.trim()).length;
			let text = dot;
			text += ok ? theme.fg("success", "done") : theme.fg("error", `exit ${exitCode}`);
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
			const diff = result.details?.diff as string | undefined;
			if (!diff) return new Text(dot + theme.fg("success", "applied"), 0, 0);
			const diffLines = diff.split("\n");
			let add = 0;
			let del = 0;
			for (const line of diffLines) {
				if (line.startsWith("+") && !line.startsWith("+++")) add++;
				else if (line.startsWith("-") && !line.startsWith("---")) del++;
			}
			let text = dot + theme.fg("success", `+${add}`) + theme.fg("dim", "/") + theme.fg("error", `-${del}`);
			if (expanded) {
				const shown = diffLines.slice(0, PREVIEW_LINES);
				for (const line of shown) {
					if (line.startsWith("+") && !line.startsWith("+++")) text += `\n${theme.fg("success", line)}`;
					else if (line.startsWith("-") && !line.startsWith("---")) text += `\n${theme.fg("error", line)}`;
					else text += `\n${theme.fg("dim", line)}`;
				}
				if (diffLines.length > PREVIEW_LINES) {
					text += `\n${theme.fg("muted", `... ${diffLines.length - PREVIEW_LINES} more diff lines`)}`;
				}
			}
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
			return getBuiltInTools(ctx.cwd).write.execute(toolCallId, params, signal, onUpdate);
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
		renderResult(result, { isPartial }, theme, ctx) {
			const output = textOf(result);
			const errored = output.startsWith("Error") || ctx.isError === true;
			const dot = marker(theme, ctx, isPartial, !errored);
			if (isPartial) return new Text(dot + theme.fg("warning", "writing..."), 0, 0);
			if (errored) return new Text(dot + theme.fg("error", output.split("\n")[0] || "failed"), 0, 0);
			return new Text(dot + theme.fg("success", "written"), 0, 0);
		},
	});

	// --- find / grep / ls: generic "N results" summary ----------------------
	for (const name of ["find", "grep", "ls"] as const) {
		const original = getBuiltInTools(process.cwd())[name];
		pi.registerTool({
			name,
			label: name,
			description: original.description,
			parameters: original.parameters,
			async execute(toolCallId, params, signal, onUpdate, ctx) {
				return getBuiltInTools(ctx.cwd)[name].execute(toolCallId, params, signal, onUpdate);
			},
			renderCall(args, theme) {
				const parts = Object.entries(args)
					.filter(([, v]) => v !== undefined && v !== null && v !== "")
					.map(([k, v]) => `${k}=${typeof v === "string" ? shortenPath(v) : v}`);
				return new Text(
					theme.fg("toolTitle", theme.bold(`${name} `)) + theme.fg("accent", parts.join(" ")),
					0,
					0,
				);
			},
			renderResult(result, { expanded, isPartial }, theme, ctx) {
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
			},
		});
	}
}
