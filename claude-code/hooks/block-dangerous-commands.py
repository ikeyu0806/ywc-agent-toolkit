#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
Block Dangerous Commands - PreToolUse Hook for Bash
Blocks dangerous shell patterns before execution.
Logs to: ~/.claude/hooks-logs/YYYY-MM-DD.jsonl

SAFETY_LEVEL: 'critical' | 'high' | 'strict'
  critical - Only catastrophic: rm -rf ~, dd to disk, fork bombs
  high     - + risky: force push main, secrets exposure, git reset --hard
  strict   - + cautionary: any force push, sudo rm, docker prune
"""

import json
import re
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

SAFETY_LEVEL = "high"


@dataclass(frozen=True)
class Pattern:
    level: str
    id: str
    regex: re.Pattern
    reason: str


PATTERNS: list[Pattern] = [
    # CRITICAL — catastrophic, unrecoverable
    Pattern("critical", "rm-home",          re.compile(r'\brm\s+(?:-\S+\s+)*["\']?~(?:\/[^;&|]*)?["\']?(?:\s|$|[;&|])'),          "rm targeting home directory"),
    Pattern("critical", "rm-home-var",      re.compile(r'\brm\s+(?:-\S+\s+)*["\']?\$HOME(?:\/[^;&|]*)?["\']?(?:\s|$|[;&|])'),     "rm targeting $HOME"),
    Pattern("critical", "rm-home-trailing", re.compile(r'\brm\s+.+\s+["\']?(~\/?|\$HOME)["\']?(\s*$|[;&|])'),                      "rm with trailing ~/ or $HOME"),
    Pattern("critical", "rm-root",          re.compile(r'\brm\s+(-.+\s+)*\/(\*|\s|$|[;&|])'),                                      "rm targeting root filesystem"),
    Pattern("critical", "rm-system",        re.compile(r'\brm\s+(-.+\s+)*\/(etc|usr|var|bin|sbin|lib|boot|dev|proc|sys)(\/|\s|$)'), "rm targeting system directory"),
    Pattern("critical", "rm-cwd",           re.compile(r'\brm\s+(-.+\s+)*(\.\/?|\*|\.\/\*)(\s|$|[;&|])'),                          "rm deleting current directory contents"),
    Pattern("critical", "dd-disk",          re.compile(r'\bdd\b.+of=\/dev\/(sd[a-z]|nvme|hd[a-z]|vd[a-z]|xvd[a-z])'),             "dd writing to disk device"),
    Pattern("critical", "mkfs",             re.compile(r'\bmkfs(\.\w+)?\s+\/dev\/(sd[a-z]|nvme|hd[a-z]|vd[a-z])'),                "mkfs formatting disk"),
    Pattern("critical", "fork-bomb",        re.compile(r':\(\)\s*\{.*:\s*\|\s*:.*&'),                                              "fork bomb detected"),
    # HIGH — significant risk, data loss, security
    Pattern("high", "curl-pipe-sh",         re.compile(r'\b(curl|wget)\b.+\|\s*(?:sudo\s+)?(?:\S+/)?(ba)?sh\b'),                   "piping URL to shell (RCE risk)"),
    Pattern("high", "git-force-main",       re.compile(r'\bgit\s+push\b(?!.+--force-with-lease)(?=.+(--force|-f)\b)(?=.+\b(main|master)\b)'), "force push to main/master"),
    Pattern("high", "git-reset-hard",       re.compile(r'\bgit\s+reset\s+--hard'),                                                 "git reset --hard loses uncommitted work"),
    Pattern("high", "git-clean-f",          re.compile(r'\bgit\s+clean\s+(-\w*f|-f)'),                                             "git clean -f deletes untracked files"),
    Pattern("high", "chmod-777",            re.compile(r'\bchmod\b.+\b777\b'),                                                     "chmod 777 is a security risk"),
    Pattern("high", "cat-env",              re.compile(r'\b(cat|less|head|tail|more)\s+\.env\b'),                                  "reading .env file exposes secrets"),
    Pattern("high", "cat-secrets",          re.compile(r'\b(cat|less|head|tail|more)\b.+(credentials|secrets?|\.pem|\.key|id_rsa|id_ed25519)', re.IGNORECASE), "reading secrets file"),
    Pattern("high", "env-dump",             re.compile(r'\b(printenv|env)\b\s*([;&|]|$)'),                                         "env dump may expose secrets"),
    Pattern("high", "echo-secret",          re.compile(r'\becho\b.+\$\w*(SECRET|KEY|TOKEN|PASSWORD|API_|PRIVATE)', re.IGNORECASE), "echoing secret variable"),
    Pattern("high", "docker-vol-rm",        re.compile(r'\bdocker\s+volume\s+(rm|prune)'),                                         "docker volume deletion loses data"),
    Pattern("high", "rm-ssh",               re.compile(r'\brm\b.+\.ssh\/(id_|authorized_keys|known_hosts)'),                       "deleting SSH keys"),
    # STRICT — cautionary, context-dependent
    Pattern("strict", "git-force-any",      re.compile(r'\bgit\s+push\b(?!.+--force-with-lease).+(--force|-f)\b'),                 "force push (use --force-with-lease)"),
    Pattern("strict", "git-checkout-dot",   re.compile(r'\bgit\s+checkout\s+\.'),                                                  "git checkout . discards changes"),
    Pattern("strict", "sudo-rm",            re.compile(r'\bsudo\s+rm\b'),                                                          "sudo rm has elevated privileges"),
    Pattern("strict", "docker-prune",       re.compile(r'\bdocker\s+(system|image)\s+prune'),                                      "docker prune removes images"),
    Pattern("strict", "crontab-r",          re.compile(r'\bcrontab\s+-r'),                                                         "removes all cron jobs"),
]

LEVELS: dict[str, int] = {"critical": 1, "high": 2, "strict": 3}
EMOJIS: dict[str, str] = {"critical": "🚨", "high": "⛔", "strict": "⚠️"}
LOG_DIR = Path.home() / ".claude" / "hooks-logs"


def log(data: dict) -> None:
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        log_file = LOG_DIR / f"{datetime.now().strftime('%Y-%m-%d')}.jsonl"
        with open(log_file, "a") as f:
            f.write(json.dumps({"ts": datetime.now().isoformat(), "hook": "block-dangerous-commands", **data}) + "\n")
    except Exception:
        pass


def check_command(cmd: str, safety_level: str = SAFETY_LEVEL) -> Pattern | None:
    threshold = LEVELS.get(safety_level, 2)
    for p in PATTERNS:
        if LEVELS[p.level] <= threshold and p.regex.search(cmd):
            return p
    return None


def main() -> None:
    try:
        data = json.loads(sys.stdin.read())
        if data.get("tool_name") != "Bash":
            print("{}")
            return

        cmd = data.get("tool_input", {}).get("command", "")
        matched = check_command(cmd)

        if matched:
            log({
                "level": "BLOCKED", "id": matched.id, "priority": matched.level,
                "cmd": cmd, "session_id": data.get("session_id"), "cwd": data.get("cwd"),
            })
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "deny",
                    "permissionDecisionReason": f"{EMOJIS[matched.level]} [{matched.id}] {matched.reason}",
                }
            }))
        else:
            print("{}")

    except Exception:
        print("{}")


if __name__ == "__main__":
    main()
