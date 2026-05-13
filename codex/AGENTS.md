# Repository Guidelines

## Project Structure & Module Organization

This repository is a portable skill bundle for Claude Code and Codex.

Codex skills live under `codex/skills/` in a flat `codex/skills/<skill-name>/` structure.
Each skill keeps its main instructions in `SKILL.md`, with optional supporting material in `references/`.
Shared bundle metadata sits at the root: `README.md`, `CHANGELOG.md`, `VERSION`.
Installation logic lives in `scripts/install.sh`.

## Build, Test, and Development Commands

- `bash scripts/install.sh --codex`: copies every skill under `codex/skills/` into `${CODEX_HOME:-~/.codex}/skills`
- `bash scripts/install.sh --codex ywc-task-generator ywc-tech-research`: installs only the specified skills
- `bash scripts/install.sh --list --codex`: list all available Codex skills
- `find codex/skills -maxdepth 3 -type f`: quick check that the bundle contains the expected skill files
- `git diff --stat`: review scope before committing documentation or skill changes

There is no project build pipeline or package manager in this repository.
Development is primarily editing Markdown and shell scripts.

## Coding Style & Naming Conventions

Use concise, instructional Markdown with short sections and concrete examples.
Keep directory names lowercase with hyphens, matching installed skill names such as `ywc-tech-research`.
Keep shell scripts portable Bash with `set -euo pipefail`.

Bundle-level documentation aimed at repository users should be written in Korean unless there is a specific reason to use English.
