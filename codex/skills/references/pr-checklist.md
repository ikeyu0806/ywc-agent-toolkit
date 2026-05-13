# PR Creation Checklist

## Before Committing

- Are all changes logically grouped into coherent commits?
- Are unrelated changes separated into distinct commits?
- Does each commit message follow the repository's convention?
- Are no secrets, `.env` files, or credentials staged?
- Were staged, unstaged, and branch-level diffs checked for common token patterns such as `AKIA`, `sk-`, `ghp_`, `github_pat_`, `xoxb-`, `AIza`, PEM private keys, `password=`, `token=`, `Bearer`, or `DATABASE_URL=`?

## PR Content

- Does the title describe the change in under 70 characters?
- Is the PR body filled using the repository's template?
- Are testing steps or verification evidence included?
- Are risks or follow-up items called out?

## CI Check (Pre-push)

- Have lint, format, typecheck, and test checks been run locally?
- Did all checks pass? If not, were failures addressed or explicitly skipped by the user?

## Before Opening

- Is the base branch correct (`develop`, `main`, or as specified)?
- Is the branch pushed to remote?
- Is the PR opened as draft when appropriate?
- Are there existing open PRs for the same branch?
