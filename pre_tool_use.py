#!/usr/bin/env python3
import sys
import os
from datetime import datetime
import re

# Destructive command patterns to block
DANGEROUS_PATTERNS = [
    r'rm\s+-rf',
    r'DROP\s+TABLE',
    r'git\s+push\s+--force',
    r'TRUNCATE',
    r'DELETE\s+FROM\s+\w+\s*(?=;|$)'
]

def is_dangerous_command(command):
    """Check if command matches any dangerous patterns"""
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False

def log_blocked_command(command, project_path):
    """Log blocked command attempts"""
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    
    with open(log_file, "a") as f:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"[{timestamp}] Blocked: {command} in {project_path}\n")

def main():
    # Read command from stdin
    command = sys.stdin.read().strip()
    
    # Get project path from environment or default to current directory
    project_path = os.environ.get('PROJECT_PATH', os.getcwd())
    
    # Check if command is dangerous
    if is_dangerous_command(command):
        log_blocked_command(command, project_path)
        print("Claude Code Assistant: This command has been blocked for safety.", file=sys.stderr)
        print("Blocked dangerous command:", command, file=sys.stderr)
        sys.exit(1)
    else:
        # Pass through safe commands
        print(command)
        sys.exit(0)

if __name__ == "__main__":
    main()