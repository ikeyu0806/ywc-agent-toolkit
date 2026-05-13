#!/usr/bin/env bash
# fetch-unresolved-comments.sh <owner/repo> <pr-number>

set -euo pipefail

REPO="${1:-}"
PR_NUMBER="${2:-}"

if [ -z "$REPO" ] || [ -z "$PR_NUMBER" ]; then
  echo "Usage: fetch-unresolved-comments.sh <owner/repo> <pr-number>" >&2
  exit 2
fi

CURRENT_USER=$(gh api user --jq .login 2>/dev/null) || {
  echo "ERROR: gh CLI not authenticated or API unreachable" >&2
  exit 1
}

gh api "repos/${REPO}/pulls/${PR_NUMBER}/comments" --paginate 2>/dev/null \
  | jq --arg me "$CURRENT_USER" '
    group_by(.in_reply_to_id // .id)
    | map(
        sort_by(.created_at)
        | {
            comments: .,
            root: .[0],
            addressed: (map(.body) | any(test("<!--\\s*<review_comment_addressed>\\s*-->"))),
            my_replies: (map(select(.user.login == $me)) | sort_by(.created_at)),
            reviewer_comments: (map(select(.user.login != $me)) | sort_by(.created_at))
          }
      )
    | map(select(
        .addressed == false
        and (
          (.my_replies | length) == 0
          or (
            (.reviewer_comments | length) > 0
            and (.my_replies | last | .created_at) < (.reviewer_comments | last | .created_at)
          )
        )
      ))
    | map({
        id: .root.id,
        in_reply_to_id: .root.in_reply_to_id,
        body: .root.body,
        path: .root.path,
        line: (.root.line // .root.original_line),
        user: .root.user.login,
        created_at: .root.created_at,
        thread_comment_count: (.comments | length)
      })
  '
