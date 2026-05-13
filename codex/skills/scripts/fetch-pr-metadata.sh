#!/usr/bin/env bash
# fetch-pr-metadata.sh <pr-number> [<pr-number> ...]

set -uo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: fetch-pr-metadata.sh <pr-number> [<pr-number> ...]" >&2
  exit 2
fi

VAGUE_RE='^(fix|update|wip|misc|change|changes|bump|cleanup|refactor|chore|temp|tmp)$'

for PR_NUMBER in "$@"; do
  DATA=$(gh pr view "$PR_NUMBER" \
    --json state,number,author,title,body \
    2>/dev/null) || {
    printf '{"number":%s,"skipped":true,"reason":"fetch_error"}\n' "$PR_NUMBER"
    continue
  }

  STATE=$(echo "$DATA" | jq -r .state)
  if [ "$STATE" != "MERGED" ]; then
    echo "$DATA" | jq -c \
      --arg reason "not_merged: $STATE" \
      '{number: .number, skipped: true, reason: $reason}'
    continue
  fi

  SUMMARY=$(echo "$DATA" | jq -r '
    .title
    | gsub("^\\[[A-Z]+-[0-9]+\\]\\s*"; "")
    | gsub("^(feat|fix|chore|refactor|docs|test|perf|ci|build|style)(!\\([^)]+\\))?(!)?:\\s*"; "")
    | gsub("^\\s+|\\s+$"; "")
    | if length > 80 then (.[0:79] + "...") else . end
  ')

  if echo "$SUMMARY" | grep -qiE "$VAGUE_RE" || [ -z "$SUMMARY" ]; then
    BODY_LINE=$(echo "$DATA" | jq -r '
      (.body // "")
      | split("\n")
      | map(select(length > 0 and (test("^(##|<!--|\\s*-\\s*\\[)") | not)))
      | first // ""
      | .[0:80]
    ')
    [ -n "$BODY_LINE" ] && SUMMARY="$BODY_LINE"
  fi

  echo "$DATA" | jq -c \
    --arg summary "$SUMMARY" \
    '{number: .number, author: .author.login, title: .title, summary: $summary, skipped: false}'
done
