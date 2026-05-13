# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.1](https://github.com/yongwoon/ywc-agent-toolkit/compare/v1.0.0...v1.0.1) (2026-05-13)


### ### Fixed

* address CodeRabbit review — permissions completeness and deduplication ([714972c](https://github.com/yongwoon/ywc-agent-toolkit/commit/714972c1d1b829bbab45e68c5bbfd36e123ff768))
* pin release-please-action to full commit SHA for supply-chain security ([10f57b7](https://github.com/yongwoon/ywc-agent-toolkit/commit/10f57b73cb9bd8b7e03eaa9371bf94deaa65a0c9))
* use GitHub App token to allow release-please tags to trigger release.yml ([a970c21](https://github.com/yongwoon/ywc-agent-toolkit/commit/a970c2119b17956197a990c3c71bf5de77cf6877))


### ### Changed

* add check-readme-freshness hook for skill directory changes ([f4d7341](https://github.com/yongwoon/ywc-agent-toolkit/commit/f4d7341317ad835bd4ac72af6bb208a61ccac815))
* add CodeRabbit configuration ([f27ccbf](https://github.com/yongwoon/ywc-agent-toolkit/commit/f27ccbfc89ca1ccf78d897ecc21ec15245a82ef1))
* add comprehensive permissions and model config to claude settings ([661eb74](https://github.com/yongwoon/ywc-agent-toolkit/commit/661eb74cfbff826b30601e74db6eabee690fbb3f))
* add comprehensive permissions and model config to claude settings ([7fc06fd](https://github.com/yongwoon/ywc-agent-toolkit/commit/7fc06fda29c7fe8e838f96dd95d8396fe8b6fd8d))
* add README freshness hook and fix codex skill count ([6df2c94](https://github.com/yongwoon/ywc-agent-toolkit/commit/6df2c94a36973a82ad5e84e2daddd094db7e1a74))
* retrigger release-please after app installation fix ([a4249f0](https://github.com/yongwoon/ywc-agent-toolkit/commit/a4249f090432983f4b250df59caadb454f709d25))
* retrigger release-please with correct app credentials ([ae3acd1](https://github.com/yongwoon/ywc-agent-toolkit/commit/ae3acd1793d62ee06e7e494e357a67c3ed6b78eb))
* retrigger release-please with correct app id ([7e64450](https://github.com/yongwoon/ywc-agent-toolkit/commit/7e64450e55c4e28f72f96adcc6c07e7435a12f8f))
* trigger release-please workflow ([e5454f8](https://github.com/yongwoon/ywc-agent-toolkit/commit/e5454f829388302ef64fd297a3938baf59bea514))


### ### Documentation

* fix codex skill count and update install example ([cc1fe4b](https://github.com/yongwoon/ywc-agent-toolkit/commit/cc1fe4b1503067f2ee02f97842dcbc087126375f))

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
