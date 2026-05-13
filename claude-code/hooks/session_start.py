#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
SessionStart Hook
=================
Triggered when Claude Code starts or resumes a session.

With --load-context flag, injects the following into Claude's context:
- Session start timestamp and source (startup/resume/clear)
- Current git branch and uncommitted file count
- Contents of .claude/CONTEXT.md, .claude/TODO.md, TODO.md (if they exist)
- Recent open GitHub issues (if gh CLI is available)

Usage in settings.json:
  "command": "uv run .claude/hooks/session_start.py --load-context"

Source: https://github.com/disler/claude-code-hooks-mastery
"""

import argparse
import json
import sys
import subprocess
from pathlib import Path
from datetime import datetime

LOG_DIR = Path.home() / ".claude" / "hooks-logs"


def log_session_start(input_data: dict) -> None:
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        log_file = LOG_DIR / f"{datetime.now().strftime('%Y-%m-%d')}.jsonl"
        entry = {"ts": datetime.now().isoformat(), "hook": "session-start", **input_data}
        with open(log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass


def get_git_status():
    try:
        branch_result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=5
        )
        current_branch = branch_result.stdout.strip() if branch_result.returncode == 0 else "unknown"

        status_result = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, timeout=5
        )
        if status_result.returncode == 0:
            changes = status_result.stdout.strip().split("\n") if status_result.stdout.strip() else []
            uncommitted_count = len(changes)
        else:
            uncommitted_count = 0

        return current_branch, uncommitted_count
    except Exception:
        return None, None


def get_recent_issues():
    try:
        gh_check = subprocess.run(["which", "gh"], capture_output=True)
        if gh_check.returncode != 0:
            return None

        result = subprocess.run(
            ["gh", "issue", "list", "--limit", "5", "--state", "open"],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except Exception:
        pass
    return None


def load_development_context(source):
    context_parts = []

    context_parts.append(f"Session started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    context_parts.append(f"Session source: {source}")

    branch, changes = get_git_status()
    if branch:
        context_parts.append(f"Git branch: {branch}")
        if changes and changes > 0:
            context_parts.append(f"Uncommitted changes: {changes} files")

    context_files = [
        ".claude/CONTEXT.md",
        ".claude/TODO.md",
        "TODO.md",
        ".github/ISSUE_TEMPLATE.md",
    ]

    for file_path in context_files:
        if Path(file_path).exists():
            try:
                with open(file_path, "r") as f:
                    content = f.read().strip()
                    if content:
                        context_parts.append(f"\n--- Content from {file_path} ---")
                        context_parts.append(content[:1000])
            except Exception:
                pass

    issues = get_recent_issues()
    if issues:
        context_parts.append("\n--- Recent GitHub Issues ---")
        context_parts.append(issues)

    return "\n".join(context_parts)


def main():
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument("--load-context", action="store_true",
                            help="Inject git status and project context into Claude's context")
        args = parser.parse_args()

        input_data = json.loads(sys.stdin.read())
        source = input_data.get("source", "unknown")

        log_session_start(input_data)

        if args.load_context:
            context = load_development_context(source)
            if context:
                output = {
                    "hookSpecificOutput": {
                        "hookEventName": "SessionStart",
                        "additionalContext": context
                    }
                }
                print(json.dumps(output))
                sys.exit(0)

        sys.exit(0)

    except (json.JSONDecodeError, Exception):
        sys.exit(0)


if __name__ == "__main__":
    main()
