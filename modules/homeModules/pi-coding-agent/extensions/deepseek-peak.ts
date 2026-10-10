/**
 * DeepSeek peak / off-peak indicator
 *
 * When the active model is served by DeepSeek, the built-in footer is replaced
 * with one that renders a green "off-peak" or red "peak" badge (plus a countdown
 * to the next switch) immediately to the left of the provider/model name.
 *
 * Peak billing is anchored to UTC: 01:00-04:00 and 06:00-10:00 UTC, Monday-Friday
 * (Beijing time), excluding Chinese public holidays and weekends (off-peak in
 * full). Using UTC/Beijing fields means the badge is correct in any local time
 * zone, including AEDT (UTC+11).
 *
 * Schedule source: https://api-docs.deepseek.com/quick_start/pricing/
 * Refresh CHINA_HOLIDAY_RANGES once a year when the State Council publishes the
 * next year's dates.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { isAbsolute, relative, resolve, sep } from "node:path";

const H = 3600_000; // one hour in ms

/** Peak windows in UTC hours [start, end), applied on Beijing weekdays. */
const PEAK_WINDOWS: Array<[number, number]> = [
	[1, 4],
	[6, 10],
];

/**
 * Chinese public holidays (official State Council dates) are off-peak in full.
 * Only the officially released year is bundled; add the next year once published.
 * Make-up workdays (调休) need no entry: they always land on a Sat/Sun, which is
 * off-peak anyway, so only weekday holidays can change a decision.
 */
const CHINA_HOLIDAY_RANGES: Array<[string, string]> = [
	["2026-01-01", "2026-01-03"], // New Year
	["2026-02-15", "2026-02-23"], // Spring Festival
	["2026-04-04", "2026-04-06"], // Ching Ming
	["2026-05-01", "2026-05-05"], // Labour Day
	["2026-06-19", "2026-06-21"], // Dragon Boat
	["2026-09-25", "2026-09-27"], // Mid-Autumn
	["2026-10-01", "2026-10-07"], // National Day
];

// Beijing calendar-day keys ("YYYY-MM-DD"), expanded once at load (UTC math, no DST).
const HOLIDAY_DAYS = new Set<string>();
for (const [from, to] of CHINA_HOLIDAY_RANGES) {
	const end = Date.parse(`${to}T00:00:00Z`);
	for (let t = Date.parse(`${from}T00:00:00Z`); t <= end; t += 24 * H) {
		HOLIDAY_DAYS.add(new Date(t).toISOString().slice(0, 10));
	}
}

/** True when DeepSeek bills off-peak at `date`. */
export function isOffPeak(date: Date): boolean {
	const bj = new Date(date.getTime() + 8 * H); // Beijing time (UTC+8)
	const dow = bj.getUTCDay();
	if (dow === 0 || dow === 6) return true; // Beijing weekend
	if (HOLIDAY_DAYS.has(bj.toISOString().slice(0, 10))) return true;
	const h = date.getUTCHours();
	return !PEAK_WINDOWS.some(([start, end]) => h >= start && h < end);
}

/** First instant where the peak/off-peak state flips, or null if none within the scan window. */
export function nextPriceChange(date: Date): Date | null {
	const now = date.getTime();
	const day = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate());
	const state = isOffPeak(date);
	const candidates: number[] = [];
	// Spring Festival is ~9.5 contiguous off-peak days, so scan three weeks ahead.
	for (let i = 0; i < 21; i++) {
		const d = day + i * 24 * H;
		for (const h of [1, 4, 6, 10]) candidates.push(d + h * H);
		candidates.push(d - 8 * H); // Beijing midnight (holiday boundaries)
	}
	for (const t of candidates.sort((a, b) => a - b)) {
		if (t > now && isOffPeak(new Date(t + 1)) !== state) return new Date(t);
	}
	return null;
}

function formatHM(m: number): string {
	if (m <= 0) return "";
	if (m < 60) return `${m}m`;
	const h = Math.floor(m / 60);
	const min = m % 60;
	return min === 0 ? `${h}h` : `${h}h${String(min).padStart(2, "0")}m`;
}

/** Time until the next switch: "8d22h", "27h", "1h30m", "45m". */
export function formatCountdown(date: Date): string {
	const next = nextPriceChange(date);
	if (!next) return "";
	const m = Math.ceil((next.getTime() - date.getTime()) / 60000);
	if (m >= 48 * 60) return `${Math.floor(m / 1440)}d${formatHM(m % 1440)}`;
	return formatHM(m);
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function formatCwd(cwd: string): string {
	const home = process.env.HOME || process.env.USERPROFILE;
	if (!home) return cwd;
	const resolvedCwd = resolve(cwd);
	const resolvedHome = resolve(home);
	const rel = relative(resolvedHome, resolvedCwd);
	const inside = rel === "" || (rel !== ".." && !rel.startsWith(`..${sep}`) && !isAbsolute(rel));
	if (!inside) return cwd;
	return rel === "" ? "~" : `~${sep}${rel}`;
}

function sanitizeStatusText(text: string): string {
	return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

// --- footer state -----------------------------------------------------------

let currentCtx: ExtensionContext | undefined;
let currentTui: { requestRender(): void } | undefined;

/** Badge text/color for the current instant (green off-peak, red peak). */
function badge(theme: { fg: (color: any, text: string) => string }, now: Date): string {
	const offPeak = isOffPeak(now);
	const cd = formatCountdown(now);
	const label = offPeak ? "off-peak" : "peak";
	return theme.fg(offPeak ? "success" : "error", cd ? `${label} ${cd}` : label);
}

function renderFooter(
	width: number,
	theme: { fg: (color: any, text: string) => string },
	footerData: { getGitBranch(): string | null; getExtensionStatuses(): ReadonlyMap<string, string>; getAvailableProviderCount(): number },
): string[] {
	const ctx = currentCtx;
	if (!ctx) return [];

	// pwd + git branch + session name
	let pwd = formatCwd(ctx.sessionManager.getCwd());
	const branch = footerData.getGitBranch();
	if (branch) pwd += ` (${branch})`;
	const sessionName = ctx.sessionManager.getSessionName();
	if (sessionName) pwd += ` • ${sessionName}`;

	// cumulative usage across all entries
	const totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
	const addUsage = (u: any) => {
		if (!u) return;
		totals.input += u.input ?? 0;
		totals.output += u.output ?? 0;
		totals.cacheRead += u.cacheRead ?? 0;
		totals.cacheWrite += u.cacheWrite ?? 0;
		totals.cost += u.cost?.total ?? 0;
	};
	for (const entry of ctx.sessionManager.getEntries() as any[]) {
		if (entry.type === "usage") addUsage(entry.usage);
		else if (entry.type === "message") {
			const msg = entry.message;
			if (msg.role === "assistant") addUsage(msg.usage);
			else if (msg.role === "toolResult") addUsage(msg.usage);
		} else if ((entry.type === "compaction" || entry.type === "branch_summary") && entry.usage) {
			addUsage(entry.usage);
		}
	}

	const parts: string[] = [];
	if (totals.input) parts.push(`↑${formatTokens(totals.input)}`);
	if (totals.output) parts.push(`↓${formatTokens(totals.output)}`);
	if (totals.cacheRead) parts.push(`R${formatTokens(totals.cacheRead)}`);
	if (totals.cacheWrite) parts.push(`W${formatTokens(totals.cacheWrite)}`);
	if (totals.cost) parts.push(`$${totals.cost.toFixed(3)}`);

	const usage = ctx.getContextUsage();
	const contextWindow = usage?.contextWindow ?? (ctx.model as any)?.contextWindow ?? 0;
	const percent = usage?.percent;
	const ctxText = `${percent != null ? `${percent.toFixed(1)}%` : "?"}/${formatTokens(contextWindow)}`;
	if (percent != null && percent > 90) parts.push(theme.fg("error", ctxText));
	else if (percent != null && percent > 70) parts.push(theme.fg("warning", ctxText));
	else parts.push(ctxText);

	let left = parts.join(" ");
	const leftWidth = visibleWidth(left);
	if (leftWidth > width) left = truncateToWidth(left, width, "...");

	// right side: badge + (provider) + model + thinking level
	const model = ctx.model as any;
	const modelName = model?.id || "no-model";
	let right = modelName;
	if (model?.reasoning) {
		const level = ctx.thinkingLevel || "off";
		right = `${modelName} • ${level}`;
	}
	if (footerData.getAvailableProviderCount() > 1 && model) {
		right = `(${model.provider}) ${right}`;
	}
	let badgeText = "";
	if (model?.provider === "deepseek") badgeText = badge(theme, new Date());
	const badgeWidth = badgeText ? visibleWidth(badgeText) + 1 : 0;
	const rightWidth = badgeWidth + visibleWidth(right);

	const minPadding = 2;
	let statsLine: string;
	if (leftWidth + rightWidth + minPadding <= width) {
		const padding = " ".repeat(width - leftWidth - rightWidth);
		statsLine = theme.fg("dim", left) + padding + (badgeText ? `${badgeText} ` : "") + theme.fg("dim", right);
	} else {
		const available = width - leftWidth - minPadding;
		if (available > badgeWidth + 3) {
			const truncated = truncateToWidth(right, available - badgeWidth, "");
			const truncatedWidth = badgeWidth + visibleWidth(truncated);
			const padding = " ".repeat(Math.max(0, width - leftWidth - truncatedWidth));
			statsLine = theme.fg("dim", left) + padding + (badgeText ? `${badgeText} ` : "") + theme.fg("dim", truncated);
		} else {
			statsLine = theme.fg("dim", left);
		}
	}

	const lines = [truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")), statsLine];

	const statuses = footerData.getExtensionStatuses();
	if (statuses.size > 0) {
		const statusLine = Array.from(statuses.entries())
			.sort(([a], [b]) => a.localeCompare(b))
			.map(([, text]) => sanitizeStatusText(text))
			.join(" ");
		lines.push(truncateToWidth(statusLine, width, theme.fg("dim", "...")));
	}

	return lines;
}

function applyFooter(ctx: ExtensionContext): void {
	currentCtx = ctx;
	if (ctx.mode !== "tui") return;

	if ((ctx.model as any)?.provider === "deepseek") {
		ctx.ui.setFooter((tui, theme, footerData) => {
			currentTui = tui;
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());
			return {
				dispose() {
					unsubscribe();
				},
				invalidate() {},
				render(width: number) {
					return renderFooter(width, theme, footerData);
				},
			};
		});
	} else {
		ctx.ui.setFooter(undefined);
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		applyFooter(ctx);
	});

	pi.on("model_select", async (_event, ctx) => {
		applyFooter(ctx);
	});

	// Refresh the badge each time the agent finishes a task.
	pi.on("agent_end", async (_event, ctx) => {
		currentCtx = ctx;
		currentTui?.requestRender();
	});

	pi.on("thinking_level_select", async (_event, ctx) => {
		currentCtx = ctx;
		currentTui?.requestRender();
	});

	pi.on("session_shutdown", async () => {
		currentTui = undefined;
	});
}
