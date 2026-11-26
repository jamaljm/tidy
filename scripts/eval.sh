#!/bin/bash
# Human-readable checks for the fixer. Cases are app|title|message blocks.
set -uo pipefail
cd "$(dirname "$0")/.."

tidy=build/Tidy.app/Contents/MacOS/Tidy
if [[ ! -x "$tidy" ]]; then
    echo 'ERROR: Build Tidy first with NO_INSTALL=1 ./build.sh'
    exit 1
fi

failed=0
count=0
run_case() {
    local block="$1" expectation="$2" app rest title message
    if [[ "$block" != *'|'* || "${block#*|}" != *'|'* ]]; then
        echo 'ERROR: Expected app|title|message in eval_cases.txt'
        failed=1
        return
    fi
    app="${block%%|*}"
    rest="${block#*|}"
    title="${rest%%|*}"
    message="${rest#*|}"
    message="${message//\\n/$'\n'}"
    count=$((count + 1))
    printf 'Case %s\nContext: %s | %s\nInput: %s\nEXPECT: %s\nOutput:\n' "$count" "$app" "$title" "$message" "$expectation"
    if ! "$tidy" --test "$message" --app "$app" --title "$title"; then
        failed=1
    fi
    printf '\n'
}

block=''
expectation=''
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" ]]; then
        if [[ -n "$block" ]]; then run_case "$block" "$expectation"; block=''; expectation=''; fi
    elif [[ "$line" == EXPECT:* ]]; then
        expectation="${line#EXPECT: }"
    else
        if [[ -n "$block" ]]; then block+=$'\n'; fi
        block+="$line"
    fi
done < scripts/eval_cases.txt
if [[ -n "$block" ]]; then run_case "$block" "$expectation"; fi
exit "$failed"
