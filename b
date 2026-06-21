#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook that blocks destructive bash commands.

Place this file at: ~/.claude/hooks/pre-tool-use
Make it executable: chmod +x ~/.claude/hooks/pre-tool-use
"""

import json
import os
import re
import sys
from datetime import datetime, timezone

BLOCKED_LOG = os.path.expanduser("~/.claude/hooks/blocked.log")

# Patterns that are always blocked
ALWAYS_BLOCKED = [
    r"rm\s+-rf",
    r"rm\s+-[a-zA-Z]*f",
    r"git\s+push\s+.*--force",
    r"git\s+push\s+-f",
    r"DROP\s+TABLE",
    r"TRUNCATE",
]

# Patterns that require a WHERE clause
DELETE_PATTERN = r"DELETE\s+FROM"


def log_blocked(command: str, project_path: str):
    """Log a blocked command attempt to the blocked log file."""
    os.makedirs(os.path.dirname(BLOCKED_LOG), exist_ok=True)
    timestamp = datetime.now(timezone.utc).isoformat()
    with open(BLOCKED_LOG, "a") as f:
        f.write(f"{timestamp} | {command} | {project_path}\n")


def is_destructive(command: str) -> tuple[bool, str]:
    """Check if a command is destructive. Returns (is_blocked, reason)."""
    upper = command.upper()

    for pattern in ALWAYS_BLOCKED:
        if re.search(pattern, command, re.IGNORECASE):
            return True, f"Matched blocked pattern: {pattern}"

    if re.search(DELETE_PATTERN, command, re.IGNORECASE):
        if not re.search(r"WHERE\s+", command, re.IGNORECASE):
            return True, "DELETE FROM without a WHERE clause is not allowed"

    return False, ""


def main():
    # Read the hook payload from stdin
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    tool_name = payload.get("tool_name", "")
    tool_input = payload.get("tool_input", {})

    if tool_name != "bash":
        sys.exit(0)

    command = tool_input.get("command", "")
    project_path = payload.get("project_path", "")

    blocked, reason = is_destructive(command)
    if blocked:
        log_blocked(command, project_path)
        print(f"🚫 BLOCKED: This command was prevented from running.\nReason: {reason}\nCommand: {command}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()