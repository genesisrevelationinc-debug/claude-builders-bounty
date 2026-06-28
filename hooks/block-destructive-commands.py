#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.

Place this file at: ~/.claude/hooks/block-destructive-commands.py
And make it executable: chmod +x ~/.claude/hooks/block-destructive-commands.py
"""

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


# Patterns that are always blocked (no exceptions)
ALWAYS_BLOCKED = [
    r"rm\s+(-[a-zA-Z]*f[a-zA-Z]*|-[a-zA-Z]*r[a-zA-Z]*)\s+",  # rm with -rf or similar
    r"rm\s+.*\s+-[a-zA-Z]*[rf]",  # rm with -rf anywhere
    r"git\s+push\s+.*--force",  # git push --force
    r"git\s+push\s+-f\b",  # git push -f
    r"DROP\s+TABLE",  # DROP TABLE (case insensitive below)
    r"TRUNCATE\s+",  # TRUNCATE
]

# Patterns that are blocked only if they lack a WHERE clause
DELETE_NO_WHERE = r"DELETE\s+FROM\s+\S+"


def get_log_path():
    """Get the path to the blocked log file."""
    hooks_dir = Path.home() / ".claude" / "hooks"
    hooks_dir.mkdir(parents=True, exist_ok=True)
    return hooks_dir / "blocked.log"


def log_blocked(command, reason):
    """Log a blocked command to the log file."""
    log_path = get_log_path()
    timestamp = datetime.now().isoformat()
    project_path = os.getcwd()
    
    log_entry = f"{timestamp} | REASON: {reason} | CMD: {command} | PROJECT: {project_path}\n"
    
    with open(log_path, "a") as f:
        f.write(log_entry)


def is_destructive(command):
    """
    Check if a command is destructive and should be blocked.
    
    Returns (is_blocked, reason) tuple.
    """
    upper = command.upper()
    
    # Check always-blocked patterns
    for pattern in ALWAYS_BLOCKED:
        if re.search(pattern, command, re.IGNORECASE):
            if "rm" in command.lower():
                return True, "Destructive file removal (rm with -rf flags) is blocked to prevent accidental data loss."
            elif "git push" in command.lower():
                return True, "Force git push is blocked to prevent overwriting remote history."
            elif "DROP TABLE" in upper:
                return True, "DROP TABLE is blocked to prevent accidental data loss."
            elif "TRUNCATE" in upper:
                return True, "TRUNCATE is blocked to prevent accidental data loss."
            return True, "This command matches a blocked destructive pattern."
    
    # Check DELETE FROM without WHERE
    if re.search(DELETE_NO_WHERE, command, re.IGNORECASE):
        # Check if there's a WHERE clause
        delete_match = re.search(r"DELETE\s+FROM\s+\S+\s*(.*)", command, re.IGNORECASE)
        if delete_match:
            after_table = delete_match.group(1).strip()
            if not re.search(r"WHERE\s+", after_table, re.IGNORECASE):
                return True, "DELETE FROM without a WHERE clause is blocked to prevent accidental deletion of all rows."
    
    return False, None


def main():
    # Read the hook input from stdin (JSON)
    try:
        hook_data = json.loads(sys.stdin.read())
    except json.JSONDecodeError:
        # If not valid JSON, allow the command
        sys.exit(0)
    
    # Extract the command from the hook data
    command = hook_data.get("command", "")
    if not command:
        sys.exit(0)
    
    # Check if the command is destructive
    blocked, reason = is_destructive(command)
    
    if blocked:
        log_blocked(command, reason)
        print(f"🚫 BLOCKED: {reason}", file=sys.stderr)
        print(f"   Command: {command}", file=sys.stderr)
        print(f"   This command has been logged for security review.", file=sys.stderr)
        sys.exit(1)  # Non-zero exit blocks the command
    
    # Allow the command
    sys.exit(0)


if __name__ == "__main__":
    main()