# UI/UX Review - Hybrid Code & Live UI Auditor

A Codex Skill that audits a project from a UI/UX perspective by combining static code analysis with live UI exploration through available browser tooling, and produces a prioritized Markdown report.

## Overview

This Skill answers "where should we improve UX first?" with evidence-backed findings. Every issue cites an authoritative heuristic (Nielsen 10 / WCAG 2.2 AA / Material 3 / Apple HIG / internal design system).

### Key Features

- Hybrid review: static code analysis + live UI exploration
- Focus areas: Information Architecture, Visual Design
- Four-tier severity output: Critical / High / Medium / Low
- Every finding carries a location and a heuristic citation
- Evidence-efficient via accessibility trees, screenshots, console inspection, and computed-style checks where available

## Usage

```text
Review the UI/UX of http://localhost:3000 — focus on the dashboard.
```

```text
Audit usability and Information Architecture of the settings flow.
```

Natural-language triggers are defined in [SKILL.md](./SKILL.md).

## References

- Domain checklists and heuristic citations live under [`references/`](./references)
- Report scaffold lives under [`assets/`](./assets)
- Workflow and trigger phrases are defined in [SKILL.md](./SKILL.md)

## Live UI Tooling

This Skill uses the browser tooling available in the Codex environment, such as Playwright, browser MCP tools, Chrome DevTools MCP, screenshots, accessibility snapshots, console inspection, and computed-style checks. If no live browser tool is available, it falls back to code-only review and records that limitation.

## Localized Versions

- [Korean (Primary)](./README.md)
- [Japanese](./README.ja.md)
- [Korean (Summary)](./README.ko.md)
