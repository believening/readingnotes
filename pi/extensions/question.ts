/**
 * Question — an opencode-style, platform-agnostic interactive question tool for pi.
 *
 * Positioning (mirrors opencode): this extension is *just* a tool. It does not
 * encode any interview / spec workflow into the system prompt. Whether the LLM
 * asks zero, one, or many questions, serially or as it works, is the model's
 * call. Opinions about "how to interview" belong in AGENTS.md / skills, not here.
 *
 * One tool call asks ONE question (pi's native serial-chat rhythm); it states:
 *   - concrete options, each with a `description` (explicit trade-offs)
 *   - optional `recommended` marker (structural) — always keep the recommended
 *     option first and add "(Recommended)" to the label too, per cross-tool
 *     community convention, so the signal survives even if this field is dropped
 *   - `multiple` to allow multi-select
 *   - `custom` (default true) — when true a "Type something." row is appended,
 *     so never include an "Other" option yourself
 * - optional short `header` for compact rendering/navigation
 *
 * Result text is normalised to `"question"="label1, label2"` (Unanswered if
 * empty) and ends with a Continue hint, so the LLM reliably knows how to proceed.
 *
 * Modes:
 *   - tui      — full custom three-mode UI (options / edit / reject)
 *   - rpc      — graceful fallback to ctx.ui.select + ctx.ui.input (custom UI is
 *                unavailable in RPC), so headless / integrations still work
 *   - json/print — non-interactive; returns a non-fatal skip string
 *
 * Robustness:
 *   - Honours `signal` (abort) so a cancelled turn doesn't strand a hanging
 *     prompt; mirrors opencode's addFinalizer guarantee.
 *   - Reject-with-reason is fed back so the LLM can reformulate (from AUQ).
 *
 * Load: place this file in .pi/extensions/ (project) or ~/.pi/agent/extensions/
 * (user); it auto-loads in all sessions. The tool is always available.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	Editor,
	type EditorTheme,
	Key,
	matchesKey,
	Text,
	visibleWidth,
	wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface OptionSpec {
	label: string;
	description?: string;
	recommended?: boolean;
}

type DisplayOption = OptionSpec & { isOther?: boolean };

interface QuestionDetails {
	question: string;
	header?: string;
	options: string[];
	recommended: string[];
	multiple: boolean;
	custom: boolean;
	answers: string[]; // selected labels; [] means unanswered
	wasCustom?: boolean;
	rejected?: boolean;
	reason?: string;
}

const OptionSchema = Type.Object({
	label: Type.String({ description: "Display text (1–5 words, concise)" }),
	description: Type.Optional(
		Type.String({
			description: "Explanation of the option's trade-off or consequence; shown below the label",
		}),
	),
	recommended: Type.Optional(
		Type.Boolean({
			description:
				"Mark the option you recommend. ALSO: keep it first in the list and suffix its label with \"(Recommended)\" so the signal survives even without this field.",
		}),
	),
});

const QuestionParams = Type.Object({
	question: Type.String({ description: "The complete question to ask" }),
	header: Type.Optional(
		Type.String({ description: "Very short navigation label (max ~30 chars). Optional." }),
	),
	options: Type.Array(OptionSchema, {
		description:
			"Concrete choices. Give each a `description` so the trade-off is explicit. " +
			"Do NOT include an \"Other\" option — the tool adds a custom-input row automatically when `custom` is true (default).",
	}),
	multiple: Type.Optional(
		Type.Boolean({ description: "Allow selecting more than one option. Default: false (single-select)." }),
	),
	custom: Type.Optional(
		Type.Boolean({
			description: "Allow a free-form \"Type something.\" answer (default: true). Set false for pure multiple-choice.",
		}),
	),
});

// Build the normalised k=v result text fed back to the LLM.
function formatResultText(question: string, answers: string[] | null): string {
	const value = answers && answers.length ? answers.join(", ") : "Unanswered";
	return `"${question}"="${value}". You can now continue with the user's answers in mind.`;
}

export default function questionTool(pi: ExtensionAPI) {
	pi.registerTool({
		name: "question",
		label: "Question",
		description:
			"Ask the user ONE question and wait for the answer. Use this whenever you need clarification, a decision, or missing info — do NOT just print the question as plain text. " +
			"Provide concrete options each with a `description`. Mark the option you recommend with `recommended: true` AND list it first with \"(Recommended)\" in its label. " +
			"A custom \"Type something.\" answer is added automatically (default); do not include an \"Other\" option yourself. Answers come back as selected labels.",
		promptSnippet: "Ask the user an interactive clarifying question",
		parameters: QuestionParams,
		executionMode: "sequential",

		async execute(_toolCallId, params, signal, _onUpdate, ctx) {
			const multiple = params.multiple === true;
			const custom = params.custom !== false; // default true
			const baseOptions = params.options ?? [];
			const recommendedLabels = baseOptions.filter((o) => o.recommended).map((o) => o.label);

			const makeDetails = (partial: Partial<QuestionDetails>): QuestionDetails => ({
				question: params.question,
				header: params.header,
				options: baseOptions.map((o) => o.label),
				recommended: recommendedLabels,
				multiple,
				custom,
				answers: [],
				...partial,
			});

			// Guard 1: abort already requested before we even prompt.
			if (signal?.aborted) {
				return {
					content: [
						{ type: "text", text: "Question skipped: the turn was cancelled before the prompt was shown." },
					],
					details: makeDetails({}),
				};
			}

			// Guard 2: no interactive frontend at all (json / print modes).
			if (!ctx.hasUI) {
				return {
					content: [{ type: "text", text: formatResultText(params.question, null) }],
					details: makeDetails({ answers: [] }),
				};
			}

			// RPC mode: ctx.ui.custom() is unavailable, but select/input work via JSON.
			// Degrade to a single-shot select (+ optional input for "Other"/write-in).
			if (ctx.mode === "rpc") {
				const choice = await ctx.ui.select(params.question, baseOptions.map((o) => o.label));
				// User dismissed / cancelled entirely.
				if (choice === undefined) {
					return {
						content: [{ type: "text", text: "User dismissed the question." }],
						details: makeDetails({ answers: [] }),
					};
				}
				// If custom input is allowed, offer a free-form follow-up; empty = use selection as-is.
				if (custom) {
					const extra = await ctx.ui.input("Type a custom answer, or Enter to keep your selection");
					if (extra && extra.trim()) {
						return {
							content: [{ type: "text", text: formatResultText(params.question, [extra.trim()]) }],
							details: makeDetails({ answers: [extra.trim()], wasCustom: true }),
						};
					}
				}
				return {
					content: [{ type: "text", text: formatResultText(params.question, [choice]) }],
					details: makeDetails({ answers: [choice] }),
				};
			}

			// TUI mode: rich three-mode custom UI.
			const displayOptions: DisplayOption[] = [...baseOptions];
			if (custom) {
				displayOptions.push({ label: "Type something.", isOther: true });
			}

			const result = await ctx.ui.custom<
				{ answers: string[]; wasCustom: boolean } | { rejected: true; reason: string } | null
			>((tui, theme, _kb, done) => {
				const selected = new Set<number>();
				let optionIndex = 0;
				let mode: "options" | "edit" | "reject" = "options";
				let cachedLines: string[] | undefined;

				const editorTheme: EditorTheme = {
					borderColor: (s) => theme.fg("accent", s),
					selectList: {
						selectedPrefix: (t) => theme.fg("accent", t),
						selectedText: (t) => theme.fg("accent", t),
						description: (t) => theme.fg("muted", t),
						scrollInfo: (t) => theme.fg("dim", t),
						noMatch: (t) => theme.fg("warning", t),
					},
				};
				const editor = new Editor(tui, editorTheme);

				editor.onSubmit = (value) => {
					const trimmed = value.trim();
					if (mode === "reject") {
						done(trimmed ? { rejected: true, reason: trimmed } : null);
						return;
					}
					// "Type something" free-form input
					if (trimmed) {
						done({ answers: [trimmed], wasCustom: true });
					} else {
						mode = "options";
						editor.focused = false;
						editor.setText("");
						refresh();
					}
				};

				function refresh() {
					cachedLines = undefined;
					tui.requestRender();
				}

				function handleInput(data: string) {
					if (mode === "edit" || mode === "reject") {
						if (matchesKey(data, Key.escape)) {
							mode = "options";
							editor.focused = false;
							editor.setText("");
							refresh();
							return;
						}
						editor.handleInput(data);
						refresh();
						return;
					}

					// options mode — accept recommended (single-select only)
					if (data.toLowerCase() === "r" && !multiple) {
						const recIdx = baseOptions.findIndex((o) => o.recommended);
						if (recIdx >= 0) {
							done({ answers: [baseOptions[recIdx].label], wasCustom: false });
						}
						return;
					}

					if (matchesKey(data, Key.up)) {
						optionIndex = Math.max(0, optionIndex - 1);
						refresh();
						return;
					}
					if (matchesKey(data, Key.down)) {
						optionIndex = Math.min(displayOptions.length - 1, optionIndex + 1);
						refresh();
						return;
					}

					if (matchesKey(data, Key.space) && multiple) {
						const opt = displayOptions[optionIndex];
						if (opt && !opt.isOther) {
							if (selected.has(optionIndex)) selected.delete(optionIndex);
							else selected.add(optionIndex);
							refresh();
						}
						return;
					}

					if (matchesKey(data, Key.enter)) {
						const opt = displayOptions[optionIndex];
						if (opt?.isOther) {
							mode = "edit";
							// Mark the editor focused so it emits the hardware-cursor marker,
							// letting the TUI position the (IME) cursor at the caret.
							editor.focused = true;
							editor.setText("");
							refresh();
							return;
						}
						if (multiple) {
							// Enter commits the current selection set (option under cursor toggled as well)
							if (opt && !selected.has(optionIndex)) selected.add(optionIndex);
							const chosen = [...selected]
								.sort((a, b) => a - b)
								.map((i) => baseOptions[i].label)
								.filter(Boolean);
							if (chosen.length) {
								done({ answers: chosen, wasCustom: false });
							}
							return;
						}
						if (opt) {
							done({ answers: [opt.label], wasCustom: false });
						}
						return;
					}

					if (matchesKey(data, Key.escape)) {
						mode = "reject";
						// Focus the editor so its cursor marker is emitted for correct
						// IME candidate-window placement while typing the reason.
						editor.focused = true;
						editor.setText("");
						refresh();
						return;
					}
				}

				function render(width: number): string[] {
					if (cachedLines) return cachedLines;

					const lines: string[] = [];
					const renderWidth = Math.max(1, width);

					function addWrapped(text: string) {
						lines.push(...wrapTextWithAnsi(text, renderWidth));
					}
					function addWrappedWithPrefix(prefix: string, text: string) {
						const prefixWidth = visibleWidth(prefix);
						if (prefixWidth >= renderWidth) {
							addWrapped(prefix + text);
							return;
						}
						const wrapped = wrapTextWithAnsi(text, renderWidth - prefixWidth);
						const continuationPrefix = " ".repeat(prefixWidth);
						for (let i = 0; i < wrapped.length; i++) {
							lines.push(`${i === 0 ? prefix : continuationPrefix}${wrapped[i]}`);
						}
					}

					lines.push(theme.fg("accent", "─".repeat(renderWidth)));
					addWrappedWithPrefix(" ", theme.fg("text", params.question));
					lines.push("");

					if (mode !== "reject") {
						for (let i = 0; i < displayOptions.length; i++) {
							const opt = displayOptions[i];
							const cursor = i === optionIndex;
							const checked = selected.has(i) ? theme.fg("success", "☑") : theme.fg("dim", "☐");
							const prefix = multiple
								? `${checked} ${cursor ? theme.fg("accent", ">") : " "}`
								: cursor
									? theme.fg("accent", "> ")
									: "  ";
							const recMark = opt.recommended
								? ` ${theme.fg("success", theme.bold("★ recommended"))}`
								: "";
							const editMark = opt.isOther && mode === "edit" ? " ✎" : "";
							const label = `${i + 1}. ${opt.label}${recMark}${editMark}`;
							const color = cursor || (opt.isOther && mode === "edit") ? "accent" : "text";
							addWrappedWithPrefix(prefix + " ", theme.fg(color, label));
							if (opt.description) {
								addWrappedWithPrefix("     ", theme.fg("muted", opt.description));
							}
						}
					}

					if (mode === "edit") {
						lines.push("");
						addWrappedWithPrefix(" ", theme.fg("muted", "Your answer:"));
						for (const line of editor.render(Math.max(1, renderWidth - 2))) {
							lines.push(` ${line}`);
						}
					} else if (mode === "reject") {
						lines.push("");
						addWrappedWithPrefix(
							" ",
							theme.fg("warning", "Reject this question — tell the agent why (it will reformulate):"),
						);
						for (const line of editor.render(Math.max(1, renderWidth - 2))) {
							lines.push(` ${line}`);
						}
					}

					lines.push("");
					const help =
						mode === "edit"
							? "Enter to submit • Esc back to options"
							: mode === "reject"
								? "Enter to reject with reason (empty = cancel) • Esc to cancel"
								: multiple
									? "↑↓ navigate • Space toggle • Enter submit • Esc reject with reason"
									: "↑↓ navigate • r accept recommended • Enter select • Esc reject with reason";
					addWrappedWithPrefix(" ", theme.fg("dim", help));
					lines.push(theme.fg("accent", "─".repeat(renderWidth)));

					cachedLines = lines;
					return lines;
				}

				return {
					render,
					invalidate: () => {
						cachedLines = undefined;
					},
					handleInput,
				};
			});

			// Plain cancel (Esc at reject stage with empty reason / blank submit)
			if (!result) {
				return {
					content: [{ type: "text", text: "User dismissed the question." }],
					details: makeDetails({ answers: [] }),
				};
			}

			// Reject with reason — fed back so the LLM can reformulate
			if ("rejected" in result) {
				return {
					content: [
						{
							type: "text",
							text: `User REJECTED this question with reason: "${result.reason}". Reconsider your approach and do not repeat the same question.`,
						},
					],
					details: makeDetails({ answers: [], rejected: true, reason: result.reason }),
				};
			}

			return {
				content: [{ type: "text", text: formatResultText(params.question, result.answers) }],
				details: makeDetails({ answers: result.answers, wasCustom: result.wasCustom || undefined }),
			};
		},

		renderCall(args, theme, _context) {
			const tag = args.header
				? theme.fg("dim", ` [${args.header}]`)
				: "";
			let text = theme.fg("toolTitle", theme.bold("question ")) + theme.fg("muted", args.question) + tag;
			const opts = Array.isArray(args.options) ? (args.options as OptionSpec[]) : [];
			if (opts.length) {
				const mode = args.multiple ? "multi" : "single";
				text += `\n${theme.fg("dim", `  Options (${mode}): ${opts.map((o) => o.label).join(", ")}`)}`;
				const recs = opts.filter((o) => o.recommended).map((o) => o.label);
				if (recs.length) {
					text += `\n${theme.fg("success", `  Recommended: ${recs.join(", ")}`)}`;
				}
			}
			return new Text(text, 0, 0);
		},

		renderResult(result, _options, theme, _context) {
			const details = result.details as QuestionDetails | undefined;
			if (!details) {
				const text = result.content[0];
				return new Text(text?.type === "text" ? text.text : "", 0, 0);
			}

			if (details.rejected) {
				const reason = details.reason ? ` — ${details.reason}` : "";
				return new Text(theme.fg("error", "✗ Rejected") + theme.fg("muted", reason), 0, 0);
			}

			if (!details.answers.length) {
				return new Text(theme.fg("warning", "Dismissed"), 0, 0);
			}

			const value = details.answers.join(", ");
			if (details.wasCustom) {
				return new Text(
					theme.fg("success", "✓ ") + theme.fg("muted", "(wrote) ") + theme.fg("accent", value),
					0,
					0,
				);
			}
			const isRecList = details.answers.filter((a) => details.recommended.includes(a));
			const recMark = isRecList.length ? ` ${theme.fg("success", "★")}` : "";
			return new Text(theme.fg("success", "✓ ") + theme.fg("accent", value) + recMark, 0, 0);
		},
	});
}
