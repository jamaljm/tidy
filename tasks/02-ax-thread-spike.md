# Task 02: spike, can we read the thread above the reply box?

Read `AGENTS.md` first. This is a throwaway investigation. Its output is a report, not a feature.

## Goal

Find out how much of the conversation above the focused reply box each app exposes through Accessibility. The answer decides whether v1 reply drafts can rely on AX, or need a screenshot fallback.

## Steps

1. Add a hidden debug command `Tidy --dump-thread`. It waits 5 seconds (so the owner can click into a reply box), then:
   - takes the focused element, and walks **up** the parents (`kAXParentAttribute`) to the window, printing role, subrole, description, title and a value preview (first 80 characters) at each level;
   - from each ancestor up to 6 levels, walks **down** (`kAXChildrenAttribute`, depth limit 12, node limit 3,000), collecting every `AXStaticText` or text-bearing element's value, in tree order;
   - prints the collected text with its depth and role to stdout, and writes it to `~/.config/tidy/dumps/<bundleID>-<timestamp>.txt`.
   - It calls `AX.enableManual(pid)` first, since Electron apps need it.
2. Add `docs/ax-thread-report.md` with one section per app: Slack desktop, Gmail in Chrome, Apple Mail, Messages (iMessage), WhatsApp desktop. Each section says whether sender names, message text and timestamps are visible, how many past messages appear, which ancestor level holds the message list, and a suggested extraction rule (for example "the AXList with subrole X under the AXGroup that holds the reply box").
3. The owner has to run the dump by hand in each app, because you can't click into their apps. Write the report template with clear "run this, paste here" steps, and fill in any part you can verify yourself.

## Done when

- `--dump-thread` compiles and runs.
- The report template exists with exact run instructions.
- No message text gets logged anywhere except the dump file the owner asked for. Add `dumps/` to the privacy note in the report.
