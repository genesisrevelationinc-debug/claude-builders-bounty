#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook: Block destructive bash commands.

Place this file at: ~/.claude/hooks/block-destructive-commands.py
Make it executable: chmod +x ~/.claude/hooks/block-destructive-commands.py

This hook intercepts bash tool invocations and blocks known dangerous patterns.
"""

import json
import os
import re
import sys
from datetime import datetime, timezone


LOG_FILE = os.path.expanduser("~/.claude/hooks/blocked.log")


def log_blocked(command: str, project_path: str, reason: str):
    """Log a blocked command attempt with timestamp and details."""
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    timestamp = datetime.now(timezone.utc).isoformat()
    log_entry = f"[{timestamp}] BLOCKED: {command!r} | Project: {project_path} | Reason: {reason}\n"
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(log_entry)


def block_with_message(reason: str, command: str):
    """Print a structured error message for Claude and exit with non-zero code."""
    print(f"\n🛡️  SECURITY HOOK BLOCKED this command:\n\n  > {command}\n\nReason: {reason}\n", file=sys.stderr)
    print("The command was prevented from running to protect your system.", file=sys.stderr)
    sys.exit(1)


def is_destructive_bash(command: str) -> tuple[bool, str]:
    """
    Check if a bash command contains destructive patterns.
    Returns (is_blocked, reason).
    """
    upper = command.upper()

    # Pattern: rm -rf (and variants like rm -rf /, rm -rf *)
    if re.search(r'\brm\s+(-[a-zA-Z]*f|--)+\s', command) or re.search(r'\brm\s+-\S*f', command):
        # More specific: rm with -f or -rf
        if re.search(r'\brm\s+-\S*[rf]\S*', command) or re.search(r'\brm\s+.*-[a-zA-Z]*[rf]', command):
            return True, "Destructive file removal: `rm -rf` or similar force-recursive delete"

    # Pattern: DROP TABLE
    if re.search(r'\bDROP\s+TABLE\b', upper):
        return True, "Destructive SQL: DROP TABLE"

    # Pattern: TRUNCATE
    if re.search(r'\bTRUNCATE\b', upper):
        return True, "Destructive SQL: TRUNCATE"

    # Pattern: DELETE FROM without WHERE
    if re.search(r'\bDELETE\s+FROM\b', upper) and not re.search(r'\bWHERE\b', upper):
        return True, "Destructive SQL: DELETE FROM without WHERE clause"

    # Pattern: git push --force (and variants)
    if re.search(r'\bgit\s+push\s+.*--force\b', command) or re.search(r'\bgit\s+push\s+.*-f\b', command):
        return True, "Destructive git: force push can overwrite remote history"

    return False, ""


def main():
    # Read the tool-use payload from stdin
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Hook error: invalid JSON input: {e}", file=sys.stderr)
        sys.exit(0)  # Don't block on hook errors

    tool_name = payload.get("tool_name", "")
    tool_input = payload.get("tool_input", {})

    # Only intercept bash tool
    if tool_name != "bash":
        sys.exit(0)

    command = tool_input.get("command", "")
    if not command:
        sys.exit(0)

    # Get project path from environment or current working directory
    project_path = os.environ.get("PWD", os.getcwd())

    # Check for destructive patterns
    blocked, reason = is_destructive_bash(command)
    if blocked:
        log_blocked(command, project_path, reason)
        block_with_message(reason, command)

    # Not blocked, allow to proceed
    sys.exit(0)


if __name__ == "__main__":
    main()

--- /dev/null
# Block Destructive Commands Hook

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they execute.

## What it blocks

| Pattern | Examplelets |
|---------|-------------|
| `rm -rf` | `rm -rf /`, `rm -rf node_modules` |
| `DROP TABLE` | `DROP TABLE users;` |
| `TRUNCATE` | `TRUNCATE orders;` |
| `DELETE FROM` (no WHERE) | `DELETE FROM users;` |
| `git push --force` | `git push --force origin main` |

## Installation (2 commands)

