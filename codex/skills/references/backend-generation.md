# Backend Generation Reference

Load this reference when the user explicitly authorizes delegated or parallel implementation work and a backend slice is needed.

## Targets

1. API routes, request/response types, and validation
2. Service or use-case layer logic
3. Database migrations and seed data when required
4. Shared DTOs, enums, or generated types

## Standards

- Follow the repository's existing framework, ORM, route, and error-response patterns.
- Include input validation using the project's established validation library.
- Keep request and response contracts aligned with frontend and test generation.
- Use strict types where the language supports them.
- Separate migrations from feature logic when the repository's workflow expects isolated migration tasks.

## Output Checklist

- Generated files and their purpose
- API contract summary
- Schema or migration notes
- Environment variables or external dependencies
- Follow-up verification commands
