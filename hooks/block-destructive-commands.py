#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.

Place this file at: ~/.claude/hooks/block-destructive-commands.py
Make it executable: chmod +x ~/.claude/hooks/block-destructive-commands.py
"""

import json
import os
import re
import sys
from datetime import datetime


BLOCKED_PATTERNS = [
    # rm -rf (any variant)
    r'\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?-[a-zA-Z]*r[a-zA-Z]*\s+',
    r'\brm\s+-[a-zA-Z]*\s+-[a-zA-Z]*r[a-zA-Z]*\s+',
    # DROP TABLE
    r'\bDROP\s+TABLE\b',
    # git push --force
    r'\bgit\s+push\s+.*--force\b',
    r'\bgit\s+push\s+.*-f\b',
    # TRUNCATE
    r'\bTRUNCATE\s+TABLE?\b',
    # DELETE FROM without WHERE
    r'\bDELETE\s+FROM\s+\S+(?!.*\bWHERE\b)',
]

LOG_FILE = os.path.expanduser("~/.claude/hooks/blocked.log")


def log_blocked(command: str, project_path: str):
    """Log a blocked command attempt."""
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    timestamp = datetime.now().isoformat()
    with open(LOG_FILE, "a") as f:
        f.write(f"{timestamp} | {project_path} | {command}\n")


def is_destructive(command: str) -> tuple[bool, str | None]:
    """Check if a command matches any destructive pattern."""
    upper = command.upper()
    
    for pattern in BLOCKED_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True, pattern
    
    return False, None


def main():
    # Read the hook input from stdin
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("Error: Invalid JSON input", file=sys.stderr)
        sys.exit(0)
    
    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})
    
    # Only intercept bash tool
    if tool_name != "bash":
        sys.exit(0)
    
    command = tool_input.get("command", "")
    project_path = hook_input.get("project_path", "unknown")
    
    destructive, pattern = is_destructive(command)
    
    if destructive:
        log_blocked(command, project_path)
        
        print(f"""🚫 BLOCKED: Destructive command detected

The following command was blocked for safety:
  {command}

This hook prevents accidental execution of destructive operations including:
  - rm -rf (recursive force delete)
  - DROP TABLE (database table deletion)
  - git push --force (force push)
  - TRUNCATE (table data removal)
  - DELETE FROM without WHERE (unqualified row deletion)

If you need to run this command, disable the hook or modify the pattern: {pattern}""", file=sys.stderr)
        
        sys.exit(1)
    
    sys.exit(0)


if __name__ == "__main__":
    main()

--- /dev/null
# Block Destructive Commands Hook

A Claude Code `pre-tool-use` hook that intercepts and blocks dangerous bash commands before they are executed.

## Installation

