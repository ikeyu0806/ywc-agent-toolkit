# ywc-agent-toolkit

A collection of skills for **Claude Code** and **Codex** that automates the full development workflow — from planning and spec writing to code generation, review, and release.

[日本語](README.ja.md) | [한국어](README.ko.md) | [中文](README.zh.md) | [Español](README.es.md)

## Supported Tools

| Tool | Skills | Install path |
|------|--------|-------------|
| Claude Code | 26 | `~/.claude/skills/` |
| Codex | 1 | `~/.codex/skills/` |

## Installation

### Quick install

```bash
git clone https://github.com/yongwoon/ywc-agent-toolkit.git
cd ywc-agent-toolkit

# Claude Code
bash scripts/install.sh --cc

# Codex
bash scripts/install.sh --codex

# Both
bash scripts/install.sh --all
```

### Install specific skills only

```bash
bash scripts/install.sh --cc ywc-plan ywc-commit ywc-create-pr
bash scripts/install.sh --codex ywc-ui-ux-review
```

### List available skills

```bash
bash scripts/install.sh --list
bash scripts/install.sh --list --cc
bash scripts/install.sh --list --codex
```

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_SKILLS_DIR` | `~/.claude/skills` | Override Claude Code install path |
| `CODEX_HOME` | `~/.codex` | Override Codex home path |

Restart Claude Code or Codex after installation for skills to take effect.

---

## Claude Code Skills

### Planning & Spec

| Skill | Description |
|-------|-------------|
| `ywc-plan` | Convert a rough idea into `plan.md` (Small) or a Spec document (Medium/Large) |
| `ywc-spec-writer` | Write and update spec documents (`docs/specification/`) |
| `ywc-spec-validate` | Validate spec quality (Completeness / Consistency / Feasibility) |
| `ywc-tech-research` | Research libraries and compare technical approaches |
| `ywc-ubiquitous-language` | Create and maintain a domain ubiquitous language dictionary |

### Task & Execution

| Skill | Description |
|-------|-------------|
| `ywc-task-generator` | Decompose a spec into dependency-safe tasks |
| `ywc-sequential-executor` | Execute tasks sequentially (Branch → Implement → Commit → PR → Merge) |
| `ywc-parallel-executor` | Execute tasks in parallel using Git worktree isolation |
| `ywc-code-gen` | Generate Backend + Frontend + QA code in parallel |

### Review & Verification

| Skill | Description |
|-------|-------------|
| `ywc-impl-review` | Verify implementation across Spec / Security / QA axes |
| `ywc-security-audit` | Security audit based on OWASP Top 10 |
| `ywc-ui-ux-review` | UI/UX review (IA + Visual design + WCAG 2.2 AA) |
| `ywc-product-review` | Product feedback across 5 business dimensions |
| `ywc-gen-testcase` | Generate test sheets from PRs or tasks |
| `ywc-e2e-test-strategy` | Design Playwright E2E test strategy |

### Git & Release

| Skill | Description |
|-------|-------------|
| `ywc-commit` | Stage and commit session work |
| `ywc-create-pr` | Commit and create a Draft PR |
| `ywc-handle-pr-reviews` | Automate PR review responses |
| `ywc-finish-branch` | Full branch delivery (CI → merge → cleanup) |
| `ywc-merge-dependabot` | Auto-merge Dependabot PRs |
| `ywc-release-pr-list` | Summarize PRs included in a release |
| `ywc-changelog-release-notes` | Generate CHANGELOG entries and user-facing release notes |

### Documentation & Other

| Skill | Description |
|-------|-------------|
| `ywc-project-scaffold` | Generate directory structure for any language/framework |
| `ywc-project-docs` | Generate project documentation in Korean or Japanese |
| `ywc-incident-postmortem` | Write a structured postmortem after a production incident |
| `ywc-skill-author` | (Meta) Rules for authoring new `ywc-*` skills |

---

## Codex Skills

| Skill | Description |
|-------|-------------|
| `ywc-ui-ux-review` | UI/UX review (IA + Visual design + WCAG 2.2 AA) |

---

## Recommended Development Pipeline

```
ywc-tech-research        # (optional) research before starting
  ↓
ywc-plan                 # rough idea → plan.md or spec
  ↓
ywc-spec-writer          # write or update the spec
  ↓
ywc-spec-validate        # validate spec quality
  ↓
ywc-task-generator       # decompose spec into tasks
  ↓
ywc-sequential-executor  # or ywc-parallel-executor
  ↓
ywc-impl-review          # verify implementation
  ↓
ywc-gen-testcase         # generate test sheet
  ↓
ywc-commit → ywc-create-pr → ywc-handle-pr-reviews
```

---

## Hooks (coming soon)

`claude-code/hooks/` and `codex/hooks/` will contain automation hooks:

- `PostToolUse` — auto format/lint after file edits
- `Stop` — build verification at session end

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR.

- **Bug reports & skill improvements**: open an issue or PR
- **New skills**: follow the [ywc-skill-author](claude-code/skills/ywc-skill-author/SKILL.md) guidelines
- **Translations**: see the [translation guide](CONTRIBUTING.md#translations)

## License

MIT
