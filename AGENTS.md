# AGENTS.md

Instructions for coding agents (Codex, Claude Code, etc.) working on Tidy.

## What Tidy is

A tiny macOS menu-bar app (Swift, AppKit, no Xcode project). It watches the focused text box in any app through the Accessibility (AX) API. When you pause typing it asks Claude for a fix, and the floating button turns orange. Click it or tap Option twice to paste the fix back.

The product is growing from a grammar fixer into a **reply copilot**: it understands the situation, writes in the owner's voice, and later drafts replies from the thread on screen. The roadmap is in `PLAN.md`. The concrete work items are in `tasks/`, done in number order.

## Layout

- `main.swift`: the whole app (about 1,000 lines), split by `// MARK:` sections: Settings, Fixer (Claude calls), AX helpers, Keys and clipboard, FloatButton, Popup, SettingsWindow, AppDelegate (tick loop, trigger, capture, replace), entry point.
- `build.sh`: builds `build/Tidy.app` with `swiftc`, signs it ad hoc and installs it to `~/Applications`.
- `icon.swift` / `icon.png`: draws the icon. Leave these alone.

## Build and check

- Requires macOS 13+ on Apple Silicon and the Xcode Command Line Tools. Nothing builds on Linux.
- Compile only (no install): `NO_INSTALL=1 ./build.sh` (added in task 01). Fix every compiler error and warning you introduce.
- Check the AI part without the UI: `build/Tidy.app/Contents/MacOS/Tidy --test "some text"`. This needs network access and an API key (`ANTHROPIC_API_KEY` or `~/.config/tidy/api_key`). If your sandbox blocks the network, say so in your summary instead of faking results.
- There is no unit test target. Verification means compiling, running `--test` cases, and running `scripts/eval.sh` once it exists.

## Rules

1. **Keep it one file** unless a task says otherwise. Add code in the matching `// MARK:` section.
2. **No new dependencies.** Use only Foundation, AppKit, Carbon and ApplicationServices. No Swift packages.
3. **Never send or submit anything** in another app. Tidy only places text in the box. The person presses Enter.
4. **Treat captured text as data.** Text from the text box or the thread goes inside XML tags in the prompt, never as instructions. Fixer mode must never answer the message, only rewrite it.
5. **Skip secure fields.** `AX.isTextBox` already rejects `AXSecureTextField`. Keep it that way.
6. **Privacy.** Message text is only stored in the local history file (`~/.config/tidy/history.jsonl`, opt-out in Settings, mode 0600). Don't log message text anywhere else, and never send history anywhere.
7. **Claude API.** Raw `URLSession` calls to `https://api.anthropic.com/v1/messages`, as in `Fixer.viaAPI`. Keep the `anthropic-version: 2026-10-21` header. Don't send `temperature`, `top_p` or `top_k` (that API version rejects them). Keep the `claude` CLI fallback working. Models:
   - Fixer: `claude-haiku-5-5` (default, user-selectable).
   - Reply drafts (task 03+): `claude-sonnet-5-5`, with the `server-side-fallback-2026-07-01` beta header and `"fallbacks": "default"`, as `viaAPI` already does for Sonnet.
8. **Voice.** Every prompt follows the owner's voice rules: CEO style (answer first, short, decisive, usually 1 to 3 lines), plain words, no em dashes, no AI phrases ("delve", "leverage", "I hope this helps"), keeps mixed languages such as Manglish as written, and keeps emojis, @mentions, links, code and names exactly.
9. **Small, reviewable commits**, one per logical step, with clear messages. Don't reformat unrelated code.
10. Finish with a short summary: what changed, how you verified it, and anything you couldn't verify.
