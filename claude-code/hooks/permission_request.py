#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
PermissionRequest Hook
======================
Triggered when Claude Code requests user permission for a tool call.

Behavior:
- Auto-allows read-only operations (Read, Glob, Grep, safe Bash commands)
  when invoked with --auto-allow flag
- Logs all permission requests to ~/.claude/hooks-logs/YYYY-MM-DD.jsonl

Usage in settings.json:
  "command": "uv run .claude/hooks/permission_request.py --auto-allow"

Source: https://github.com/disler/claude-code-hooks-mastery
"""

import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path

LOG_DIR = Path.home() / ".claude" / "hooks-logs"


# Operations that can be auto-allowed
SAFE_OPERATIONS: dict[str, object] = {
    "Read": lambda tool_input: True,
    "Write": lambda tool_input: True,
    "Edit": lambda tool_input: True,
    "MultiEdit": lambda tool_input: True,
    "Glob": lambda tool_input: True,
    "Grep": lambda tool_input: True,
    "Bash": lambda tool_input: is_safe_bash_command(tool_input.get("command", "")),
}

SAFE_BASH_COMMANDS = [
    r"^ls\b",
    r"^pwd\b",
    r"^echo\b",
    r"^cat\b(?!.*>)",
    r"^head\b",
    r"^tail\b",
    r"^wc\b",
    r"^which\b",
    r"^whereis\b",
    r"^type\b",
    r"^file\b",
    r"^stat\b",
    r"^git\s+(status|log|diff|show|branch|tag)\b",
    r"^git\s+remote\s+-v\b",
    r"^npm\s+(list|ls|outdated|view)\b",
    r"^pip\s+(list|show|freeze)\b",
    r"^uv\s+(pip\s+list|tree)\b",
    r"^python\s+--version\b",
    r"^node\s+--version\b",
    r"^npm\s+--version\b",
]


def is_safe_bash_command(command: str) -> bool:
    if not command:
        return False
    normalized = command.strip()
    for pattern in SAFE_BASH_COMMANDS:
        if re.search(pattern, normalized):
            return True
    return False


def should_auto_allow(tool_name: str, tool_input: dict) -> bool:
    checker = SAFE_OPERATIONS.get(tool_name)
    if checker:
        return checker(tool_input)
    return False


def log_permission_request(input_data: dict) -> None:
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        log_file = LOG_DIR / f"{datetime.now().strftime('%Y-%m-%d')}.jsonl"
        entry = {"ts": datetime.now().isoformat(), "hook": "permission-request", **input_data}
        with open(log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass


def main():
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument("--auto-allow", action="store_true",
                            help="Auto-allow read-only operations")
        parser.add_argument("--log-only", action="store_true",
                            help="Only log, do not make decisions")
        args = parser.parse_args()

        input_data = json.load(sys.stdin)

        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        hook_event_name = input_data.get("hook_event_name", "")

        if hook_event_name != "PermissionRequest":
            sys.exit(0)

        log_permission_request(input_data)

        if args.log_only:
            sys.exit(0)

        if args.auto_allow and should_auto_allow(tool_name, tool_input):
            response = {
                "hookSpecificOutput": {
                    "hookEventName": "PermissionRequest",
                    "decision": {"behavior": "allow"}
                }
            }
            print(json.dumps(response))
            sys.exit(0)

        sys.exit(0)

    except (json.JSONDecodeError, Exception):
        sys.exit(0)


if __name__ == "__main__":
    main()
