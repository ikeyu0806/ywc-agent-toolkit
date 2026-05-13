# Review Response Patterns

## Comment Classification

| Type | Signal | Action |
|---|---|---|
| Code change request | "change", "fix", "update", "rename", "move" | Apply the fix, commit, reply with commit link |
| Question | "why", "what", "how", "?", "curious" | Reply with explanation, no code change |
| Suggestion (optional) | "nit", "consider", "maybe", "optional" | Evaluate, apply if low-cost, explain if skipped |
| Approval | "LGTM", "looks good", thumbs up | Reply with thanks |
| Blocker | "blocking", "must fix", "do not merge" | Prioritize fix, reply with resolution |

## Reply Templates

### Fixed
```
Fixed in [commit-hash](commit-url)
[Brief description of what changed]
```

### Explained (no change needed)
```
This is [reason]. [Evidence or reference].
Happy to discuss further if you see a concern I'm missing.
```

### Deferred
```
Good catch. Filed as [issue/todo] to address in a follow-up.
Keeping this PR focused on [current scope].
```

## Safety Rules

- Never force-push after review comments exist
- Never amend commits that reviewers have already seen
- Batch fixes to the same file into a single commit
- If a comment is ambiguous, ask before changing code
