#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook that blocks destructive bash commands.

This hook intercepts dangerous bash commands before execution and blocks them
if they match known destructive patterns.
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path


def block_destructive_commands():
    """Main hook function that blocks destructive commands."""
    # Read the tool use request from stdin
    try:
        raw_input = sys.stdin.read()
        tool_use = json.loads(raw_input)
    except json.JSONDecodeError:
        # If not JSON or invalid JSON, allow the command to proceed
        return True
    
    # Only check bash commands
    if tool_use.get("type") != "bash" or not tool_use.get("data", {}).get("command"):
        return True
    
    command = tool_use["data"]["command"]
    
    # Check for destructive patterns
    destructive_patterns = [
        r"rm\s+-rf",           # rm -rf command
        r"DROP\s+TABLE",         # DROP TABLE SQL command
        r"git\s+push\s+--force",  # git push --force
        r"TRUNCATE",             # TRUNCATE SQL command
        r"DELETE\s+FROM\s+\w+\s*$',  # DELETE FROM without WHERE clause
    ]
    
    # Special handling for DELETE FROM without WHERE
    delete_without_where = re.search(r"DELETE\s+FROM", command, re.IGNORECASE) and not re.search(r"WHERE", command, re.IGNORECASE)
    
    # Check if command matches any destructive pattern
    is_destructive = any(re.search(pattern, command, re.IGNORECASE) for pattern in destructive_patterns[:-1]) or delete_without_where
    
    if is_destructive:
        # Log the blocked command
        log_blocked_command(command)
        
        # Block the command
        print(f"❌ BLOCKED: Dangerous command detected and prevented:\n\n> {command}\n\n"
              "This command was blocked because it could cause data loss or other destructive effects.\n"
              "If you need to perform this action, run it manually outside of Claude Code.",
              file=sys.stderr)
        return False
    
    # Non-destructive command, allow it
    return True


def log_blocked_command(command):
    """Log blocked command attempts to ~/.claude/hooks/blocked.log"""
    try:
        # Create hooks directory if it doesn't exist
        hooks_dir = Path.home() / ".claude" / "hooks"
        hooks_dir.mkdir(parents=True, exist_ok=True)
        
        # Log file path
        log_file = hooks_dir / "blocked.log"
        
        # Get current project path (if available)
        project_path = os.getcwd()
        
        # Log entry with timestamp, command, and project path
        timestamp = datetime.now().isoformat()
        log_entry = f"[{timestamp}] Blocked command in project {project_path}:\n{command}\n\n"
        
        # Write to log file in append mode
        with open(log_file, "a") as f:
            f.write(log_entry)
    except Exception as e:
        # If logging fails, we still want to block the command
        pass


def main():
    """Entry point for the hook."""
    if not block_destructive_commands():
        sys.exit(1)


if __name__ == "__main__":
    main()