#!/usr/bin/env python3
"""Build PR title components from a task directory name."""

import argparse
import re
import sys


def parse_task_name(task_name: str) -> tuple[str, str]:
    match = re.match(r"^(\d{6}-\d{3})-(.+)$", task_name)
    if match:
        return match.group(1), match.group(2)
    match = re.match(r"^(\d{6})-(.+)$", task_name)
    if match:
        return match.group(1), match.group(2)
    match = re.match(r"^(\d+-\d+)-(.+)$", task_name)
    if match:
        print(f"INFO: using flexible N-M format for '{task_name}'", file=sys.stderr)
        return match.group(1), match.group(2)
    match = re.match(r"^(\d+)-(.+)$", task_name)
    if match:
        print(f"INFO: using single-prefix format for '{task_name}'", file=sys.stderr)
        return match.group(1), match.group(2)
    return "", task_name


def slug_to_english(slug: str) -> str:
    return " ".join(word.capitalize() for word in slug.replace("-", " ").split())


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build PR title components from a task directory name"
    )
    parser.add_argument("task_name")
    parser.add_argument("--format", choices=["parts", "title"], default="parts")
    args = parser.parse_args()

    task_number, slug = parse_task_name(args.task_name)
    slug_en = slug_to_english(slug)

    if not task_number:
        print(
            f"WARNING: Could not detect task-number prefix in '{args.task_name}'",
            file=sys.stderr,
        )
        print("TASK_NUMBER=")
        print(f"SLUG_EN={slug_en}")
        sys.exit(1)

    if args.format == "title":
        print(f"[{task_number}] {slug_en}")
    else:
        print(f"TASK_NUMBER={task_number}")
        print(f"SLUG_EN={slug_en}")


if __name__ == "__main__":
    main()
