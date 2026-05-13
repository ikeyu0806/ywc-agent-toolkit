# QA Checklist

Load this reference when assessing whether the implementation has adequate automated or manual verification.

## Coverage Assessment

1. Do test files exist for the changed implementation files?
2. Are the spec's acceptance criteria mapped to tests?
3. Are unit, integration, and end-to-end boundaries covered appropriately?
4. Do tests cover happy paths, edge cases, and error paths?
5. Are assertions specific enough to catch regressions?

## Gap Areas

| Area | Examples |
|---|---|
| Boundary values | Empty input, null, undefined, max length, zero, negative numbers |
| Authorization | No auth, another user's resource, role-based access |
| Concurrency | Duplicate submissions, race conditions, retries |
| External dependencies | Network failure, timeout, rate limit |
| Data integrity | Cascade delete, duplicate creation, referential integrity |

## Severity Guide

| Severity | Criteria |
|---|---|
| Critical | No tests for core business logic or release-blocking workflow |
| High | Missing tests for major error paths, auth, data integrity, or migration behavior |
| Medium | Missing secondary scenarios or weak assertions |
| Low | Test readability or organization improvement |

## Finding Format

```text
[Severity] target path — missing test scenario
Recommendation: specific test to add
```
