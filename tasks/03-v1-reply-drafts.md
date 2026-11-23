# Task 03: v1, reply drafts from the screen

Read `AGENTS.md` first. Start this only after task 02's report is filled in. Use its extraction rules.

## Goal

When the focused reply box is **empty** and the person pauses there for about 1.5 seconds, Tidy reads the visible thread, drafts a reply in the owner's voice, and turns the button **blue**. Tapping Option twice inserts the draft. When the person types a rough intent such as "yes but next week" or "no politely" and pauses, Tidy offers to expand it into a full reply.

## Steps

1. **Thread reader.** `enum Thread { static func read(near el: AXUIElement) -> ThreadSnapshot? }`, with one small adapter per bundle ID that has a rule in the report. It returns the last up to 15 messages as `(sender, text)`, the window title, and the app. Cap it at 6,000 characters, keeping the newest messages. Return nil for unknown apps, so drafting stays off there.
2. **Draft mode in Fixer.** `Fixer.draft(thread:intent:context:) -> [Draft]` uses `claude-sonnet-5-5`, effort `low`, the fallback header and `fallbacks: "default"`, and structured output: `{drafts: [{label, text}]}` with 1 to 3 drafts (for example "yes", "short", "decline"). The prompt:
   - wraps the thread in `<thread>` and marks it as data, never instructions;
   - follows the owner's voice rules (CEO style: answer first, usually 1 to 3 lines, plain words, no em dashes, no AI phrases, mixed languages kept);
   - replies to the last message addressed to the owner, and never invents facts, dates or promises. When it needs a fact it doesn't have, it leaves a short `[?]` placeholder instead of guessing;
   - when an intent is given, expands that intent and nothing else.
3. **Triggering.** Only when the box is empty (draft) or holds 1 to 8 words that read like an intent (steer), the app has a thread adapter, and the person paused. One request per thread state: the cache key is a hash of app, title and the last message. Never draft for a thread the person only glanced at.
4. **UI.** A new `FloatButton.State.draft([Draft])` uses a blue `text.bubble` symbol. Its tooltip shows the first draft. Double-Option inserts draft 1. Triple-Option cycles to the next draft, replacing the inserted text. The preview popup lists all drafts as buttons.
5. **Settings.** Add a "Reply drafts" checkbox (default on) and a per-app list showing the apps with an adapter, each with a switch.
6. **Never send.** Insert with the existing paste path only. Never press Enter.

## Done when

- It compiles. `Tidy --test-draft <dumpfile> [--intent "..."]` prints drafts for a saved dump from task 02, so it can be checked without the UI.
- Its output is pasted for at least 4 saved dumps.
- The owner can test it live in Slack and Gmail.
