# UI/UX Review - Hybrid Code & Live UI Auditor

静的 Code 分析と利用可能な browser tooling による Live UI 探索を組み合わせ、Project を UI/UX 観点で点検し、優先度別 Markdown report を生成する Codex Skill です。

## 概要

「どこから UX を直すべきか」に evidence ベースで答える Skill です。すべての finding は権威ある heuristic(Nielsen 10 / WCAG 2.2 AA / Material 3 / Apple HIG / Internal Design System)に基づいて citation が付与されます。

### 主な機能

- Hybrid Review: 静的 Code 分析 + Live UI 探索
- 重点 Domain: Information Architecture, Visual Design
- Critical / High / Medium / Low の 4 段階出力
- すべての finding に location と heuristic citation を付与
- Accessibility tree、screenshot、console、computed style など利用可能な evidence を効率的に収集

## 使用方法

```text
http://localhost:3000 の dashboard を UI/UX review してください。
```

```text
Settings flow の usability と Information Architecture を audit してください。
```

自然言語 Trigger は [SKILL.md](./SKILL.md) に定義されています。

## Reference

- Domain checklist と heuristic citation は [`references/`](./references) にあります
- Report template は [`assets/`](./assets) にあります
- Workflow と Trigger は [SKILL.md](./SKILL.md) にあります

## Live UI Tooling

本 Skill は Codex 環境で利用可能な browser tooling を使用します。Playwright、browser MCP、Chrome DevTools MCP、screenshot、accessibility snapshot、console inspection、computed style check などを状況に応じて使い、Live browser tool がない場合は code-only review として制約を記録します。

## Localized Versions

- [Korean (Primary)](./README.md)
- [English](./README.en.md)
- [Korean (Summary)](./README.ko.md)
