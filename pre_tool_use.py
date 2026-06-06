#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.
"""

import sys
import json
import os
from datetime import datetime

# Dangerous patterns to block
DANGEROUS_PATTERNS = [
    'rm -rf',
    'DROP TABLE',
    'git push --force',
    'TRUNCATE',
    'DELETE FROM'
]

def log_blocked_command(command, project_path):
    """Log blocked command to file"""
    log_path = os.path.expanduser('~/.claude/hooks/blocked.log')
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # Create log entry
    log_entry = f"{timestamp} | {command} | {project_path}\n"
    
    # Write to log file
    with open(log_path, 'a') as f:
        f.write(log_entry)

def is_destructive_command(command_str):
    """Check if command contains dangerous patterns"""
    if 'rm -rf' in command_str:
        return True
    if 'DROP TABLE' in command_str:
        return True
    if 'git push --force' in command_str:
        return True
    if 'TRUNCATE' in command_str:
        return True
    if 'DELETE FROM' in command_str and 'WHERE' not in command_str:
        return True
    return False

def main():
    try:
        # Read the tool use request from stdin
        request = json.load(sys.stdin)
        
        # Extract command and arguments
        tool_name = request.get('tool_name', '')
        tool_args = request.get('tool_args', {})
        command = tool_args.get('command', '') if isinstance(tool_args, dict) else ''
        
        # Only check bash commands
        if tool_name != 'bash':
            # Not a bash command, allow it
            print(json.dumps(request))
            return 0
            
        # Check if this is a destructive command
        if is_destructive_command(command):
            # Log the blocked command
            project_path = os.getcwd()
            log_blocked_command(command, project_path)
            
            # Block the command and explain why
            print("Command blocked: " + command, file=sys.stderr)
            print("Reason: This command contains potentially destructive patterns", file=sys.stderr)
            print("Blocked patterns: rm -rf, DROP TABLE, git push --force, TRUNCATE, DELETE FROM (without WHERE)", file=sys.stderr)
            return 1
        
        # Allow non-destructive commands
        print(json.dumps(request))
        return 0
        
    except Exception as e:
        print(f"Error in hook: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())