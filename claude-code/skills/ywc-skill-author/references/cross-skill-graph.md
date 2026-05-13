# Cross-Skill Graph

This document captures the dependency and cross-reference relationships among the 18 production ywc-* skills as of 2026-04. Use it to:

1. Decide whether a new skill needs `requires: [...]` and what to put there.
2. Decide what to write in the `Do not use for ... (use ywc-X)` portion of a new skill's description.
3. Detect overlap before creating a new skill (overlap usually means an existing skill should be extended instead).

## Dependency Graph (`requires:` declarations)

```text
ywc-tech-research
        │
        ▼
ywc-spec-validate                 (validates spec quality)
        │
        ▼
ywc-task-generator              (requires: [ywc-spec-validate])
        │
        ▼
ywc-code-gen                    (requires: [ywc-task-generator])
ywc-sequential-executor         (requires: [ywc-task-generator])
ywc-parallel-executor           (requires: [ywc-task-generator])
        │
        ▼
ywc-impl-review                 (no formal requires; runs after executors)
        │
        ▼
ywc-gen-testcase                (no formal requires; reads PR/Task/diff)
        │
        ▼
ywc-commit                      (standalone)
        │
        ▼
ywc-create-pr                   (no formal requires; calls ywc-commit internally)
        │
        ▼
ywc-handle-pr-reviews           (requires: [ywc-create-pr])
        │
        ▼
ywc-release-pr-list             (release flow; no formal requires)
```

Standalone / parallel skills (no requires):

- `ywc-security-audit` — runs against any code path; not pipeline-bound
- `ywc-ui-ux-review` — runs against running UI; not pipeline-bound
- `ywc-product-review` — runs against project state; not pipeline-bound
- `ywc-e2e-test-strategy` — runs after implementation; not pipeline-bound (init / audit / flow modes)
- `ywc-incident-postmortem` — runs reactively after production incidents; not part of dev pipeline
- `ywc-changelog-release-notes` — runs at release time; soft dependency on ywc-release-pr-list output
- `ywc-merge-dependabot` — independent of feature pipeline
- `ywc-project-scaffold` — pre-pipeline (used at project start)
- `ywc-project-docs` — independent documentation utility
- `ywc-skill-author` — meta-skill for authoring other skills

## Cross-Reference Table (`Do not use for ... (use ywc-X)`)

When skill A and skill B share trigger vocabulary, A's description should explicitly point to B for the case A does not handle. The pairs below are the existing cross-pointers documented in production:

| Skill | Anti-trigger pointing to |
|---|---|
| `ywc-commit` | PR creation → `ywc-create-pr` |
| `ywc-create-pr` | Existing PR review comments → `ywc-handle-pr-reviews` |
| `ywc-handle-pr-reviews` | Creating new PR → `ywc-create-pr`; performing code review → `ywc-impl-review` |
| `ywc-task-generator` | Spec review only → `ywc-spec-validate`; direct implementation → (none) |
| `ywc-code-gen` | Single-file edit → (none, ad-hoc); refactoring existing module → (none) |
| `ywc-impl-review` | Spec-only review → `ywc-spec-validate`; product review → `ywc-product-review` |
| `ywc-spec-validate` | Code-level review → `ywc-impl-review`; product review → `ywc-product-review` |
| `ywc-product-review` | Code review → `ywc-impl-review`; security review → `ywc-security-audit`; UI/UX review → `ywc-ui-ux-review` |
| `ywc-security-audit` | General code review → `ywc-impl-review`; product risk → `ywc-product-review` |
| `ywc-ui-ux-review` | Backend/API review → `ywc-impl-review`; product strategy review → `ywc-product-review` |
| `ywc-tech-research` | Spec writing → output goes to `ywc-spec-validate`; code gen → `ywc-code-gen` |
| `ywc-sequential-executor` | Parallel execution → `ywc-parallel-executor`; no task directory → `ywc-code-gen` |
| `ywc-parallel-executor` | Sequential tasks → `ywc-sequential-executor` |
| `ywc-gen-testcase` | Automated unit/integration tests → (none, dev-domain skill) |
| `ywc-e2e-test-strategy` | Manual verification test sheets → `ywc-gen-testcase`; security penetration testing → `ywc-security-audit`; unit/integration test generation → (none, dev-domain) |
| `ywc-merge-dependabot` | Feature PR merge → `ywc-create-pr` (or platform tools) |
| `ywc-release-pr-list` | Feature PR creation → `ywc-create-pr`; review comment handling → `ywc-handle-pr-reviews` |
| `ywc-project-scaffold` | Existing project modification → (none); task creation → `ywc-task-generator` |
| `ywc-project-docs` | Code comments → (none, in-source); root README → (none); implementation tasks → `ywc-task-generator` |
| `ywc-incident-postmortem` | Proactive security audit → `ywc-security-audit`; general code review → `ywc-impl-review`; release notes after patch → `ywc-changelog-release-notes` |
| `ywc-changelog-release-notes` | PR list generation → `ywc-release-pr-list`; committing changelog → `ywc-commit`; creating release PR → `ywc-create-pr`; incident postmortem → `ywc-incident-postmortem` |

## How to Use This Graph When Writing a New Skill

1. **Find the closest existing skill.** If your new skill's purpose is within ~80% of an existing one, **do not create a new skill** — extend the existing one. Splitting an over-similar pair causes activation collision.

2. **Identify upstream dependency.** If your skill relies on another ywc-* skill having run first (e.g., reading task directories, requiring a spec), declare `requires: [ywc-X]`. If the dependency is conventional but not strict, omit `requires:` and instead mention the upstream in `## Integration` body section.

3. **Identify potential collisions.** Look at the Cross-Reference Table for the closest 2-3 existing skills. Their description triggers tell you which natural-language phrases overlap with your new skill. Add `Do not use for ... (use ywc-X)` for each collision.

4. **Update this graph.** When adding a new skill, add it to:
   - The Dependency Graph (placement based on `requires:`)
   - The Cross-Reference Table (one row, listing each anti-trigger pointer)

## Spotting Overlap (Avoid Creating Duplicate Skills)

If the new skill matches one of these patterns, it is overlap with an existing skill — reconsider:

| New skill purpose | Already covered by |
|---|---|
| "Generate unit tests" | (separate from `ywc-gen-testcase`, which is for human verification testsheets) — but if the goal is test generation as part of code generation, use `ywc-code-gen`'s QA agent |
| "Lint check / typecheck before commit" | `ywc-create-pr` Step 5 (CI Check) |
| "Verify code matches spec" | `ywc-impl-review` Spec axis |
| "Find security vulnerabilities" | `ywc-security-audit` |
| "Decompose feature into tasks" | `ywc-task-generator` |
| "Run tasks in worktrees" | `ywc-parallel-executor` |
| "Stage selected files and commit" | `ywc-commit` |

When in doubt, propose the new skill to the user and ask whether to extend an existing one instead.

## Naming Conventions for New Skills

Pattern: `ywc-<verb-or-domain-noun>` — short, kebab-case, descriptive.

| Style | Examples (existing) | Use for |
|---|---|---|
| Verb-led | `ywc-create-pr`, `ywc-handle-pr-reviews`, `ywc-merge-dependabot` | Action-oriented skills |
| Domain noun + suffix | `ywc-impl-review`, `ywc-spec-validate`, `ywc-security-audit` | Review / audit skills |
| Compound noun | `ywc-task-generator`, `ywc-tech-research`, `ywc-gen-testcase` | Generator / produce-X skills |
| Executor pattern | `ywc-sequential-executor`, `ywc-parallel-executor` | Multi-task orchestration |

Avoid:

- Generic names like `ywc-helper`, `ywc-utility`
- Names ending in `-skill` (redundant)
- Names mentioning models or tools (`ywc-claude-X`, `ywc-gpt-X`)

## Last Updated

This graph reflects the state at commit `9851518` (2026-04-30). Re-audit when new skills are added or when significant restructuring happens.
