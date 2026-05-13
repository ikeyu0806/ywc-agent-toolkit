# QA Generation Reference

Load this reference when the user explicitly authorizes delegated or parallel implementation work and test generation is needed.

## Targets

1. Unit tests for isolated logic
2. Integration tests across API, database, or component boundaries
3. End-to-end scenarios for user-visible workflows

## Coverage Categories

| Category | What to cover |
|---|---|
| Happy path | Expected successful behavior |
| Edge case | Empty values, boundaries, optional fields, maximum sizes |
| Error path | Invalid input, authorization failures, unavailable dependencies |

## Standards

- Follow the existing test runner, fixtures, and naming patterns.
- Prefer real behavior verification over excessive mocks.
- Use specific assertions rather than truthy checks.
- Include regression tests for previously broken behavior when context exists.
- Do not create empty test shells or placeholder assertions.

## Output Checklist

- Test files and target code paths
- Coverage summary by unit, integration, and E2E scenario
- Remaining manual checks
- Commands used to run or verify tests
