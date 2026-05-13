#!/usr/bin/env bash
#
# PreToolUse hook — intercept `git push` and verify CLAUDE.md freshness.
#
# Behavior
#   * Reads the Bash tool input from stdin.
#   * If the command is not a `git push`, exits 0 (allow).
#   * If the push targets only tags (`--tags` or refspecs that resolve to a
#     tag ref), exits 0 — the current branch HEAD diff is irrelevant for
#     tag-only pushes.
#   * If the push range has code/config/docs changes but no CLAUDE.md in the
#     same range was touched, emits a warning to stderr.
#   * Default mode is warn-only (exit 0). Set `CLAUDE_MD_CHECK_MODE=strict`
#     to block the push (exit 2) instead.
#   * Any CLAUDE.md change in the range is treated as "reviewed".
#
# Bypass
#   Set `CLAUDE_MD_CHECK=skip` in the invoking shell to skip the check once.
#
# Modes
#   CLAUDE_MD_CHECK_MODE=warn   (default) — warn on stderr, do not block.
#   CLAUDE_MD_CHECK_MODE=strict           — exit 2 to block the push.
#
# Exit codes
#   0 — allow the push (warn-only by default, even when stale)
#   2 — block the push (only when `CLAUDE_MD_CHECK_MODE=strict`)
#
set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

# Only act on `git push` — match both `git push` and `... && git push ...`.
if ! printf '%s' "$cmd" | grep -qE '(^|[[:space:]&|;])git[[:space:]]+push([[:space:]]|$)'; then
  exit 0
fi

# Manual bypass.
if [[ "${CLAUDE_MD_CHECK:-}" == "skip" ]]; then
  exit 0
fi

# Tag-only push (e.g. `git push --tags` or `git push origin v1.2.3`) does not
# ship branch HEAD changes, so the freshness check would produce false alarms.
# Heuristic: bail out if `--tags` is present, or if every refspec after the
# remote is a tag ref or matches a local tag name.
if printf '%s' "$cmd" | grep -qE '(^|[[:space:]])(--tags|--follow-tags)([[:space:]]|$)'; then
  exit 0
fi
push_args=$(printf '%s' "$cmd" | sed -E 's/.*[[:space:]&|;]git[[:space:]]+push[[:space:]]+//')
if [[ -n "$push_args" ]]; then
  read -ra _tokens <<<"$push_args"
  refspecs=()
  for ((i = 1; i < ${#_tokens[@]}; i++)); do
    tok="${_tokens[$i]}"
    [[ -z "$tok" || "$tok" == -* ]] && continue
    refspecs+=("$tok")
  done
  if (( ${#refspecs[@]} > 0 )); then
    all_tags=1
    for spec in "${refspecs[@]}"; do
      ref="${spec##*:}"  # right side of src:dst, or the whole thing
      ref="${ref#+}"      # strip leading + (force flag)
      if [[ "$ref" == refs/tags/* ]]; then
        continue
      fi
      if git rev-parse --verify --quiet "refs/tags/$ref" >/dev/null 2>&1; then
        continue
      fi
      all_tags=0
      break
    done
    if (( all_tags == 1 )); then
      exit 0
    fi
  fi
fi

# Work relative to the project root when available.
cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>/dev/null || true

# Only run inside a git working tree.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

# Resolve an upstream ref to diff against.
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
if [[ -z "$upstream" ]]; then
  origin_head=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/||' || true)
  upstream="${origin_head:-}"
fi
if [[ -z "$upstream" ]] || ! git rev-parse --verify --quiet "$upstream" >/dev/null; then
  # Can't resolve a push range — don't second-guess the user.
  exit 0
fi

base=$(git merge-base HEAD "$upstream" 2>/dev/null || true)
if [[ -z "$base" ]]; then
  exit 0
fi

changed=$(git diff --name-only "$base"..HEAD 2>/dev/null || true)
if [[ -z "$changed" ]]; then
  # Nothing to push (tag-only pushes, already-synced branches, etc.).
  exit 0
fi

claude_md_changed=$(printf '%s\n' "$changed" | grep -E '(^|/)CLAUDE\.md$' || true)
if [[ -n "$claude_md_changed" ]]; then
  # At least one CLAUDE.md was updated alongside the code — assume reviewed.
  exit 0
fi

# Determine which CLAUDE.md files are relevant to the changed paths.
# For every changed file, walk upward until a CLAUDE.md is found.
relevant=$(printf '%s\n' "$changed" | while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  dir=$(dirname "$f")
  while :; do
    if [[ -f "$dir/CLAUDE.md" ]]; then
      printf '%s\n' "$dir/CLAUDE.md"
      break
    fi
    [[ "$dir" == "." || "$dir" == "/" ]] && break
    dir=$(dirname "$dir")
  done
done | sort -u)

mode="${CLAUDE_MD_CHECK_MODE:-warn}"
if [[ "$mode" == "strict" ]]; then
  status_label="Blocked"
else
  status_label="Warning"
fi

# Emit guidance via stderr so Claude sees it.
{
  echo "[CLAUDE.md freshness check] ${status_label}: \`git push\` would ship code without any CLAUDE.md update."
  echo
  echo "Range: ${base:0:12}..HEAD (upstream: $upstream)"
  echo
  echo "Changed files (first 20):"
  printf '%s\n' "$changed" | head -20 | sed 's/^/  - /'
  echo
  if [[ -n "$relevant" ]]; then
    echo "Nearest CLAUDE.md files to review:"
    printf '%s\n' "$relevant" | sed 's/^/  - /'
  else
    echo "No CLAUDE.md found on the ancestor path of the changed files."
  fi
  echo
  echo "Next steps:"
  echo "  1. For each changed path above, open the nearest CLAUDE.md and decide whether"
  echo "     commands, dependencies, file layout, or documented rules are now stale."
  echo "  2. If stale — update the CLAUDE.md, commit, and re-run the push."
  echo "  3. If not — re-run with:  CLAUDE_MD_CHECK=skip <your push command>"
  if [[ "$mode" != "strict" ]]; then
    echo "  (Set CLAUDE_MD_CHECK_MODE=strict to enforce blocking.)"
  fi
} >&2

# Default: warn-only. Block only when explicitly requested.
if [[ "$mode" == "strict" ]]; then
  exit 2
fi
exit 0