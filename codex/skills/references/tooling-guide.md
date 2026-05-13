# Monorepo Tooling Guide

## Signals to Check

- `turbo.json`: Turborepo task graph and caching
- `nx.json`: Nx project graph and affected commands
- `pnpm-workspace.yaml`: pnpm workspace membership
- root `package.json` with `workspaces`: npm or yarn workspace layout

## Questions to Answer

- Which tool owns dependency linking?
- Which tool owns build orchestration?
- Which commands support affected-only execution?
- Are there published packages or only internal packages?

## Common High-Risk Nodes

- shared UI libraries
- type packages
- API client packages
- root build config
- lint and TypeScript base config
