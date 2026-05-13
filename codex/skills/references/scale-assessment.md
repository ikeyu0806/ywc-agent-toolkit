# Scale Assessment Heuristics

Use this reference when the scale rubric in `SKILL.md` does not give an obvious answer.

## Default Bias

When ambiguous, always default to Medium.

- Cost of writing a spec for an actually-Small change: about one hour wasted, with little rework.
- Cost of skipping a spec for an actually-Medium change: rework, scope drift, and poor decomposition.

## Hard Disqualifiers from Small

Any one of these forces Medium minimum, regardless of LOC count:

| Trigger | Reason |
|---|---|
| Database migration / schema change | Migration must become its own task. |
| New library / framework introduction | Library introduction must become its own task. |
| New API contract consumed by services or clients | Contract changes need coordination and compatibility planning. |
| Authentication / authorization logic touched | Security-sensitive behavior needs spec review. |
| Cross-cutting concern modified across more than one module | Pattern changes ripple across the codebase. |
| Public API breaking change | Backward-compatibility planning is required. |

## Borderline Examples

### Add a field to the user profile API response

- Files touched: 2-3
- LOC: about 50
- DB migration: yes
- Verdict: Medium, because DB migration is a hard disqualifier.

### Fix 500 error in CSV export when input has a UTF-8 BOM

- Files touched: 1-2
- LOC: about 30
- DB migration: no
- New library: no
- API contract: unchanged
- Verdict: Small, because it is a single-concern bug fix with no disqualifiers.

### Add a settings page for notification preferences

- Files touched: about 10
- LOC: about 400
- DB migration: yes
- Verdict: Medium, because it spans UI, API, DB, and migration work.

### Refactor email sending to use a queue

- Files touched: 3-5
- LOC: about 200
- New library: possible
- Cross-cutting: yes
- Verdict: Medium, because the change affects callers and may introduce infrastructure.

### Rename `getUserData` to `fetchUser` everywhere

- Files touched: many
- LOC: many, but mechanical
- DB migration: no
- New library: no
- Behavioral change: no
- Verdict: Small, because it is a mechanical rename with no behavior change.

## Tie-Breakers

| Tie | Decision rule |
|---|---|
| Small vs Medium | Choose Medium. |
| Medium vs Large | If expected task count is 12-18, choose Medium. If 18+, choose Large and recommend splitting. |
| Large vs multiple specs | Split when feature boundaries are separable; keep one Large spec when the work is tightly coupled. |

## When to Stop Investigating

Stop reading code once you can confidently:

1. Pick a scale using the rubric.
2. Name concrete files or paths in the plan/spec.
3. State the project's actual lint, test, build, or verification commands.

Do not turn planning into open-ended debugging or implementation investigation.
