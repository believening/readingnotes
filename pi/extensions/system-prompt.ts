/**
 * /system-prompt command for pi
 *
 * Prints the current system prompt to a file and notifies the path, with a
 * rough token estimate. Useful for understanding what extensions/skills/tools
 * are contributing to the LLM context window.
 *
 * Why a file and not the TUI directly?
 *   System prompts are routinely 5-20KB. notify() truncates / wraps badly.
 *   Writing to a tmp file lets you `less /tmp/pi-system-prompt.txt` or open
 *   it in your editor.
 *
 * Usage:
 *   /system-prompt           write & open path
 *   /system-prompt summary   print just a per-section size summary inline
 *   /system-prompt tools     list the active tools with descriptions
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

const OUT_PATH = path.join(os.tmpdir(), "pi-system-prompt.txt");

function estimateTokens(s: string): number {
	// Cheap heuristic. Real tokenizer would need tiktoken/anthropic SDK.
	// ~4 chars per token is the standard rule of thumb for English.
	return Math.ceil(s.length / 4);
}

function fmtBytes(n: number): string {
	if (n < 1024) return `${n}B`;
	return `${(n / 1024).toFixed(1)}KB`;
}

function sectionSizes(prompt: string): string[] {
	// Pi's default system prompt uses `## Heading` blocks. Split and measure.
	const parts = prompt.split(/\n(?=## )/);
	const lines: string[] = [];
	for (const part of parts) {
		const firstLine = part.split("\n", 1)[0].trim();
		const heading = firstLine.startsWith("## ") ? firstLine.slice(3) : "(preamble)";
		const chars = part.length;
		const tokens = estimateTokens(part);
		lines.push(
			`  ${heading.padEnd(28)} ${String(chars).padStart(6)} chars  ~${String(tokens).padStart(5)} tokens`,
		);
	}
	return lines;
}

export default function systemPromptCmd(pi: ExtensionAPI) {
	pi.registerCommand("system-prompt", {
		description:
			"Dump the current system prompt to a file. Subcommands: summary | tools",
		getArgumentCompletions: (prefix) => {
			const opts = [
				{ value: "summary", label: "summary  — print per-section size summary" },
				{ value: "tools", label: "tools    — list active tools with descriptions" },
			];
			const f = opts.filter((o) => o.value.startsWith(prefix.toLowerCase()));
			return f.length ? f : null;
		},
		handler: async (args, ctx) => {
			const mode = args.trim().toLowerCase();
			const prompt = ctx.getSystemPrompt();
			const chars = prompt.length;
			const tokens = estimateTokens(prompt);

			if (mode === "tools") {
				// getActiveTools() returns string[] of names; getAllTools() returns full objects.
				const activeNames: string[] = (pi as any).getActiveTools?.() ?? [];
				const all: any[] = (pi as any).getAllTools?.() ?? [];
				const activeSet = new Set(activeNames);
				const tools = all.filter((t) => activeSet.has(t.name));

				let totalDesc = 0;
				let totalParams = 0;
				let totalGuide = 0;

				const lines: string[] = [
					`Active tools: ${tools.length} of ${all.length} registered`,
					"",
				];
				// Group by source for readability.
				const groups = new Map<string, any[]>();
				for (const t of tools) {
					const src = t.sourceInfo?.source ?? "?";
					if (!groups.has(src)) groups.set(src, []);
					groups.get(src)!.push(t);
				}
				const sourceOrder = ["builtin", "sdk", "extension", "?"];
				const sortedSources = [...groups.keys()].sort(
					(a, b) => (sourceOrder.indexOf(a) + 99) - (sourceOrder.indexOf(b) + 99),
				);

				for (const src of sortedSources) {
					lines.push(`--- ${src} ---`);
					for (const t of groups.get(src)!) {
						const desc = (t.description ?? "").replace(/\s+/g, " ").trim();
						const paramsStr = JSON.stringify(t.parameters ?? {});
						const guideStr = (t.promptGuidelines ?? []).join(" ");
						const dtok = estimateTokens(desc);
						const ptok = estimateTokens(paramsStr);
						const gtok = estimateTokens(guideStr);
						totalDesc += dtok;
						totalParams += ptok;
						totalGuide += gtok;
						const total = dtok + ptok + gtok;
						lines.push(
							`${t.name.padEnd(20)} total ~${String(total).padStart(4)}t  ` +
								`(desc ${dtok}t / params ${ptok}t / guide ${gtok}t)`,
						);
						if (desc) {
							lines.push(
								`   "${desc.slice(0, 120)}${desc.length > 120 ? "…" : ""}"`,
							);
						}
					}
					lines.push("");
				}

				const grand = totalDesc + totalParams + totalGuide;
				lines.push(`Totals: ~${grand}t  (desc ${totalDesc}t / params ${totalParams}t / guide ${totalGuide}t)`);
				lines.push("Note: this is what's sent via the provider's tools field, separate from system prompt.");
				ctx.ui.notify(lines.join("\n"), "info");
				return;
			}

			if (mode === "summary") {
				const lines = [
					`System prompt: ${fmtBytes(chars)} (${chars} chars), ~${tokens} tokens`,
					"",
					"By section:",
					...sectionSizes(prompt),
				];
				ctx.ui.notify(lines.join("\n"), "info");
				return;
			}

			// Default: dump to file.
			fs.writeFileSync(OUT_PATH, prompt, "utf8");
			ctx.ui.notify(
				`System prompt written: ${OUT_PATH}\n` +
					`Size: ${fmtBytes(chars)} (~${tokens} tokens)\n` +
					`View with:  less ${OUT_PATH}\n` +
					`Subcommands: /system-prompt summary | tools`,
				"info",
			);
		},
	});
}
