# Tidy roadmap

Goal: Tidy grows from "fix what I typed" into "write what I would have typed". It reads the situation, writes in the owner's voice (CEO style: short, clear, decisive), and later drafts replies from the conversation on screen. It never sends anything itself.

| Phase | Ships | Task brief |
| --- | --- | --- |
| v0: Smarter fixer | A fix that matches the situation (app, recipient, tone), reshapes run-on text into lines or points when that reads better, and offers one "better way to say it" alternative | `tasks/01-v0-smarter-fixer.md` |
| Spike: read the thread | A debug dump of what the AX tree exposes above the reply box in Slack, Gmail (Chrome), Mail, iMessage and WhatsApp | `tasks/02-ax-thread-spike.md` |
| v1: Reply drafts | Empty reply box plus a pause gives a draft reply in a blue button state. Steer mode turns "yes but next week" into a full reply | `tasks/03-v1-reply-drafts.md` |
| v2: It learns you | Memory in the owner's Obsidian vault: `Tidy/Style.md`, `Tidy/People/*.md` and `Tidy/Sent/*.md`, plus a local index. Captures draft vs what was really sent | brief written after v1 |
| v3: It acts | Chips like "check calendar" or "attach doc" that run one step, then draft with the answer | brief written after v2 |

Decisions already made by the owner:
- Reply drafts use **Claude Sonnet 5.5**. The fixer stays on Haiku 5.5.
- The default voice is **CEO style**: answer first, usually 1 to 3 lines, never long like AI. The length follows the situation.
- Personal context and memory live in the owner's **Obsidian vault** as plain markdown. Tidy only writes under `Tidy/` in the vault, and only reads folders the owner allows.
