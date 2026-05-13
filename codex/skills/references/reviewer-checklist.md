# Reviewer Checklist

Load this reference when a deeper implementation-conformance pass is needed.

## Review Dimensions

1. **Spec Conformance** — Verify every stated requirement, request/response format, edge case, and out-of-scope boundary.
2. **Code Quality** — Check readability, maintainability, duplication, naming, and error handling.
3. **Pattern Consistency** — Confirm directory structure, imports, style, and local helper usage match the repository.
4. **Completeness** — Check tests, migrations, environment variables, documentation, and feature wiring.
5. **Simplicity** — Check whether the implementation uses the minimum code necessary to satisfy the spec.
6. **Surgical Changes** — Check whether every changed file and line traces to the declared spec, task, or ownership scope.
7. **Module Interface Quality** — Check whether new public interfaces hide complexity, or whether shallow module proliferation creates extra indirection.

## Additional Checks

### Simplicity

- Does the implementation add features, abstractions, or flexibility beyond the spec?
- Are there implementations significantly longer than the spec requires? For a simple spec, flag functions over roughly 50 lines or new files over roughly 150 lines for review.
- Are there abstractions designed for single-use code?
- Would a senior engineer say this is overcomplicated?

### Surgical Changes

- Were files modified outside the task's declared Ownership?
- Were adjacent code, comments, or formatting improved without being the task's subject?
- Do all changed lines trace directly to a requirement in the spec or task?
- Are there unrelated refactors of pre-existing code?

### Module Interface Quality

Avoid shallow module proliferation: many small modules with complex interfaces can create a maze that neither humans nor future AI sessions can navigate.

- Does each new module expose a simple interface relative to its implementation depth?
- Are there multiple small single-purpose modules that could be one deeper module with a cleaner public API?
- Can a developer entering this code understand the entry point without tracing through three or more layers of indirection?
- Do public interfaces hide complexity, or do they leak implementation details?

When shallow modules are found, flag them as `Low` unless they create a concrete behavioral or maintainability risk that warrants a higher severity. Recommend drafting the simplified target interface and scheduling a dedicated refactoring task via `ywc-plan`; do not fold consolidation into the current task unless the current spec explicitly requires it.

## Severity Guide

| Severity | Criteria |
|---|---|
| Critical | Requirement missing, runtime error, data loss risk, or broken core workflow |
| High | Major spec deviation, unsafe behavior, or missing important edge case |
| Medium | Localized bug, pattern mismatch with maintenance cost, or incomplete secondary behavior |
| Low | Minor refactor, readability, or polish issue |

Review depth prioritization: apply the Gray Box principle. Public API boundaries, exported functions, shared contracts, and DB schema changes deserve deeper scrutiny because bugs propagate through those boundaries. Internal implementation details that satisfy the interface should usually be `Low` unless they touch a critical execution path such as payments, auth, or data migration.

## Finding Format

```text
[Severity] path:line — issue
Category: Spec Conformance | Code Quality | Pattern Consistency | Completeness
Recommendation: concrete fix
```

Prioritize behavioral and spec issues over style-only comments.
