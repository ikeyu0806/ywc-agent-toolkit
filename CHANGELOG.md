# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-05-13

### Added
- 26 `ywc-*` Claude Code skills under `claude-code/skills/` covering planning, spec writing, code generation, review, testing, CI, release, and incident management
- 1 Codex skill (`ywc-ui-ux-review`) under `codex/skills/` with full reference assets
- Unified installer `scripts/install.sh` with `--cc`, `--codex`, `--all`, and `--list` flags
- Local validation script `scripts/validate.sh` mirroring CI checks
- Multilingual README support (en / ja / ko / es / zh) for all skills via tiered translation system
- `translations.json` configuration for language tier management (manual: en/ja/ko, AI-generated: es/zh)
- CI workflows: skill validation, markdownlint, translation-check, and automated GitHub Release on `v*` tags
- `claude-code/hooks/` and `codex/hooks/` directories for future hook extensions

### Fixed
- Codex skill validation in CI now treats `codex/skills/` as a single bundle, not per-subdirectory (#1)
- Added missing frontmatter checks and local `validate.sh` to mirror CI (#1)
- Resolved ShellCheck SC2115 warning and markdownlint configuration in CI

### Removed
- Non-`ywc-*` reference files, prompts, and scripts from `codex/skills/` that were unrelated to any `ywc-*` skill (#2)
  - 20 orphaned reference files (e.g., `backend-generation.md`, `automated-pr-review-loop.md`)
  - `prompts/implementer-base.md` (non-ywc code generation prompt)
  - `scripts/` directory (9 PR automation scripts)
