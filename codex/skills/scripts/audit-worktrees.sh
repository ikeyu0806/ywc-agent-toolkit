#!/usr/bin/env bash
# audit-worktrees.sh [--prune] [--expect <task1,task2,...>]

set -uo pipefail

DO_PRUNE=0
EXPECT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prune) DO_PRUNE=1; shift ;;
    --expect) EXPECT="${2:-}"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ "$DO_PRUNE" -eq 1 ]; then
  git worktree prune --verbose 2>&1 || true
fi

WORKTREES=$(git worktree list --porcelain 2>/dev/null \
  | awk '/^worktree /{print $2}' \
  | grep -E '/worktree-' || true)

if [ -z "$WORKTREES" ]; then
  echo "OK: no parallel-executor worktrees found"
  exit 0
fi

declare -A EXPECTED_MAP
if [ -n "$EXPECT" ]; then
  IFS=',' read -ra EXPECTED_LIST <<< "$EXPECT"
  for TASK in "${EXPECTED_LIST[@]}"; do
    EXPECTED_MAP["worktree-${TASK}"]=1
  done
fi

FOUND_UNEXPECTED=0
while IFS= read -r WT_PATH; do
  WT_BASENAME=$(basename "$WT_PATH")
  if [ -n "$EXPECT" ] && [ "${EXPECTED_MAP[$WT_BASENAME]+_}" ]; then
    echo "OK (preserved failure): $WT_PATH"
  else
    echo "DRIFT: unexpected worktree: $WT_PATH"
    echo "  Investigate before proceeding to next wave."
    echo "  If already merged: git worktree remove --force $WT_PATH"
    echo "  If in-progress work: stop and surface to user"
    FOUND_UNEXPECTED=1
  fi
done <<< "$WORKTREES"

exit "$FOUND_UNEXPECTED"
