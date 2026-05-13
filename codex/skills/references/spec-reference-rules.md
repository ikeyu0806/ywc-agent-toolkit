# Spec Reference Rules

Every task's `README.md` must include a `## Spec Reference` section. This section specifies the source-of-truth documents that the agent or developer executing the task must read **before implementation**.

Since LLMs do not retain full project context when executing tasks, explicitly linking specs here significantly reduces hallucination and scope creep.

## Required Structure

### 1. Primary Sources

List source-of-truth documents. Each entry should include the specific section or anchor.

- **Default: project-relative paths only** (for example, `docs/prd/auth.md#token-rotation`). This works in offline environments and allows drift tracking via version control.
- **External URLs** (Notion, Confluence, Figma, and similar) should only be used when the project explicitly allows it. See the `ywc-sequential-executor` external URL policy for the project-level rule.
- **For tasks with no spec** (for example, pure lint setup or housekeeping), mark as `N/A — no external spec (housekeeping / refactor / config only)`.

### 2. Summary

Write a 2-5 sentence summary. The purpose is to provide enough orientation for the implementer to start without opening every link.

- The linked sources above are the source of truth; this summary is for quick understanding.
- If the link and summary diverge, **trust the link and flag the drift**.

### 3. Out of Scope (from spec)

List items mentioned in the spec that are intentionally not addressed in this task. This prevents implementers from expanding scope because something seems natural.

- When handled by another task, specify that task's name.

## Cross-Task Scope Handoff

When a spec item is intentionally deferred, name the receiving task in `Out of Scope (from spec)` and ensure the receiving task lists the same source in `Primary Sources`.

## Hard Rule

**Never leave Spec Reference empty or omit it** — use `N/A` when there is no spec. An empty section makes it impossible for the implementer to tell whether it was forgotten or genuinely absent.
