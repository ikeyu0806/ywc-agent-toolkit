#!/usr/bin/env bash
# Local validation script — mirrors the logic in .github/workflows/validate.yml.
# Usage: bash scripts/validate.sh
set -euo pipefail

ERRORS=0

check_skill_dir() {
  local dir="$1"
  local name
  name="$(basename "$dir")"
  local skill_md="${dir}SKILL.md"

  if [ ! -f "$skill_md" ]; then
    echo "ERROR: $name is missing SKILL.md"
    ERRORS=$((ERRORS + 1))
    return
  fi

  if ! grep -q "^name:" "$skill_md"; then
    echo "ERROR: $name/SKILL.md is missing 'name:' in frontmatter"
    ERRORS=$((ERRORS + 1))
  fi

  if ! grep -q "^description:" "$skill_md"; then
    echo "ERROR: $name/SKILL.md is missing 'description:' in frontmatter"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "==> Validating claude-code skills..."
for dir in claude-code/skills/*/; do
  [ -d "$dir" ] && check_skill_dir "$dir"
done

echo "==> Validating codex skills..."
# codex/skills/ is a single skill bundle (not per-subdirectory like claude-code)
check_skill_dir "codex/skills/"

echo "==> Checking install script (dry run)..."
bash scripts/install.sh --list > /dev/null

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "Validation failed: $ERRORS error(s) found."
  exit 1
fi

echo "All checks passed."
