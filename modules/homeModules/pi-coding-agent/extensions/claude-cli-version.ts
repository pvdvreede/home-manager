/**
 * Raise the spoofed Claude Code version sent by pi-web-search.
 *
 * pi-web-search@1.7.0 hardcodes `user-agent: claude-cli/2.1.251` for Anthropic
 * OAuth requests (src/providers/anthropic.ts). Anthropic rejects that for newer
 * models (claude-opus-5-5 needs >= 2.1.280). Pi's own client already sends a
 * newer version, so only older values are rewritten.
 *
 * TODO: remove once pi-web-search ships a fix.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MIN_VERSION = "2.1.280";
const UA_RE = /^claude-cli\/(\d+)\.(\d+)\.(\d+)/;

function tooOld(ua: string): boolean {
	const m = UA_RE.exec(ua);
	if (!m) return false;
	const min = MIN_VERSION.split(".").map(Number);
	const cur = [Number(m[1]), Number(m[2]), Number(m[3])];
	for (let i = 0; i < 3; i++) {
		if (cur[i] !== min[i]) return cur[i] < min[i];
	}
	return false;
}

export default function (_pi: ExtensionAPI) {
	const g = globalThis as { fetch: typeof fetch; __claudeCliPatched?: boolean };
	if (g.__claudeCliPatched) return;
	g.__claudeCliPatched = true;
	const original = g.fetch;

	g.fetch = ((input: RequestInfo | URL, init?: RequestInit) => {
		const h = init?.headers;
		if (h && !Array.isArray(h)) {
			if (h instanceof Headers) {
				const ua = h.get("user-agent");
				if (ua && tooOld(ua)) {
					const next = new Headers(h);
					next.set("user-agent", `claude-cli/${MIN_VERSION}`);
					init = { ...init, headers: next };
				}
			} else {
				const rec = h as Record<string, string>;
				const key = Object.keys(rec).find((k) => k.toLowerCase() === "user-agent");
				if (key && tooOld(rec[key])) {
					init = { ...init, headers: { ...rec, [key]: `claude-cli/${MIN_VERSION}` } };
				}
			}
		}
		return original(input, init);
	}) as typeof fetch;
}
