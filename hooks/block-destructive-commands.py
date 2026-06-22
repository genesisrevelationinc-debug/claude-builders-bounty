#!/usr/bin/env python3
"""
Pre-tool-use hook for Claude Code that blocks destructive bash commands.

Place this file at: ~/.claude/hooks/block-destructive-commands.py
Make it executable: chmod +x ~/.claude/hooks/block-destructive-commands.py

This hook intercepts bash tool calls and blocks dangerous patterns
before they can be executed.
"""

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path


# Destructive patterns to block
DANGEROUS_PATTERNS = [
    # rm -rf (recursive force delete)
    (r'\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?-[a-zA-Z]*r[a-zA-Z]*\s+', "rm -rf: Recursive force deletion"),
    (r'\brm\s+.*\s+-[a-zA-Z]*rf', "rm -rf: Recursive force deletion"),
    
    # SQL destructive commands
    (r'\bDROP\s+TABLE\b', "DROP TABLE: Database table deletion"),
    (r'\bTRUNCATE\b', "TRUNCATE: Table data destruction"),
    # DELETE FROM without WHERE
    (r'\bDELETE\s+FROM\s+\S+\s*;?\s*$', "DELETE FROM without WHERE: Unconditional data deletion"),
    (r'\bDELETE\s+FROM\s+\S+\s+(?!WHERE\b)', "DELETE FROM without WHERE: Unconditional data deletion"),
    
    # Git destructive commands
    (r'\bgit\s+push\s+.*--force\b', "git push --force: Force push can overwrite remote history"),
    (r'\bgit\s+push\s+.*-f\b', "git push --force: Force push can overwrite remote history"),
]


def get_log_file():
    """Get the path to the blocked attempts log file."""
    hooks_dir = Path.home() / ".claude" / "hooks"
    hooks_dir.mkdir(parents=True, exist_ok=True)
    return hooks_dir / "blocked.log"


def log_blocked_attempt(command, project_path):
    """Log a blocked attempt to the log file."""
    log_file = get_log_file()
    timestamp = datetime.now(timezone.utc).isoformat()
    
    log_entry = (
        f"[{timestamp}] "
        f"BLOCKED: {command.strip()[:200]} | "
        f"Project: {project_path}\n"
    )
    
    with open(log_file, "a") as f:
        f.write(log_entry)


def check_command(command):
    """Check if a command contains dangerous patterns. Returns (is_blocked, reason)."""
    command_upper = command.upper()
    
    for pattern, reason in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True, reason
    
    return False, None


def main():
    """Main hook entry point."""
    # Read the tool use request from stdin
    try:
        input_data = sys.stdin.read()
        tool_request = json.loads(input_data)
    except (json.JSONDecodeError, ValueError):
        # If we can't parse, let it through (fail open for safety)
        sys.exit(0)
    
    # Only intercept bash tool calls
    tool_name = tool_request.get("tool_name", "")
    if tool_name != "bash":
        sys.exit(0)
    
    command = tool_request.get("command", "")
    project_path = tool_request.get("project_path", os.getcwd())
    
    is_blocked, reason = check_command(command)
    
    if is_blocked:
        # Log the blocked attempt
        log_blocked_attempt(command, project_path)
        
        # Output the block message to stderr for Claude to see
        print(f"\n🚫 BLOCKED: {reason}\n", file=sys.stderr)
        print(f"Command: {command.strip()}\n", file=sys.stderr)
        print("This destructive command has been blocked for safety. Please use a safer alternative or confirm the command is intentional.\n", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()