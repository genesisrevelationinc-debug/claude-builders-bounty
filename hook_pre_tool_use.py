#!/usr/bin/env python3

import sys
import re
import os
import json
import time

def log_blocked_command(command, project_path, timestamp):
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    with open(log_file, "a") as f:
        log_entry = {
            "timestamp": timestamp,
            "command": command,
            "project_path": project_path
        }
        f.write(json.dumps(log_entry) + "\n")

def block_destructive_commands():
    # Commands to block
    blocked_patterns = [
        r'rm\s+-rf',
        r'DROP\s+TABLE',
        r'git\s+push\s+--force',
        r'TRUNCATE',
        r'DELETE\s+FROM\s+\w+\s*;',  # DELETE FROM table;
    ]
    
    input_command = sys.argv[1] if len(sys.argv) > 1 else ""
    
    # Check if command matches any blocked pattern
    for pattern in blocked_patterns:
        if re.search(pattern, input_command, re.IGNORECASE):
            project_path = os.getcwd()
            timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            log_blocked_command(input_command, project_path, timestamp)
            print(f"❌ BLOCKED: Dangerous command detected and prevented: {input_command}")
            print("📝 Blocked commands are logged in ~/.claude/hooks/blocked.log")
            sys.exit(1)
    
    # If no dangerous patterns detected, allow command to proceed
    print("✅ Command is safe. Allowing execution.")
    return 0

if __name__ == "__main__":
    block_destructive_commands()

"""
Claude Code Hook: Pre-tool-use
Blocks destructive bash commands
"""

# Add to ~/.claude/hooks/pre-tool-use

import sys
import re
import os
import json
import time
from datetime import datetime

def log_blocked_command(command, project_path):
    log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as f:
        log_entry = {
            "timestamp": timestamp,
            "command": command,
            "project_path": project_path
        }
        f.write(json.dumps(log_entry) + "\n")

def main():
    blocked_patterns = [
        r'rm\s+-rf',
        r'DROP\s+TABLE',
        r'git\s+push\s+--force',
        r'TRUNCATE',
        r'DELETE\s+FROM\s+\w+\s*;'  # DELETE FROM table;
    ]
    
    input_command = sys.argv[1] if len(sys.argv) > 1 else ""
    
    for pattern in blocked_patterns:
        if re.search(pattern, input_command, re.IGNORECASE):
            project_path = os.getcwd()
            timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            log_blocked_command(input_command, project_path)
            print(f"❌ BLOCKED: Dangerous command detected and prevented: {input_command}")
            print("📝 Blocked commands are logged in ~/.claude/hooks/blocked.log")
            sys.exit(1)
    
    # If no dangerous patterns detected, allow command to proceed
    print("✅ Command is safe. Allowing execution.")
    sys.exit(0)

if __name__ == "__main__":
    main()
