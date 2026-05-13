# React + TypeScript Patterns

Use this reference when the task needs concrete implementation guidance beyond the main workflow.

## Component Boundaries

- Keep server or transport shapes out of presentational components when a small adapter can normalize them once.
- Type props at the component boundary instead of relying on inferred spread objects from distant callers.
- Extract a hook when logic is reused or when state/effects overwhelm the JSX, not just to shorten a file.

## State

- Store the minimum state needed to recreate the UI.
- Derive filtered lists, counts, labels, and booleans from source state instead of persisting them separately.
- Keep transient UI state local unless multiple distant consumers actually need shared ownership.

## Effects

- Effects should sync with something external: network, timer, DOM API, subscription, URL, storage.
- If an effect only computes a value from props or state, move that logic into render or a helper.
- Make async effects cancellation-aware when stale responses could overwrite newer state.

## TypeScript

- Prefer `unknown` plus narrowing over `any`.
- Prefer discriminated unions for multi-state UI flows.
- Prefer small typed adapters for API data with optional or inconsistent fields.
- Use assertions sparingly and close to the place where the invariant is genuinely guaranteed.

## UI Reliability

- Handle loading, empty, error, and success states explicitly when data is remote.
- Keep button disabled states and submission guards aligned so duplicate actions are not possible.
- Preserve accessible names when replacing text with icons or spinners.

## Anti-Patterns

- Duplicated derived state.
- Effects that mirror props into state without a clear external sync requirement.
- Inline casts that hide nullable or partial data issues.
- Deep optional chaining in render paths where a single adapter would simplify the contract.
- Tests that only snapshot markup and miss changed user behavior.
