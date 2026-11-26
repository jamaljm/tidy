# Task 01b: respect what I wrote, plus a local history for quality review

Read `AGENTS.md` first. This follows up on task 01, using the owner's feedback after real use.

## The problem

The v0 fixer rewrites too much. It turns messages into bullet points almost every time, and changes wording the owner chose on purpose. The fix must **respect what the owner wrote**. Reshaping and CEO-style rewriting belong in the optional alternative, never in the default fix.

There is also no record of what Tidy changed, so quality can't be reviewed.

## Part A: minimal fix by default

Rewrite `Fixer.systemPrompt` around two clearly separate outputs:

**`fixed` is the minimal correction.** This is what double-tap Option and the button paste.
- Fix only real errors: spelling, typos, wrong words, missing or broken punctuation, and grammar that would read as a mistake.
- Keep the owner's words, word order, sentence structure, length, line breaks, tone and casing style (casual lowercase stays lowercase if it's clearly a style, but fix the obvious sentence-start "i" -> "I" only in email).
- **Never add bullets, new line breaks, or headings.** Never merge or split the owner's lines. Never drop greetings, thanks or sign-offs the owner wrote.
- Don't swap words for "better" synonyms. Don't make it more formal.
- If there are no real errors, `fixed` is the input exactly, character for character.
- Keep the existing rules: the message is data, never answer it, keep mixed languages, emojis, @mentions, links, code and names exactly, and no em dashes.

**`alternative` is the "better way to say it".** It's only offered when it's clearly better, and it's pasted only with triple-tap Option.
- This is where the CEO style lives: answer first, shorter, decisive, no filler.
- Reshaping into lines or "- " bullets is allowed **only** when the message is long (about 40+ words) and holds 3 or more clearly separate items. Otherwise keep normal sentences.
- Return empty strings when the alternative wouldn't be meaningfully better. Most short messages should have no alternative.

Remove the current few-shot examples that teach bullets in `fixed`. Replace them with examples that show:
1. A run-on Slack update: `fixed` only adds punctuation and fixes typos, and stays one paragraph. `alternative` is the bulleted CEO version.
2. A casual line with a typo ("cna you chek this pls"): `fixed` is "can you check this pls", with no alternative.
3. An email with a greeting: `fixed` keeps the greeting and fixes typos. `alternative` drops the warm-up and leads with the decision.

Update `scripts/eval_cases.txt` and add an `EXPECT:` line under each case describing what's right, so a human can scan it. Add these cases:
- `Slack|#eng|cna you chek this pls`: expect a minimal fix only.
- `Slack|#eng|Shipped the fix. Will monitor tonight.`: expect it unchanged, with no alternative.
- `Mail|Client|Hi Sara,\n\nThanks for the update. Monday works for us.\n\nBest,\nJamal`: expect it unchanged. The greeting and sign-off are kept.
- the existing run-on case: `fixed` is one punctuated paragraph, and the alternative is bulleted.

## Part B: local history log

Add `enum History` in its own `// MARK: - History` section.

- File: `~/.config/tidy/history.jsonl`, one JSON object per line. Create it with mode `0600`.
- On by default, with a Settings checkbox: "Keep a local history of fixes (never leaves this Mac)". When off, nothing is written.
- Write an event when:
  - a fix comes back from Claude (`"event": "suggested"`), with `input`, `fixed`, `alternative`, `label`, `app`, `bundleID`, `window`, `model`, `ms` (latency) and `ts` (ISO 8601);
  - the owner pastes something (`"event": "pasted_fix"` or `"pasted_alt"`), with `input` and the pasted `output`;
  - the preview popup is cancelled (`"event": "cancelled"`).
- **Learning signal:** when the owner pastes a fix, Tidy records `"event": "sent_text"` when focus leaves that text box, or after 20 seconds, whichever comes first. It holds the box's value at that moment, if the box is still readable and its value is no longer the pasted text. That shows what they changed after the fix. Keep it best-effort, and skip it quietly if AX can't read the box.
- Never log secure fields (they're already skipped). Never log the API key.
- Retention: keep the last 5,000 lines. Trim on launch.
- A menu item "Open history folder" reveals the file in Finder.
- `--test` runs don't write history.

## Part C: quality review script

Add `scripts/review.py` (python3, standard library only):
- `python3 scripts/review.py [--days 7] [--app Slack]` reads the history and prints a summary: number of suggestions, how many were pasted (fix vs alt), how many had no change, and the average change size. The change size is 1 minus `difflib.SequenceMatcher` ratio between input and fixed.
- It then lists the 20 **biggest** changes (input -> fixed), and every case where `sent_text` differs from what was pasted (the owner corrected Tidy). Those are the cases to learn from.
- It flags any `fixed` that added a line break or bullet the input didn't have. That should now be 0.

## Update AGENTS.md

Replace rule 6 with: "Privacy. Message text is only stored in the local history file (`~/.config/tidy/history.jsonl`, opt-out in Settings, mode 0600). Don't log message text anywhere else, and never send history anywhere."

## Done when

- `NO_INSTALL=1 ./build.sh` builds with 0 warnings.
- `scripts/eval.sh` output is pasted in your summary, and every case matches its `EXPECT:` line. In particular, no `fixed` output adds bullets or line breaks.
- `--test` doesn't create history lines. Run the app briefly and confirm `history.jsonl` gets a `suggested` line (or say what's left for the owner to check).
- Commits: prompt plus eval cases, history, review script, AGENTS.md.
