<!-- AUTO-GENERATED: This file was translated by Claude AI from README.en.md.
     Community review and corrections are welcome.
     Source: README.en.md | Language: Chinese (Simplified) -->

# UI/UX Review - 混合代码与实时界面审计工具

一个 Codex Skill，通过将静态代码分析与可用浏览器工具的实时界面探索相结合，从 UI/UX 角度审计项目，并生成按优先级排序的 Markdown 报告。

## 概述

此 Skill 以有据可查的发现回答"我们应该首先改进哪里的用户体验？"每个问题都引用权威的启发式准则（Nielsen 10 / WCAG 2.2 AA / Material 3 / Apple HIG / 内部设计系统）。

### 主要特性

- 混合审查：静态代码分析 + 实时界面探索
- 重点领域：信息架构、视觉设计
- 四级严重性输出：严重 / 高 / 中 / 低
- 每条发现均包含位置和启发式引用
- 在可用时通过无障碍树、截图、控制台检查和计算样式检查高效收集证据

## 用法

```text
Review the UI/UX of http://localhost:3000 — focus on the dashboard.
```

```text
Audit usability and Information Architecture of the settings flow.
```

自然语言触发词在 [SKILL.md](./SKILL.md) 中定义。

## 参考资料

- 各领域检查清单和启发式引用位于 [`references/`](./references)
- 报告模板位于 [`assets/`](./assets)
- 工作流程和触发短语在 [SKILL.md](./SKILL.md) 中定义

## 实时界面工具

此 Skill 使用 Codex 环境中可用的浏览器工具，例如 Playwright、浏览器 MCP 工具、Chrome DevTools MCP、截图、无障碍快照、控制台检查和计算样式检查。如果没有可用的实时浏览器工具，则回退到仅代码审查模式，并记录该限制。

## 本地化版本

- [韩语（主版本）](./README.md)
- [日语](./README.ja.md)
- [韩语（摘要）](./README.ko.md)
