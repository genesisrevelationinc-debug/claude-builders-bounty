#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.

This hook intercepts dangerous bash commands before they are executed
and blocks them with a clear explanation.

Installation:
    mkdir -p ~/.claude/hooks
    cp block-destructive-commands.py ~/.claude/hooks/
    chmod +x ~/.claude/hooks/block-destructive-commands.py
"""

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


# Patterns that are always blocked (destructive operations)
DANGEROUS_PATTERNS = [
    # rm -rf / rm -r -f variants
    (r'\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?-[a-zA-Z]*r[a-zA-Z]*\s+.*', 'rm -rf: Recursive force delete'),
    (r'\brm\s+.*-[a-zA-Z]*r[a-zA-Z]*\s+.*-[a-zA-Z]*f', 'rm -rf: Recursive force delete'),
    
    # DROP TABLE
    (r'\bDROP\s+TABLE\b', 'DROP TABLE: Destructive SQL operation'),
    
    # TRUNCATE
    (r'\bTRUNCATE\b', 'TRUNCATE: Destructive SQL operation'),
    
    # DELETE FROM without WHERE
    (r'\bDELETE\s+FROM\s+\S+(?!.*\bWHERE\b)', 'DELETE FROM without WHERE: Unqualified delete'),
    
    # git push --force / git push -f
    (r'\bgit\s+push\s+.*(--force\b|-f\b)', 'git push --force: Force push can overwrite remote history'),
]


def get_log_path():
    """Get the path to the blocked attempts log file."""
    hooks_dir = Path.home() / '.claude' / 'hooks'
    hooks_dir.mkdir(parents=True, exist_ok=True)
    return hooks_dir / 'blocked.log'


def log_blocked_attempt(command, project_path):
    """Log a blocked attempt to the log file."""
    log_path = get_log_path()
    timestamp = datetime.now().isoformat()
    
    log_entry = f"{timestamp} | {project_path} | {command}\n"
    
    with open(log_path, 'a') as f:
        f.write(log_entry)


def check_command(command):
    """Check if a command matches any dangerous pattern."""
    command_upper = command.upper()
    
    for pattern, description in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return description
    
    return None


def main():
    """Main entry point for the hook."""
    # Read the tool use request from stdin (Claude Code hook format)
    try:
        input_data = sys.stdin.read()
        tool_request = json.loads(input_data)
    except (json.JSONDecodeError, Exception):
        # If we can't parse, let it through (fail open for safety)
        sys.exit(0)
    
    # Extract the command from the tool request
    command = tool_request.get('command', '')
    if not command:
        sys.exit(0)
    
    # Check if the command is dangerous
    block_reason = check_command(command)
    if block_reason:
        # Get project path
        project_path = tool_request.get('project_path', os.getcwd())
        
        # Log the blocked attempt
        log_blocked_attempt(command, project_path)
        
        # Print blocking message to stderr (Claude will see this)
        print(f"\n🚫 BLOCKED: {block_reason}\n", file=sys.stderr)
        print(f"Command: {command}\n", file=sys.stderr)
        print("This command has been blocked for safety. If you believe this is an error, please review the command and try a safer alternative.\n", file=sys.stderr)
        
        # Exit with non-zero to block the command
        sys.exit(1)
    
    # Command is safe, allow it
    sys.exit(0)


if __name__ == '__main__':
    main()


--- /dev/null
# Block Destructive Commands Hook

A Claude Code `pre-tool-use` hook that intercepts dangerous bash commands before they are executed.

## Installation

