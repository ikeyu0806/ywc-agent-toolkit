#!/usr/bin/env bash
# scan-secrets.sh [--staged] [--committed <base-branch>]

set -uo pipefail

MODE="staged"
BASE_BRANCH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged) MODE="staged"; shift ;;
    --committed) MODE="committed"; BASE_BRANCH="${2:-}"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ "$MODE" = "committed" ] && [ -z "$BASE_BRANCH" ]; then
  echo "Usage: scan-secrets.sh --committed <base-branch>" >&2
  exit 2
fi

FOUND=0

DANGEROUS=$(git status --short 2>/dev/null \
  | awk '{print $NF}' \
  | grep -iE '(^|/)\.env(\.|$)|credentials\.|secret\.|id_rsa|\.pem$|\.key$' \
  || true)

if [ -n "$DANGEROUS" ]; then
  echo "WARN: Potentially sensitive files in changeset:"
  echo "$DANGEROUS" | sed 's/^/  /'
  FOUND=1
fi

DIFF_STAGED=$(git diff --cached 2>/dev/null || true)
DIFF_UNSTAGED=$(git diff 2>/dev/null || true)
DIFF_CONTENT="$DIFF_STAGED
$DIFF_UNSTAGED"

if [ "$MODE" = "committed" ]; then
  DIFF_COMMITTED=$(git diff "${BASE_BRANCH}...HEAD" 2>/dev/null || true)
  DIFF_CONTENT="$DIFF_CONTENT
$DIFF_COMMITTED"
fi

SECRET_PATTERNS=(
  'AKIA[0-9A-Z]{16}'
  'sk-[a-zA-Z0-9]{32,}'
  'ghp_[a-zA-Z0-9]{36}'
  'github_pat_[a-zA-Z0-9]{82}'
  'xoxb-[0-9]{11}-[0-9]{11}-[a-zA-Z0-9]{24}'
  'xoxp-[0-9]{11}-'
  'AIza[0-9A-Za-z_-]{35}'
  '-----BEGIN .* PRIVATE KEY-----'
  'password[[:space:]]*=[[:space:]]*["'\''][^"'\'']{4,}'
  'DATABASE_URL[[:space:]]*='
)

ADDED_LINES=$(echo "$DIFF_CONTENT" | grep '^+' | grep -v '^+++' || true)

for PATTERN in "${SECRET_PATTERNS[@]}"; do
  MATCHES=$(echo "$ADDED_LINES" | grep -E -- "$PATTERN" || true)
  if [ -n "$MATCHES" ]; then
    echo "SECRET DETECTED (pattern: $PATTERN):"
    echo "$MATCHES" | head -3 | sed 's/^/  /'
    FOUND=1
  fi
done

if [ "$FOUND" -eq 0 ]; then
  echo "OK: No secrets detected"
fi

exit "$FOUND"
