#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.
"""

import os
import sys
import json
from datetime import datetime
import re

def is_destructive_command(command):
    """Check if the command is destructive"""
    destructive_patterns = [
        'rm -rf',
        'DROP TABLE',
        'TRUNCATE',
        'git push --force',
        r'DELETE FROM(?!\s+.*\bWHERE\b)',  # DELETE without WHERE
    ]
    
    for pattern in destructive_patterns:
        # Special handling for DELETE pattern
        if 'DELETE FROM' in pattern and 'WHERE' not in command:
            if re.search(r'DELETE\s+FROM\s+\w+\s*$', command.strip(), re.IGNORECASE):
                return True
            continue
        # General pattern matching
        if pattern in command:
            return True
    return False

def main():
    # Read the tool use request from stdin
    request = json.load(sys.stdin)
    
    # Check if this is a destructive command
    if is_destructive_command(request['command']):
        # Log the blocked command
        log_file = os.path.expanduser('~/.claude/hooks/blocked.log')
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        project_path = request.get('path', 'Unknown')
        attempted_command = request['command']
        
        # Log to file
        with open(log_file, 'a') as f:
            f.write(f"{timestamp} - Blocked: {attempted_command} (Project: {project_path})\n")
        
        # Create response object indicating block
        response = {
            "blocked": True,
            "reason": "Command blocked for being destructive"
        }
        print(json.dumps(response))
        sys.exit(0)
    
    # If not blocked, allow the command to proceed
    response = {
        "blocked": False,
        "command": request['command']
    }
    print(json.dumps(response))

if __name__ == '__main__':
    main()

def is_destructive_command(command):
    """Enhanced check that handles the specific patterns from the requirements"""
    # Check for the destructive patterns
    patterns = [
        (r'^\s*rm\s+-rf', 'rm -rf'),
        (r'^\s*DROP\s+TABLE', 'DROP TABLE'),
        (r'^\s*git\s+push\s+--force', 'git push --force'),
        (r'^\s*TRUNCATE', 'TRUNCATE'),
    ]
    
    for pattern, _ in patterns:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    
    # Special handling for DELETE without WHERE
    delete_pattern = r'DELETE\s+FROM\s+(\w+)\s*$'
    if re.search(delete_pattern, command.strip(), re.IGNORECASE) and not re.search(r'\bWHERE\b', command, re.IGNORECASE):
        return True
    
    return False