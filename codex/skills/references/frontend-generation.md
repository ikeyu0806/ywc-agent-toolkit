# Frontend Generation Reference

Load this reference when the user explicitly authorizes delegated or parallel implementation work and a frontend slice is needed.

## Targets

1. Pages, layouts, and reusable UI components
2. Data-fetching hooks or server-state bindings
3. Client state where required by the existing architecture
4. Props and API response types

## Standards

- Follow existing component, routing, styling, and design-system patterns.
- Use the repository's UI library and icon conventions.
- Include loading, empty, error, and permission-denied states where relevant.
- Preserve accessibility: semantic HTML, labels, keyboard behavior, and focus states.
- Keep generated UI testable and avoid introducing broad state abstractions for a narrow feature.

## Output Checklist

- Generated files and their purpose
- Component hierarchy and key props
- API dependencies and data states
- Accessibility and responsive behavior notes
- Browser or component test coverage
