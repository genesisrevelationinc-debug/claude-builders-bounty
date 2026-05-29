#!/usr/bin/env python3

import sys
import os
import datetime
import json
import re

DANGEROUS_PATTERNS = [
    r'rm\s+-rf',
    r'drop\s+table',
    r'git\s+push\s+--force',
    r'truncate',
    r'delete\s+from\s+(?!.*\bwhere\b)'
]

def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("Error: Invalid JSON input")
        sys.exit(1)

    command = data.get('command', '')
    cwd = data.get('cwd', 'Unknown')
    
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            log_blocked_command(command, cwd)
            print(f"Blocked potentially destructive command: {command}")
            sys.exit(1)
    
    print(json.dumps(data))

def log_blocked_command(cmd, project_path):
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] {cmd} - {project_path}\n")
        
if __name__ == "__main__":
    main()

def log_blocked_command(cmd, project_path):
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] {cmd} - {project_path}\n")