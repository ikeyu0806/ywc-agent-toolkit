# Contributing to ywc-agent-toolkit

Thank you for your interest in contributing! This guide explains how to submit bug reports, skill improvements, new skills, and translations.

## Table of Contents

- [How to contribute](#how-to-contribute)
- [Development setup](#development-setup)
- [Skill authoring rules](#skill-authoring-rules)
- [Translations](#translations)
- [Commit message conventions](#commit-message-conventions)
- [Pull request process](#pull-request-process)
- [CI requirements](#ci-requirements)

---

## How to contribute

| Contribution type | How |
|-------------------|-----|
| Bug report | Open an [issue](../../issues/new?template=bug_report.md) |
| Skill improvement | Open an issue or submit a PR |
| New skill | Open a [new skill issue](../../issues/new?template=new_skill.md) first, then PR |
| Translation | Open a [translation issue](../../issues/new?template=translation.md) or submit a PR directly |

---

## Development setup

```bash
# Fork and clone your fork
git clone https://github.com/<your-username>/ywc-agent-toolkit.git
cd ywc-agent-toolkit

# Create a feature branch
git checkout -b feat/your-skill-name

# Test the install script locally
bash scripts/install.sh --list
bash scripts/install.sh --cc ywc-plan   # install a single skill for testing
```

---

## Skill authoring rules

### Directory structure

```
claude-code/skills/<skill-name>/
├── SKILL.md          # required — skill definition
├── README.md         # required — English usage guide
├── README.ja.md      # optional — Japanese
├── README.ko.md      # optional — Korean
├── README.zh.md      # optional — Chinese
├── README.es.md      # optional — Spanish
└── references/       # optional — reference documents loaded by the skill
```

### SKILL.md frontmatter (required fields)

```yaml
---
name: ywc-your-skill-name
description: >
  One or two sentences describing WHEN this skill activates and WHAT it does.
  Include trigger phrases so Claude can match user intent.
---
```

### Naming conventions

- Skill directory: `ywc-<kebab-case>` (Claude Code) or `<kebab-case>` (Codex general skills)
- Follow the patterns in [ywc-skill-author](claude-code/skills/ywc-skill-author/SKILL.md)

### Before submitting a new skill PR

- [ ] `SKILL.md` has `name:` and `description:` frontmatter
- [ ] `README.md` (English) is included with usage examples
- [ ] The skill is general-purpose (not specific to a single project)
- [ ] `bash scripts/install.sh --list` still works after your change

---

## Translations

Translations are very welcome and are labeled `good first issue`.

### Supported languages

| Code | Language |
|------|----------|
| `en` | English (default — canonical source, do not submit translation PRs for this) |
| `ja` | Japanese |
| `ko` | Korean |
| `zh` | Chinese (Simplified) |
| `es` | Spanish |

### How to add a translation

1. Find a `README.md` that has not yet been translated into your language
2. Create `README.<lang>.md` in the same directory
3. Translate the full content from `README.md`
4. Submit a PR with the label `i18n:<lang>`

### Translation sync

When an English source (`README.md`) changes, CI will post an informational warning on PRs that update English without also updating translations. You are not required to update all languages in a single PR — the warning is informational only.

---

## Commit message conventions

```
<type>: <short description>

[optional body]
```

| Type | Use for |
|------|---------|
| `feat` | New skill or feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `i18n` | Translation |
| `ci` | CI/CD changes |
| `chore` | Maintenance (scripts, config) |

Examples:

```
feat: add ywc-api-design skill
fix: install.sh prune not working on partial install
i18n: add Japanese translation for ywc-plan README
```

---

## Pull request process

1. Ensure CI passes (skill validation, shellcheck, markdownlint)
2. Fill in the PR template completely
3. Link the related issue if one exists
4. A maintainer will review and merge

**Note**: Only the maintainer (@yongwoon) can merge PRs and create releases.

---

## CI requirements

All PRs must pass:

| Check | What it verifies |
|-------|-----------------|
| `validate` | Every skill has `SKILL.md` with `name:` and `description:` frontmatter |
| `shellcheck` | `scripts/install.sh` has no shell script errors |
| `markdownlint` | README files pass basic Markdown formatting rules |

The translation check posts an **informational warning** only — it does not block merging.
