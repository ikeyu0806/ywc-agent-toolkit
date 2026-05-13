# Impact Questions

- Which packages directly depend on the changed package?
- Which apps depend on those packages transitively?
- Did the change modify a public interface, build config, or shared type?
- What is the minimum safe test scope?
- What is the minimum safe build scope?
- Are there package boundaries that this change weakens or crosses?
- Would this change have been safer if the dependency graph were clearer?
