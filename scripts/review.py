#!/usr/bin/env python3
"""Review Tidy's local history. This script never sends or changes history."""

import argparse
from datetime import datetime, timedelta, timezone
from difflib import SequenceMatcher
import json
from pathlib import Path
import re
import sys


def timestamp(event):
    try:
        value = datetime.fromisoformat(event["ts"].replace("Z", "+00:00"))
        return value if value.tzinfo else value.replace(tzinfo=timezone.utc)
    except (KeyError, AttributeError, TypeError, ValueError):
        return None


def read_history(path):
    events = []
    invalid = 0
    try:
        with path.open(encoding="utf-8") as source:
            for line in source:
                try:
                    event = json.loads(line)
                    if not isinstance(event, dict) or timestamp(event) is None:
                        raise ValueError("Invalid event")
                    events.append(event)
                except (ValueError, TypeError):
                    invalid += 1
    except FileNotFoundError:
        pass
    return events, invalid


def change_size(event):
    return 1 - SequenceMatcher(None, event["input"], event["fixed"]).ratio()


def formatting_flags(event):
    original, fixed = event["input"], event["fixed"]
    flags = []
    if len(re.findall(r"\r\n|\r|\n", fixed)) > len(re.findall(r"\r\n|\r|\n", original)):
        flags.append("added line break")
    bullet = r"(?m)^[ \t]*(?:[-*+•]|\d+[.)])[ \t]+"
    if len(re.findall(bullet, fixed)) > len(re.findall(bullet, original)):
        flags.append("added bullet")
    return flags


def quote(text):
    # Escapes line breaks and control characters so each comparison stays readable.
    return json.dumps(text, ensure_ascii=False)


def describe(event):
    return f'{event["ts"]} | {event.get("app", "")} | {event.get("window", "")}'


def summarize(events, days=7, app=None, now=None):
    now = now or datetime.now(timezone.utc)
    cutoff = now - timedelta(days=days)
    selected = [event for event in events
                if cutoff <= timestamp(event) <= now
                and (app is None or str(event.get("app", "")).casefold() == app.casefold())]
    suggestions = [event for event in selected if event.get("event") == "suggested"
                   and isinstance(event.get("input"), str) and isinstance(event.get("fixed"), str)]
    pastes = [event for event in selected if event.get("event") in ("pasted_fix", "pasted_alt")]
    # Search all events so a paste just before the date cutoff can still be paired with its edit.
    by_paste_id = {event["pasteID"]: event for event in events
                   if isinstance(event.get("pasteID"), str)
                   and event.get("event") in ("pasted_fix", "pasted_alt")}
    corrections = []
    for event in selected:
        if event.get("event") != "sent_text" or not isinstance(event.get("output"), str):
            continue
        paste = by_paste_id.get(event.get("pasteID"), {})
        # The inline snapshot is the whole box, including text outside a pasted selection.
        pasted = event.get("pasted", paste.get("output"))
        if isinstance(pasted, str) and pasted != event["output"]:
            corrections.append((event, pasted))

    unchanged = sum(event["input"] == event["fixed"] for event in suggestions)
    average = sum(map(change_size, suggestions)) / len(suggestions) if suggestions else 0
    flagged = [(event, formatting_flags(event)) for event in suggestions if formatting_flags(event)]
    print(f'Local history review: last {days} days' + (f' | app: {app}' if app else ""))
    print(f"Suggestions: {len(suggestions)}")
    print(f'Pasted: {len(pastes)} (fix: {sum(e["event"] == "pasted_fix" for e in pastes)}, '
          f'alt: {sum(e["event"] == "pasted_alt" for e in pastes)})')
    print(f"No change: {unchanged}")
    print(f"Average change size: {average:.2%} (1 - SequenceMatcher ratio)")
    print(f"Formatting violations: {len(flagged)}")

    print("\n20 biggest changes (input -> fixed):")
    for event in sorted(suggestions, key=change_size, reverse=True)[:20]:
        flags = formatting_flags(event)
        suffix = f' [FLAG: {", ".join(flags)}]' if flags else ""
        print(f"\n{describe(event)} | change: {change_size(event):.2%}{suffix}")
        print(f'  {quote(event["input"])} -> {quote(event["fixed"])}')
    if not suggestions:
        print("  None.")

    print(f"\nOwner corrections after paste: {len(corrections)}")
    for event, pasted in corrections:
        print(f"\n{describe(event)}")
        print(f'  Pasted: {quote(pasted)}')
        print(f'  Owner:  {quote(event["output"])}')

    # List every violation even if it is outside the 20 biggest changes.
    if flagged:
        print("\nAll formatting violations:")
        for event, flags in flagged:
            print(f'\n{describe(event)} [FLAG: {", ".join(flags)}]')
            print(f'  {quote(event["input"])} -> {quote(event["fixed"])}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--days", type=int, default=7, help="Review this many days (default: 7)")
    parser.add_argument("--app", help="Filter by app name, ignoring case (for example Slack)")
    args = parser.parse_args()
    if args.days < 0:
        parser.error("--days must be nonnegative")
    path = Path.home() / ".config/tidy/history.jsonl"
    try:
        events, invalid = read_history(path)
    except (OSError, UnicodeError) as error:
        print(f"Cannot read local history: {error}", file=sys.stderr)
        return 1
    if not path.exists():
        print(f"No history file yet: {path}")
    if invalid:
        print(f"Skipped {invalid} malformed history lines.", file=sys.stderr)
    summarize(events, days=args.days, app=args.app)
    return 0


if __name__ == "__main__":
    sys.exit(main())
