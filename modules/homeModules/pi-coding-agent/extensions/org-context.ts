/**
 * GitHub org context
 *
 * When the cwd is a git repo whose `origin` remote points at github.com, this
 * extension looks for `<root>/<org>/` and injects every `*.md` file directly
 * in it (not recursive) as a context file, the same way Pi injects an
 * `AGENTS.md`.
 *
 * Root: `$PI_ORG_CONTEXT_DIR`, else `<agent-dir>/orgs` (usually
 * `~/.pi/agent/orgs`). The root lives outside Nix; it can be a symlink to
 * another repo. The org folder name is matched case-insensitively. Files are
 * injected in name order, with `AGENTS.md` first.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import { type ExtensionAPI, getAgentDir } from "@earendil-works/pi-coding-agent";

interface ContextFile {
	path: string;
	content: string;
}

function orgFromRemote(url: string): string | undefined {
	const match =
		url.match(/^(?:[^@/]+@)?github\.com:([^/]+)\//i) ??
		url.match(/^(?:ssh|https?|git):\/\/(?:[^@/]+@)?github\.com(?::\d+)?\/([^/]+)\//i);
	return match?.[1];
}

function findOrgDir(root: string, org: string): string | undefined {
	let entries: fs.Dirent[];
	try {
		entries = fs.readdirSync(root, { withFileTypes: true });
	} catch {
		return undefined;
	}
	const wanted = org.toLowerCase();
	const entry = entries.find((e) => e.name.toLowerCase() === wanted);
	if (!entry) return undefined;
	const dir = path.join(root, entry.name);
	try {
		return fs.statSync(dir).isDirectory() ? dir : undefined;
	} catch {
		return undefined;
	}
}

function findMarkdown(dir: string): string[] {
	const out: string[] = [];
	let entries: fs.Dirent[];
	try {
		entries = fs.readdirSync(dir, { withFileTypes: true });
	} catch {
		return out;
	}
	for (const entry of entries) {
		if (!entry.name.toLowerCase().endsWith(".md")) continue;
		const full = path.join(dir, entry.name);
		try {
			if (fs.statSync(full).isFile()) out.push(full);
		} catch {}
	}
	return out;
}

function loadOrgFiles(orgDir: string): ContextFile[] {
	const entry = path.join(orgDir, "AGENTS.md").toLowerCase();
	return findMarkdown(orgDir)
		.sort((a, b) => {
			if (a.toLowerCase() === entry) return -1;
			if (b.toLowerCase() === entry) return 1;
			return a.localeCompare(b);
		})
		.flatMap((file) => {
			try {
				return [{ path: file, content: fs.readFileSync(file, "utf8") }];
			} catch {
				return [];
			}
		});
}

export default function orgContext(pi: ExtensionAPI): void {
	let files: ContextFile[] = [];

	pi.on("session_start", async (_event, ctx) => {
		files = [];
		const result = await pi.exec("git", ["remote", "get-url", "origin"], { cwd: ctx.cwd, timeout: 5000 });
		if (result.code !== 0) return;
		const org = orgFromRemote(result.stdout.trim());
		if (!org) return;
		const root = process.env.PI_ORG_CONTEXT_DIR || path.join(getAgentDir(), "orgs");
		const orgDir = findOrgDir(root, org);
		if (!orgDir) return;
		files = loadOrgFiles(orgDir);
		if (files.length > 0) ctx.ui.notify(`Org context: ${org} (${files.length} file(s))`, "info");
	});

	pi.on("before_agent_start", async (event) => {
		if (files.length === 0) return;
		const contextFiles = event.systemPromptOptions.contextFiles;
		const known = new Set(contextFiles.map((f) => f.path));
		for (const file of files) {
			if (!known.has(file.path)) contextFiles.push({ ...file });
		}
	});
}
