#!/usr/bin/env python3

import os
import json
import re
from datetime import datetime
import sys

def log_blocked_command(command, project_path):
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] Command blocked: {command} | Project: {project_path}\n"
    
    with open(log_file, "a") as f:
        f.write(log_entry)

def check_destructive_command(command):
    # Define destructive patterns to block
    destructive_patterns = [
        r'^\s*rm\s+-rf.*',
        r'^\s*DROP\s+TABLE.*',
        r'^\s*git\s+push\s+--force.*',
        r'^\s*TRUNCATE.*',
        r'^\s*DELETE\s+FROM\s+\w+\s*$',  # DELETE FROM without WHERE
        r'^\s*DELETE\s+FROM\s+.*\s+TRUNCATE.*',
    ]
    
    for pattern in destructive_patterns:
        if re.match(pattern, command):
            return True
    return False

def main():
    # Get the command from Claude Code
    if len(sys.argv) > 1:
        command = sys.argv[1]
    else:
        # If run directly, exit normally
        return
    
    # Get the project path
    project_path = os.getcwd()
    
    # Check if command is destructive
    if check_destructive_command(command):
        # Log the attempt
        log_blocked_command(command, project_path)
        
        # Block execution by returning error message
        print(f"Blocked destructive command: {command}", file=sys.stderr)
        print("This command has been blocked as it contains potentially destructive operations.", file=sys.stderr)
        print("Destructive commands like 'rm -rf', 'DROP TABLE', 'git push --force',", file=sys.stderr)
        print("'TRUNCATE', and 'DELETE FROM' without WHERE are not allowed.", file=sys.stderr)
        sys.exit(1)
    
    # If not blocked, output the command for Claude Code to execute
    print(command)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        command = sys.argv[1]
    else:
        # If run directly, exit
        sys.exit(0)
        
    # Check for destructive patterns
    destructive_patterns = [
        r'^\s*rm\s+-rf.*',
        r'^\DROP\s+TABLE.*',
        r'^\s*git\s+push\s+--force.*',
        r'^\s*TRUNCATE.*',
        r'^\s*DELETE\s+FROM\s+\w+\s*$',
        r'^\s*DELETE\s+FROM\s+.*\s+TRUNCATE.*',
    ]
    
    is_destructive = False
    for pattern in destructive_patterns:
        if re.search(pattern, command):
            is_destructive = True
            break
            
    if is_destructive:
        # Log and block
        log_blocked_command(command, project_path)
        print(f"Blocked destructive command: {command}", file=sys.stderr)
        print("This command has been blocked as it contains destructive operations", file=sys.stderr)
        sys.exit(1)
    else:
        # Allow non-destructive commands to proceed
        print(command)

if __name__ == "__main__":
    main()