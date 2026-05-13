#!/usr/bin/env bash
#
# ywc-agent-toolkit 통합 설치 스크립트
#
# Usage:
#   bash scripts/install.sh --cc                        Claude Code 전체 설치
#   bash scripts/install.sh --codex                     Codex 전체 설치
#   bash scripts/install.sh --all                       양쪽 전체 설치
#   bash scripts/install.sh --cc <skill> [skill...]     Claude Code 특정 스킬
#   bash scripts/install.sh --codex <skill> [skill...]  Codex 특정 스킬
#   bash scripts/install.sh --list [--cc|--codex]       설치 가능한 스킬 목록
#   bash scripts/install.sh --help                      이 도움말
#
# Environment:
#   CLAUDE_SKILLS_DIR   Claude Code 설치 경로 override (default: ~/.claude/skills)
#   CODEX_HOME          Codex 홈 경로 override (default: ~/.codex)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CC_SRC="$REPO_ROOT/claude-code/skills"
CODEX_SRC="$REPO_ROOT/codex/skills"
CC_DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CODEX_DEST="${CODEX_HOME:-$HOME/.codex}/skills"
CC_MANIFEST="$CC_DEST/.ywc-agent-toolkit.manifest"
CODEX_MANIFEST="$CODEX_DEST/.ywc-agent-toolkit.manifest"

CC_INSTALLED=0
CODEX_INSTALLED=0
CC_PRUNED=0
CODEX_PRUNED=0

# ---- helpers ----------------------------------------------------------------

is_skill_dir() {
  [ -f "$1/SKILL.md" ]
}

list_skills() {
  local src="$1"
  [ -d "$src" ] || return 0
  local d
  for d in "$src"/*/; do
    [ -d "$d" ] || continue
    is_skill_dir "$d" || continue
    basename "$d"
  done
}

read_manifest() {
  local manifest="$1"
  [ -f "$manifest" ] || return 0
  grep -Ev '^(#|$)' "$manifest" || true
}

write_manifest() {
  local manifest="$1"
  local skills="$2"
  {
    echo "# ywc-agent-toolkit install manifest"
    echo "# Auto-generated — do not edit manually."
    [ -n "$skills" ] && printf '%s\n' "$skills"
  } > "$manifest"
}

# ---- install / prune --------------------------------------------------------

install_skill() {
  local src_dir="$1"
  local dest_dir="$2"
  local name
  name="$(basename "$src_dir")"
  is_skill_dir "$src_dir" || return 0
  rm -rf "${dest_dir:?}/$name"
  cp -R "$src_dir" "$dest_dir/$name"
  echo "  ✓ $name"
}

prune_orphans() {
  local dest="$1"
  local manifest="$2"
  local current="$3"
  local previous orphans name

  previous="$(read_manifest "$manifest")"
  [ -n "$previous" ] || return 0

  orphans="$(comm -23 \
    <(printf '%s\n' "$previous" | sort -u) \
    <(printf '%s\n' "$current" | sort -u))"

  [ -n "$orphans" ] || return 0

  echo "  고아 스킬 제거 중:"
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    local target="$dest/$name"
    [ -d "$target" ] || continue
    if [ ! -f "$target/SKILL.md" ]; then
      echo "    ! $name (SKILL.md 없음, skip)"
      continue
    fi
    rm -rf "$target"
    echo "    ✗ $name"
    if [ "$dest" = "$CC_DEST" ]; then
      CC_PRUNED=$((CC_PRUNED + 1))
    else
      CODEX_PRUNED=$((CODEX_PRUNED + 1))
    fi
  done <<< "$orphans"
}

# ---- Claude Code ------------------------------------------------------------

run_cc_install() {
  local skills=("$@")
  mkdir -p "$CC_DEST"
  echo "Claude Code → $CC_DEST"

  local current
  current="$(list_skills "$CC_SRC")"

  if [ "${#skills[@]}" -eq 0 ]; then
    prune_orphans "$CC_DEST" "$CC_MANIFEST" "$current"
    local d
    for d in "$CC_SRC"/*/; do
      [ -d "$d" ] || continue
      is_skill_dir "$d" || continue
      install_skill "$d" "$CC_DEST"
      CC_INSTALLED=$((CC_INSTALLED + 1))
    done
    write_manifest "$CC_MANIFEST" "$current"
  else
    local name
    for name in "${skills[@]}"; do
      local src="$CC_SRC/$name"
      if [ ! -d "$src" ] || ! is_skill_dir "$src"; then
        echo "  알 수 없는 스킬: $name" >&2
        echo "  사용 가능한 스킬:" >&2
        list_skills "$CC_SRC" >&2
        exit 1
      fi
      install_skill "$src" "$CC_DEST"
      CC_INSTALLED=$((CC_INSTALLED + 1))
    done
    local merged
    merged="$({ read_manifest "$CC_MANIFEST"; printf '%s\n' "${skills[@]}"; } | sort -u | awk 'NF')"
    write_manifest "$CC_MANIFEST" "$merged"
  fi
}

# ---- Codex ------------------------------------------------------------------

run_codex_install() {
  local skills=("$@")
  mkdir -p "$CODEX_DEST"
  echo "Codex → $CODEX_DEST"

  local current
  current="$(list_skills "$CODEX_SRC")"

  if [ "${#skills[@]}" -eq 0 ]; then
    prune_orphans "$CODEX_DEST" "$CODEX_MANIFEST" "$current"
    local d
    for d in "$CODEX_SRC"/*/; do
      [ -d "$d" ] || continue
      is_skill_dir "$d" || continue
      install_skill "$d" "$CODEX_DEST"
      CODEX_INSTALLED=$((CODEX_INSTALLED + 1))
    done
    write_manifest "$CODEX_MANIFEST" "$current"
  else
    local name
    for name in "${skills[@]}"; do
      local src="$CODEX_SRC/$name"
      if [ ! -d "$src" ] || ! is_skill_dir "$src"; then
        echo "  알 수 없는 스킬: $name" >&2
        echo "  사용 가능한 스킬:" >&2
        list_skills "$CODEX_SRC" >&2
        exit 1
      fi
      install_skill "$src" "$CODEX_DEST"
      CODEX_INSTALLED=$((CODEX_INSTALLED + 1))
    done
    local merged
    merged="$({ read_manifest "$CODEX_MANIFEST"; printf '%s\n' "${skills[@]}"; } | sort -u | awk 'NF')"
    write_manifest "$CODEX_MANIFEST" "$merged"
  fi
}

# ---- usage ------------------------------------------------------------------

usage() {
  cat >&2 <<'EOF'
Usage:
  bash scripts/install.sh --cc                        Claude Code 전체 설치
  bash scripts/install.sh --codex                     Codex 전체 설치
  bash scripts/install.sh --all                       양쪽 전체 설치
  bash scripts/install.sh --cc <skill> [skill...]     Claude Code 특정 스킬
  bash scripts/install.sh --codex <skill> [skill...]  Codex 특정 스킬
  bash scripts/install.sh --list [--cc|--codex]       설치 가능한 스킬 목록
  bash scripts/install.sh --help                      이 도움말

Environment:
  CLAUDE_SKILLS_DIR   Claude Code 설치 경로 (default: ~/.claude/skills)
  CODEX_HOME          Codex 홈 경로 (default: ~/.codex)
EOF
}

# ---- main -------------------------------------------------------------------

if [ "$#" -eq 0 ]; then
  usage
  exit 1
fi

MODE=""
declare -a SKILLS=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --cc)
      MODE="cc"
      shift
      ;;
    --codex)
      MODE="codex"
      shift
      ;;
    --all)
      MODE="all"
      shift
      ;;
    --list)
      shift
      if [ "${1:-}" = "--cc" ]; then
        echo "=== Claude Code ==="
        list_skills "$CC_SRC"
      elif [ "${1:-}" = "--codex" ]; then
        echo "=== Codex ==="
        list_skills "$CODEX_SRC"
      else
        echo "=== Claude Code ==="
        list_skills "$CC_SRC"
        echo ""
        echo "=== Codex ==="
        list_skills "$CODEX_SRC"
      fi
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      SKILLS+=("$1")
      shift
      ;;
  esac
done

case "$MODE" in
  cc)
    run_cc_install "${SKILLS[@]+"${SKILLS[@]}"}"
    ;;
  codex)
    run_codex_install "${SKILLS[@]+"${SKILLS[@]}"}"
    ;;
  all)
    run_cc_install
    echo ""
    run_codex_install
    ;;
  *)
    echo "Error: --cc / --codex / --all のいずれかを指定してください" >&2
    usage
    exit 1
    ;;
esac

echo ""
if [ "$CC_INSTALLED" -gt 0 ]; then
  msg="Claude Code: ${CC_INSTALLED}개 스킬 설치"
  [ "$CC_PRUNED" -gt 0 ] && msg+=" / ${CC_PRUNED}개 제거"
  echo "$msg → $CC_DEST"
  echo "Claude Code 를 재시작하면 설치된 스킬이 반영됩니다."
fi
if [ "$CODEX_INSTALLED" -gt 0 ]; then
  msg="Codex: ${CODEX_INSTALLED}개 스킬 설치"
  [ "$CODEX_PRUNED" -gt 0 ] && msg+=" / ${CODEX_PRUNED}개 제거"
  echo "$msg → $CODEX_DEST"
fi
