# Checkpoint and Resume - `ywc-sequential-executor`

Reference for `.ywc-run-state.json` and resume detection.

## Resume Detection

Run before Pre-flight:

```bash
test -f .ywc-run-state.json && cat .ywc-run-state.json || echo "no-state"
```

If the file exists:

1. `executor` must be `"sequential"`; if it is `"parallel"`, stop until the user deletes it or chooses the parallel executor.
2. If `last_checkpoint` is older than 48 hours, treat it as stale and ask whether to delete it and start fresh.
3. Compare `completed` against `<tasks-dir>/completed/`; warn on mismatch. If `current_step >= 2` and `branch` is set but missing locally, set `branch` to `null` and regress to Step 1.
4. Offer resume with checkpoint time, current task, step, and completed count.

## State File Format

```json
{
  "executor": "sequential",
  "args": "<original arguments>",
  "mode": "local-merge|draft|skip-ci-wait|normal",
  "tasks_dir": "tasks/",
  "range": ["<task-1>", "<task-2>"],
  "completed": [],
  "current_task": null,
  "current_step": 0,
  "branch": null,
  "started_at": "<ISO 8601 UTC>",
  "last_checkpoint": "<ISO 8601 UTC>"
}
```

## Checkpoint Events

| Event | Fields to update |
|---|---|
| Pre-flight passes | `started_at`, `range`, `mode`, `tasks_dir` |
| Step 2 complete | `current_task`, `current_step: 2`, `branch: "feature/<name>"` |
| Step 4 complete | `current_step: 4` |
| Step 5 complete (`ywc-finish-branch` returned `DONE`) | `current_step: 8` for resume compatibility; `branch: null` for `normal-pr`/`local-merge`; append completed task when finalized |
| Step 6 transition to next task | `current_task: <next-task>`, `current_step: 0` |
| All tasks done | remove `.ywc-run-state.json` |

## Manual Inspection

```bash
python <path-to-skill>/scripts/save-state.py
python <path-to-skill>/scripts/save-state.py --json
python <path-to-skill>/scripts/resume-state.py
python <path-to-skill>/scripts/resume-state.py --json
```

The file must be added to `.gitignore`.
