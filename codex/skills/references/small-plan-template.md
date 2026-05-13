# Small Path: `plan.md` Template

Use this template when `ywc-plan` selects Small scale. The output is a single file at the user-specified path, defaulting to `./plan.md`.

## Structure

````markdown
# Plan: <one-line title>

> Status: Ready for implementation
> Scale: Small
> Created: YYYY-MM-DD

## Goal

<2-3 sentences answering what concrete change is being made and why.>

## Out of Scope

- <Excluded item 1, with reason>
- <Excluded item 2, with reason>

Use `N/A - none identified` only after actively considering adjacent scope.

## Files to Touch

| File | Change Type | Reason |
|---|---|---|
| `src/path/to/file.ts` | Modify | <one-line reason> |
| `src/path/to/test.spec.ts` | Add | Test coverage for the new behavior |

List concrete paths. Do not write "several files in src/".

## Implementation Steps

- [ ] Step 1: <Concrete action referencing a specific file, function, or behavior>
      -> verify: <concrete check, e.g. `npm test` passes or unit test for X returns Y>
- [ ] Step 2: <Concrete action>
      -> verify: <concrete check>
- [ ] Step 3: <Concrete action>
      -> verify: <concrete check>
- [ ] Step 4: Add or update tests in `<test path>`
      -> verify: new tests pass and no existing tests regress
- [ ] Step 5: Run verification
      -> verify: all commands in the Verification section exit 0

Each step should fit one focused edit. Include a concrete `-> verify:` check per step so success criteria are unambiguous.

## Verification

Run the project's actual commands collected during investigation:

```bash
<lint command>
<typecheck command>
<test command>
<build command>
```

Expected outcome: all commands exit 0, with no new warnings.

## Risks and Rollback

| Risk | Likelihood | Mitigation / Rollback |
|---|---|---|
| <Risk 1> | Low / Medium / High | <How to detect, how to revert> |

Use `N/A - no operational risk` only when the change is purely additive and self-contained.

## Acceptance Criteria

- [ ] <Observable outcome 1>
- [ ] <Observable outcome 2>
- [ ] Verification commands above all pass
````

## Worked Example

````markdown
# Plan: Strip UTF-8 BOM from CSV export input before parsing

> Status: Ready for implementation
> Scale: Small
> Created: 2026-05-01

## Goal

The CSV export endpoint returns 500 when an uploaded CSV contains a UTF-8 BOM. Strip the BOM defensively before parsing so the endpoint returns 200 with correct rows.

## Out of Scope

- Other character-encoding issues, such as UTF-16 or latin-1, are deferred.
- General CSV parser replacement is deferred.
- Frontend upload UX changes are not part of this server-side fix.

## Files to Touch

| File | Change Type | Reason |
|---|---|---|
| `api/src/routes/export/csv-import.ts` | Modify | Strip BOM before parsing |
| `api/src/routes/export/__tests__/csv-import.test.ts` | Modify | Add BOM input coverage |
| `api/src/routes/export/fixtures/with-bom.csv` | Add | Fixture containing UTF-8 BOM |

## Implementation Steps

- [ ] Add `with-bom.csv` fixture under `api/src/routes/export/fixtures/`.
      -> verify: fixture file exists and contains a leading UTF-8 BOM.
- [ ] In `csv-import.ts`, strip a leading BOM after reading the request body and before parsing.
      -> verify: parser receives content without the BOM prefix.
- [ ] Add a unit test in `csv-import.test.ts` that loads `with-bom.csv` and asserts a 200 response with parsed rows.
      -> verify: the new test fails before the parser change and passes after it.
- [ ] Run verification.
      -> verify: all commands in the Verification section exit 0.

## Verification

```bash
pnpm lint api/src/routes/export
pnpm typecheck
pnpm test api/src/routes/export
pnpm build
```

Expected outcome: all pass with no new warnings.

## Risks and Rollback

| Risk | Likelihood | Mitigation / Rollback |
|---|---|---|
| Stripping BOM could affect non-CSV content types | Low | Conditional on `Content-Type: text/csv`; revert by removing the strip line |

## Acceptance Criteria

- [ ] BOM-prefixed CSV uploads return 200 with all rows parsed.
- [ ] Non-BOM CSV uploads still return 200.
- [ ] Verification commands all pass.
````
