# Frontend Testing Notes

Use this reference when choosing how to verify a React and TypeScript change.

## Preferred Order

1. Run the narrowest existing unit or component test relevant to the change.
2. Add or update a focused React Testing Library test when behavior changed.
3. Use an end-to-end test only when the behavior depends on routing, browser integration, or full-page flows.

## Good Assertions

- visible text, labels, roles, and states
- enabled versus disabled actions
- loading and error transitions
- callback effects that are visible to the user
- navigation or URL changes when that is the feature

## Weak Assertions

- internal state values
- implementation-specific class names unless styling behavior itself changed
- snapshots without targeted behavior checks

## Closeout Evidence

When reporting verification, prefer exact commands and exact scope, for example:

- `pnpm test -- LoginForm`
- `npm run test -- --runInBand src/components/Table.test.tsx`
- `pnpm vitest run src/features/cart/useCart.test.ts`
- `pnpm playwright test tests/checkout.spec.ts`
