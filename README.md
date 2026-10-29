# Tidy

A tiny Grammarly-style fixer for your Mac.

Type, pause, and the little button turns orange when it has a fix. Click it (or tap Option twice).
It fixes spelling and grammar and keeps your voice. Powered by Claude.

## Build

Needs macOS 13+ on Apple Silicon and the Xcode Command Line Tools.

```bash
./build.sh
```

This builds `Tidy.app` and installs it to `~/Applications`.

## API key

Tidy needs an Anthropic API key. Either:

- paste it in Tidy's settings (saved to `~/.config/tidy/api_key`), or
- set `ANTHROPIC_API_KEY` in your environment.
