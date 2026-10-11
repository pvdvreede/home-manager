/**
 * Thinking Block Border
 *
 * Pi renders thinking blocks as plain italic Markdown with no border, and there
 * is no theme role or component hook for one: `registerMessageRenderer` only
 * covers custom messages, not assistant thinking. The only extension surface
 * that sees thinking content is `registerMarkdownTransformer`, whose context
 * reports `messageType: "assistant-thinking"`.
 *
 * We use it to wrap each thinking block in a Markdown blockquote, which the TUI
 * Markdown renderer draws with a left border bar (`│ `) coloured by
 * `mdQuoteBorder`. The theme sets `mdQuote`/`mdQuoteBorder` cyan to match the
 * thinking tint.
 *
 * Trade-offs:
 * - Only a left border is possible; the TUI has no four-sided box that also
 *   supports multi-block content (tables draw a full box but only render
 *   inline tokens, so code/lists/paragraphs would break).
 * - Blockquote content is restyled from `thinkingText` to `mdQuote`, which is
 *   why the theme tints `mdQuote` cyan too. Normal blockquotes elsewhere in
 *   output therefore share the cyan hue.
 * - Applies only to the expanded thinking view; the collapsed "Thinking..."
 *   label is a separate `Text` node and is unaffected.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerMarkdownTransformer((markdown, context) => {
		if (context.messageType !== "assistant-thinking") return markdown;
		if (markdown.trim().length === 0) return markdown;

		// Prefix every line with `>` so marked parses the whole block as a
		// single blockquote. Blank lines stay a bare `>` (no trailing space).
		const quoted = markdown
			.split("\n")
			.map((line) => (line.length === 0 ? ">" : `> ${line}`))
			.join("\n");

		return `${quoted.trimEnd()}\n`;
	});
}
