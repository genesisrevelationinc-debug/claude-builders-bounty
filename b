#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.

Place at: ~/.claude/hooks/block-destructive-commands.py
Make executable: chmod +x ~/.claude/hooks/block-destructive-commands.py

This hook intercepts bash tool calls and blocks dangerous patterns
before they can be executed.
"""

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path


# Patterns that are always blocked (case-insensitive)
ALWAYS_BLOCKED = [
    r"rm\s+(-[a-zA-Z]*\s+)*-?[a-zA-Z]*rf",  # rm -rf (handles variations like rm -f -r, rm -rfv)
    r"git\s+push\s+.*--force",  # git push --force
    r"git\s+push\s+.*-f\b",  # git push -f
    r"DROP\s+TABLE",  # DROP TABLE
    r"TRUNCATE(\s+TABLE)?",  # TRUNCATE
]

# Patterns that require a WHERE clause
REQUIRES_WHERE = [
    r"DELETE\s+FROM",  # DELETE FROM without WHERE
]

# Log file path
LOG_FILE = Path.home() / ".claude" / "hooks" / "blocked.log"


def log_blocked(command: str, reason: str, project_path: str):
    """Log a blocked command attempt."""
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now(timezone.utc).isoformat()
    log_entry = (
        f"[{timestamp}] BLOCKED: {reason}\n"
        f"  Command: {command}\n"
        f"  Project: {project_path}\n"
        f"{'=' * 60}\n"
    )
    
    with open(LOG_FILE, "a") as f:
        f.write(log_entry)


def check_command(command: str, project_path: str) -> tuple[bool, str]:
    """
    Check if a command should be blocked.
    
    Returns:
        tuple of (is_allowed, reason_if_blocked)
    """
    upper_command = command.upper()
    
    # Check always-blocked patterns
    for pattern in ALWAYS_BLOCKED:
        if re.search(pattern, command, re.IGNORECASE):
            return False, f"Destructive command blocked: matches pattern '{pattern}'"
    
    # Check DELETE FROM without WHERE
    for pattern in REQUIRES_WHERE:
        if re.search(pattern, command, re.IGNORECASE):
            # Check if WHERE clause exists
            # Find the position after DELETE FROM
            match = re.search(r"DELETE\s+FROM", command, re.IGNORECASE)
            if match:
                after_delete = command[match.end():]
                if not re.search(r"\bWHERE\b", after_delete, re.IGNORECASE):
                    return False, "DELETE FROM without WHERE clause is blocked"
    
    return True, ""


def main():
    """Main hook entry point."""
    # Read the hook input from stdin (Claude Code passes tool info as JSON)
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError:
        # Not a valid JSON, allow to proceed
        print(json.dumps({"allow": True}))
        return
    
    # Extract tool information
    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})
    
    # Only intercept bash tool
    if tool_name != "bash":
        print(json.dumps({"allow": True}))
        return
    
    # Get the command
    command = tool_input.get("command", "")
    if not command:
        print(json.dumps({"allow": True}))
        return
    
    # Get project path from environment or current directory
    project_path = os.environ.get("PWD", os.getcwd())
    
    # Check if command should be blocked
    is_allowed, reason = check_command(command, project_path)
    
    if not is_allowed:
        # Log the blocked attempt
        log_blocked(command, reason, project_path)
        
        # Return block response with clear message
        print(json.dumps({
            "allow": False,
            "message": f"🛡️ SECURITY BLOCK: This command was prevented from running.\n\nReason: {reason}\n\nThe command '{command}' contains a destructive pattern that could cause irreversible data loss. If you need to perform this action, please do so manually outside of Claude Code or modify the command to avoid the destructive pattern."
        }))
        return
    
    # Allow the command
    print(json.dumps({"allow": True}))


if __name__ == "__main__":
    main()

# Claude Code Pre-Tool-Use Hook: Block Destructive Commands

A security hook for [Claude Code](https://docs.anthropic.com/claude-code/) that intercepts and blocks dangerous bash commands before they execute.

## What It Blocks

| Pattern | Example | Why Blocked |
|---------|---------|-------------|
| `rm -rf` | `rm -rf /important` | Irreversible deletion |
| `DROP TABLE` | `DROP TABLE users` | Irreversible data loss |
| `git push --force` | `git push --force origin main` | Overwrites remote history |
| `TRUNCATE` | `TRUNCATE TABLE orders` | Irreversible data loss |
| `DELETE FROM` (no WHERE) | `DELETE FROM users` | Deletes all rows |

## Installation

