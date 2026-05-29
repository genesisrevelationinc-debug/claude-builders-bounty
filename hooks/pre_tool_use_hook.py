#!/usr/bin/env python3
"""
Pre-tool-use hook that blocks destructive bash commands before they are executed.
Logs blocked commands to ~/.claude/hooks/blocked.log
"""

import sys
import os
import datetime
import re
import json

# Configuration
DANGEROUS_PATTERNS = [
    r'rm\s+-rf',
    r'drop\s+table',
    r'git\s+push\s+--force',
    r'truncate',
 r'delete\s+from\s+(?!.*\bwhere\b)'
]


def block_destructive_commands():
    """Main hook function to check and block destructive commands"""
    try:
        # Read the tool use request from stdin
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("Error: Invalid JSON input")
        sys.exit(1)

    # Extract command and project path
    command = data.get('command', '')
    project_path = data.get('cwd', 'Unknown')
    
    # Check for destructive patterns
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            # Log the blocked command
            log_blocked_command(command, project_path)
            # Block the command
            print(f"Blocked potentially destructive command: {command}")
            sys.exit(1)
    
    # If no destructive pattern found, allow the command to proceed
    print(json.dumps(data))


def log_blocked_command(cmd, project_path):
    """Log blocked command attempts to file"""
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] {cmd} - {project0\n")
        
if __name__ == "__main__":
    block_destructive_commands()