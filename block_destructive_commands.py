#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.
"""

import sys
import os
import re
from datetime import datetime
import json
import shutil

def log_blocked_command(command, project_path):
    """Log blocked command attempts to file"""
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Ensure log directory exists
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    
    log_entry = {
        "timestamp": timestamp,
        "command": command,
        "project_path": project_path
    }
    
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] Blocked command: {command} (Project: {project_path})\n")

def is_destructive_command(command):
    """Check if command matches destructive patterns"""
    destructive_patterns = [
        r'rm\s+-rf',  # rm -rf commands
        r'DROP\s+TABLE',  # SQL DROP TABLE
        r'git\s+push\s+--force',  # git push --force
        r'TRUNCATE\s+',  # SQL TRUNCATE
        r'DELETE\s+FROM\s+\w+\s*$',  # DELETE FROM without WHERE clause
        r'DELETE\s+FROM\s+\w+\s*;',  # DELETE FROM without WHERE clause
    ]
    
    # Check if any pattern matches
    for pattern in destructive_patterns:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False

def main():
    # Read command from stdin
    input_data = sys.stdin.read()
    if not input_data:
        sys.exit(1)
        
    try:
        # Parse the JSON input
        data = json.loads(input_data)
        command = data.get('tool_input', {}).get('command', '') if data.get('tool_input') else ''
        project_path = os.getcwd()
        
        if is_destructive_command(command):
            log_blocked_command(command, project_path)
            
            # Print explanation for Claude
            print("Error: Destructive command blocked for security.")
            if 'rm -rf' in command:
                sys.exit(1)
            elif 'DROP TABLE' in command:
                sys.exit(1)
            elif 'git push --force' in command:
                sys.exit(1)
            elif 'TRUNCATE' in command:
                sys.exit(1)
            elif 'DELETE FROM' in command and 'WHERE' not in command:
                sys.exit(1)
            else:
                sys.exit(1)
        else:
            # Not a destructive command, allow execution
            sys.exit(0)
    except json.JSONDecodeError:
        # If we can't parse JSON, err on the side of caution and block
        print("Error: Could not parse command input")
        sys.exit(1)

if __name__ == "__main__":
    main()