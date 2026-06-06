#!/usr/bin/env python3
import os
import sys
import time
from pathlib import Path

# Patterns to block
BLOCK_PATTERNS = [
    'rm -rf',
    'DROP TABLE',
    'git push --force',
    'TRUNCATE',
    'DELETE FROM'
]

def should_block_command(command):
    # Check if this is a DELETE FROM without a WHERE clause
    if command.strip().upper().startswith('DELETE FROM') and 'WHERE' not in command.upper():
        return True
    
    # Check other block patterns
    for pattern in BLOCK_PATTERNS:
        if pattern in command:
            return True
    return False

def log_blocked_command(command, project_path):
    log_file = Path.home() / '.claude' / 'hooks' / 'blocked.log'
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] Blocked command: {command.strip()}\n")
        f.write(f"  Project path: {project_path}\n")
        f.write(f"  Reason: Destructive command blocked\n\n")

def main():
    if len(sys.argv) < 3:
        # Not enough arguments, likely a normal bash command, don't block
        return 0
        
    command = sys.argv[1]
    project_path = sys.argv[2] if len(sys.argv) > 2 else "Unknown"
    
    if should_block_command(command):
        log_blocked_command(command, project_path)
        print("🚫 BLOCKED: This command has been blocked for security reasons.", file=sys.stderr)
        print("The following patterns are blocked: rm -rf, DROP TABLE, git push --force, TRUNCATE, DELETE FROM without WHERE", file=sys.stderr)
        return 1
    
    return 0

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)