#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.

This hook intercepts dangerous commands like rm -rf, DROP TABLE, etc.
before they are executed and logs the attempts.
"""

import json
import sys
import os
import re
from datetime import datetime
from pathlib import Path


def log_blocked_command(command, project_path):
    """Log blocked command attempts to a log file."""
    log_file = Path.home() / '.claude' / 'hooks' / 'blocked.log'
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = {
        "timestamp": timestamp,
        "command": command,
        "project_path": str(project_path)
    }
    
    with open(log_file, 'a') as f:
        f.write(json.dumps(log_entry) + '\n')


def is_dangerous_command(command, args):
    """
    Check if the command and arguments match dangerous patterns.
    
    Returns:
        tuple: (is_dangerous: bool, reason: str)
    """
    cmd = command.strip().lower()
    args_str = ' '.join(args).strip().lower() if args else ''
    full_command = f"{cmd} {args_str}".strip()
    
    # Check for rm -rf
    if cmd == 'rm' and '-rf' in args_str:
        return True, "rm -rf command blocked for safety"
    
    # Check for DROP TABLE
    if cmd in ('sql', 'psql', 'mysql') or 'sql' in cmd:
        if 'drop table' in args_str:
            return True, "DROP TABLE command blocked for safety"
    
    # Check for git push --force
    if cmd == 'git' and 'push' in args_str and '--force' in args_str:
        return True, "git push --force command blocked for safety"
    
    # Check for TRUNCATE
    if cmd in ('sql', 'psql', 'mysql') or 'sql' in cmd:
        if 'truncate' in args_str:
            return True, "TRUNCATE command blocked for safety"
    
    # Check for DELETE FROM without WHERE clause
    if cmd in ('sql', 'psql', 'mysql') or 'sql' in cmd:
        # Match DELETE FROM followed by a table name but not followed by WHERE
        delete_match = re.search(r'delete\s+from\s+\w+', args_str)
        where_match = re.search(r'where\s+.+', args_str)
        
        if delete_match and not where_match:
            return True, "DELETE FROM without WHERE clause blocked for safety"
    
    return False, ""


def main():
    """Main hook function that Claude Code will call."""
    # Read the JSON input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # If not valid JSON, allow the command to proceed
        return
    
    command = input_data.get('command', '')
    args = input_data.get('args', [])
    project_path = input_data.get('project_path', '')
    
    # Check if command is dangerous
    is_dangerous, reason = is_dangerous_command(command, args)
    
    if is_dangerous:
        # Log the blocked attempt
        log_blocked_command(f"{command} {' '.join(args)}", project_path)
        
        # Output error message for Claude
        error_msg = {
            "error": {
                "type": "dangerous_command_blocked",
                "message": f"Blocked dangerous command: {reason}"
            }
        }
        print(json.dumps(error_msg))
        sys.exit(1)
    
    # If not dangerous, exit normally to allow command execution


if __name__ == '__main__':
    main()