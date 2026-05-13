#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
Notification Hook - Sends Slack alerts when Claude needs user input.
Logs to: ~/.claude/hooks-logs/YYYY-MM-DD.jsonl

Setup: Set CCH_SLA_WEBHOOK environment variable to your Slack webhook URL.
"""

import json
import os
import sys
import urllib.request
from datetime import datetime
from pathlib import Path

SLACK_WEBHOOK = os.environ.get("CCH_SLA_WEBHOOK", "")
LOG_DIR = Path.home() / ".claude" / "hooks-logs"


def log(data: dict) -> None:
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        log_file = LOG_DIR / f"{datetime.now().strftime('%Y-%m-%d')}.jsonl"
        with open(log_file, "a") as f:
            f.write(json.dumps({"ts": datetime.now().isoformat(), "hook": "notify-permission", **data}) + "\n")
    except Exception:
        pass


def get_notification_type(data: dict) -> str:
    if ntype := data.get("notification_type"):
        return ntype
    msg = (data.get("message") or "").lower()
    if "permission" in msg or "approve" in msg:
        return "permission_prompt"
    if "idle" in msg or "waiting" in msg:
        return "idle_prompt"
    if "elicitation" in msg or "mcp" in msg:
        return "elicitation_dialog"
    return "notification"


def get_project_name(cwd: str | None) -> str:
    return Path(cwd).name if cwd else "unknown"


def get_emoji(ntype: str) -> str:
    return {"permission_prompt": "🔐", "idle_prompt": "💤", "elicitation_dialog": "🔧", "auth_success": "✅"}.get(ntype, "🔔")


def get_title(ntype: str, message: str) -> str:
    msg = (message or "").lower()
    if ntype == "elicitation_dialog" or any(k in msg for k in ("select", "choose", "which")):
        return "Claude needs your choice"
    if ntype == "permission_prompt":
        if "bash" in msg or "command" in msg:
            return "Claude needs permission (Bash)"
        if "write" in msg or "create file" in msg:
            return "Claude needs permission (Write)"
        if "edit" in msg or "modify" in msg:
            return "Claude needs permission (Edit)"
        if "read" in msg:
            return "Claude needs permission (Read)"
        return "Claude needs your attention"
    if ntype == "idle_prompt":
        return "Claude is waiting for you"
    if ntype == "auth_success":
        return "Claude authentication succeeded"
    return "Claude notification"


def send_slack(data: dict, ntype: str) -> dict:
    if not SLACK_WEBHOOK:
        return {"channel": "slack", "sent": False, "reason": "no webhook"}

    message = data.get("message") or ""
    short_msg = (message[:200] + "...") if len(message) > 200 else (message or "_No details provided_")
    session_id = (data.get("session_id") or "????")[:6]

    payload = {
        "blocks": [
            {
                "type": "header",
                "text": {"type": "plain_text", "text": f"{get_emoji(ntype)} {get_title(ntype, message)}", "emoji": True},
            },
            {
                "type": "section",
                "fields": [
                    {"type": "mrkdwn", "text": f"*Project:*\n`{get_project_name(data.get('cwd'))}`"},
                    {"type": "mrkdwn", "text": f"*Session:*\n`{session_id}`"},
                ],
            },
            {
                "type": "section",
                "text": {"type": "mrkdwn", "text": f"*Details:*\n{short_msg}"},
            },
            {
                "type": "context",
                "elements": [
                    {"type": "mrkdwn", "text": f"📁 `{data.get('cwd', 'unknown')}`"},
                    {"type": "mrkdwn", "text": f"🕐 {datetime.now().strftime('%H:%M:%S')}"},
                ],
            },
        ]
    }

    try:
        body = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            SLACK_WEBHOOK,
            data=body,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            return {"channel": "slack", "sent": resp.status == 200, "error": f"HTTP {resp.status}" if resp.status != 200 else None}
    except Exception as e:
        return {"channel": "slack", "sent": False, "error": str(e)}


def main() -> None:
    try:
        data = json.loads(sys.stdin.read())
        if data.get("hook_event_name") != "Notification":
            print("{}")
            return

        log({
            "level": "INPUT",
            "notification_type": data.get("notification_type"),
            "message": data.get("message"),
            "session_id": data.get("session_id"),
        })

        ntype = get_notification_type(data)
        result = send_slack(data, ntype)

        sent = [result["channel"]] if result.get("sent") else []
        failed = [result] if not result.get("sent") and result.get("error") else []
        log({
            "level": "SENT" if sent else "NONE",
            "type": ntype, "sent": sent, "failed": failed,
            "session_id": data.get("session_id"),
        })

        print("{}")

    except Exception:
        print("{}")


if __name__ == "__main__":
    main()
