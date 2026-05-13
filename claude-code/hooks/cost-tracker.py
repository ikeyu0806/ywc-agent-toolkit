#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""
Cost Tracker Hook
PostToolUse : logs each tool call to ~/.claude/cost-tracker/YYYY-MM-DD.jsonl
Stop        : prints session summary to terminal (stderr)

Token counts are estimated as: characters / 4 (industry approximation).
Actual API token counts are not exposed via Claude Code hooks.
"""

import json
import math
import sys
from datetime import datetime
from pathlib import Path

LOG_DIR = Path.home() / ".claude" / "cost-tracker"


def today_str() -> str:
    return datetime.now().strftime("%Y-%m-%d")


def get_log_file() -> Path:
    return LOG_DIR / f"{today_str()}.jsonl"


def estimate_tokens(obj) -> int:
    return math.ceil(len(json.dumps(obj or "")) / 4)


def log_tool_use(data: dict) -> None:
    try:
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        tool_input = data.get("tool_input", {})
        entry = {
            "ts": datetime.now().isoformat(),
            "session": data.get("session_id", "unknown"),
            "project": Path(data.get("cwd", "")).name,
            "tool": data.get("tool_name", ""),
            "input_tok": estimate_tokens(tool_input),
            "output_tok": estimate_tokens(data.get("tool_response")),
            "target": (tool_input.get("file_path") or tool_input.get("command") or "")[:100],
        }
        with open(get_log_file(), "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass


def print_summary(data: dict) -> None:
    session_id = data.get("session_id", "unknown")
    log_file = get_log_file()

    entries: list[dict] = []
    try:
        if log_file.exists():
            entries = [
                json.loads(line)
                for line in log_file.read_text().strip().splitlines()
                if line
            ]
            entries = [e for e in entries if e.get("session") == session_id]
    except Exception:
        pass

    if not entries:
        sys.stderr.write("\n📊 Cost Tracker: No tool calls recorded for this session.\n")
        return

    total_calls = len(entries)
    total_in = sum(e.get("input_tok", 0) for e in entries)
    total_out = sum(e.get("output_tok", 0) for e in entries)
    total_tok = total_in + total_out

    # Tool breakdown
    by_tool: dict[str, dict] = {}
    for e in entries:
        tool = e.get("tool", "unknown")
        if tool not in by_tool:
            by_tool[tool] = {"calls": 0, "tokens": 0}
        by_tool[tool]["calls"] += 1
        by_tool[tool]["tokens"] += e.get("input_tok", 0) + e.get("output_tok", 0)

    # Top targets
    target_map: dict[str, int] = {}
    for e in entries:
        t = e.get("target", "")
        if t:
            target_map[t] = target_map.get(t, 0) + 1
    top_targets = sorted(target_map.items(), key=lambda x: -x[1])[:5]

    # Duration
    first = datetime.fromisoformat(entries[0]["ts"])
    last = datetime.fromisoformat(entries[-1]["ts"])
    mins = round((last - first).total_seconds() / 60)

    SEP = "─" * 54
    cwd = data.get("cwd", "")
    out_lines = [
        "",
        SEP,
        "📊  Session Cost Tracker",
        SEP,
        f"  Session   : {session_id[:16]}...",
        f"  Project   : {Path(cwd).name if cwd else 'unknown'}",
        f"  Duration  : ~{mins} min",
        f"  Calls     : {total_calls}",
        f"  Est.Tokens: {total_tok:,}  (in: {total_in:,} / out: {total_out:,})",
        "",
        "  Tool Breakdown:",
    ]

    for tool, stat in sorted(by_tool.items(), key=lambda x: -x[1]["calls"]):
        filled = round(stat["calls"] / total_calls * 20)
        bar = "█" * filled + "░" * (20 - filled)
        out_lines.append(
            f"    {tool:<14} {stat['calls']:>3} calls  {bar}  ~{stat['tokens']:,} tok"
        )

    if top_targets:
        out_lines += ["", "  Top Targets (files / commands):"]
        for target, count in top_targets:
            short = ("..." + target[-43:]) if len(target) > 46 else target
            out_lines.append(f"    {count:>3}x  {short}")

    # Improvement hints
    hints: list[str] = []
    read_calls = by_tool.get("Read", {}).get("calls", 0)
    if read_calls > 10:
        hints.append(f"  💡 Read {read_calls}회 반복 → CONTEXT.md에 자주 읽는 파일 요약 추가 검토")
    if total_calls > 60:
        hints.append(f"  💡 총 {total_calls}회 호출 → Task 단위 재구성 또는 Prompt 구체화 검토")
    if top_targets and top_targets[0][1] >= 5:
        t = top_targets[0][0]
        short = ("..." + t[-37:]) if len(t) > 40 else t
        hints.append(f'  💡 "{short}" {top_targets[0][1]}회 반복 접근 → Context에 포함 검토')

    if hints:
        out_lines += ["", "  Improvement Hints:"] + hints

    out_lines += [SEP, ""]
    sys.stderr.write("\n".join(out_lines) + "\n")


def main() -> None:
    try:
        data = json.loads(sys.stdin.read())
        event = data.get("hook_event_name")

        if event == "PostToolUse":
            log_tool_use(data)
            print("{}")
        elif event == "Stop":
            if data.get("stop_hook_active"):
                return
            print_summary(data)

    except Exception:
        print("{}")


if __name__ == "__main__":
    main()
