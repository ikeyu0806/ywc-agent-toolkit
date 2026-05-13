#!/usr/bin/env bash
#
# PreToolUse hook — intercept `git commit` and `gh pr create`,
# checking README.md freshness when claude-code/ or codex/ are modified.
#
# Behavior
#   * Reads the Bash tool input from stdin.
#   * If the command is not `git commit` or `gh pr create`, exits 0 (allow).
#   * If claude-code/ or codex/ changes exist without README.md update → warn/block.
#   * Default mode is warn-only (exit 0). Set README_CHECK_MODE=strict to block.
#
# Bypass
#   Set README_CHECK=skip in the invoking shell to skip the check once.
#
# Modes
#   README_CHECK_MODE=warn   (default) — warn on stderr, do not block.
#   README_CHECK_MODE=strict           — exit 2 to block.
#
set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

# Only act on git commit or gh pr create
is_git_commit=0
is_pr_create=0

if printf '%s' "$cmd" | grep -qE '(^|[[:space:]&|;])git[[:space:]]+commit([[:space:]]|$|-[a-zA-Z])'; then
  is_git_commit=1
fi

if printf '%s' "$cmd" | grep -qE '(^|[[:space:]&|;])gh[[:space:]]+pr[[:space:]]+create([[:space:]]|$)'; then
  is_pr_create=1
fi

if (( is_git_commit == 0 && is_pr_create == 0 )); then
  exit 0
fi

# Manual bypass
if [[ "${README_CHECK:-}" == "skip" ]]; then
  exit 0
fi

# Work relative to the project root
REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$REPO_ROOT" 2>/dev/null || true

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

# Get changed files based on trigger type
changed=""
context=""

if (( is_git_commit == 1 )); then
  changed=$(git diff --cached --name-only 2>/dev/null || true)
  context="staged for commit"
else
  # For gh pr create, check range from upstream
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
  if [[ -z "$upstream" ]]; then
    origin_head=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/||' || true)
    upstream="${origin_head:-}"
  fi
  if [[ -z "$upstream" ]] || ! git rev-parse --verify --quiet "$upstream" >/dev/null 2>&1; then
    exit 0
  fi
  base=$(git merge-base HEAD "$upstream" 2>/dev/null || true)
  [[ -z "$base" ]] && exit 0
  changed=$(git diff --name-only "$base"..HEAD 2>/dev/null || true)
  context="in PR range (${base:0:12}..HEAD, upstream: $upstream)"
fi

[[ -z "$changed" ]] && exit 0

# Check if claude-code/ or codex/ are changed
skill_changes=$(printf '%s\n' "$changed" | grep -E '^(claude-code|codex)/' || true)
[[ -z "$skill_changes" ]] && exit 0

# If README.md is already updated alongside the changes, assume doc was reviewed
readme_changed=$(printf '%s\n' "$changed" | grep -E '^README\.md$' || true)
[[ -n "$readme_changed" ]] && exit 0

# Recount current skills for actionable guidance
cc_skill_count=$(find "$REPO_ROOT/claude-code/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ' || echo "?")
codex_skill_count=$(grep -c '^name:' "$REPO_ROOT/codex/skills/SKILL.md" 2>/dev/null || echo "?")

mode="${README_CHECK_MODE:-warn}"
if [[ "$mode" == "strict" ]]; then
  status_label="Blocked"
else
  status_label="Warning"
fi

{
  echo "[README freshness check] ${status_label}: skill directory changes detected without README.md update."
  echo
  echo "Changed skill files ($context):"
  printf '%s\n' "$skill_changes" | head -20 | sed 's/^/  - /'
  echo
  echo "Current skill counts (live recount from repo):"
  echo "  - claude-code/skills: $cc_skill_count skill(s)"
  echo "  - codex/skills (SKILL.md frontmatter): $codex_skill_count skill(s)"
  echo
  echo "Sections to verify in README.md:"
  echo "  1. '## Supported Tools' table — Claude Code: $cc_skill_count, Codex: $codex_skill_count"
  echo "  2. '## Codex Skills' section  — list should match codex/skills/SKILL.md"
  echo
  echo "To skip: README_CHECK=skip <your command>"
  if [[ "$mode" != "strict" ]]; then
    echo "(Set README_CHECK_MODE=strict to enforce blocking.)"
  fi
} >&2

if [[ "$mode" == "strict" ]]; then
  exit 2
fi
exit 0
