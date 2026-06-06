#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path

def log_blocked_command(command, project_path):
    """Log blocked commands to file with timestamp"""
    log_file = Path.home() / ".claude" / "hooks" / "blocked.log"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] Command: {command} | Project: {project_path}\n")

def should_block_command(command):
    """Check if command matches any blocked patterns"""
    # Normalize command for checking
    cmd = command.strip().lower()
    
    # Block rm -rf
    if "rm -rf" in cmd:
        return True
        
    # Block SQL DROP TABLE
    if "drop table" in cmd:
        return True
        
    # Block git push --force
    if "git push --force" in cmd:
        return True
        
    # Block TRUNCATE
    if "truncate" in cmd:
        # Only block if it's a SQL TRUNCATE command
        if re.search(r'\btruncate\b', cmd):
            return True
            
    # Block DELETE FROM without WHERE
    if "delete from" in cmd and "where" not in cmd:
        return True
        
    return False

def main():
    """Main hook function"""
    if len(sys.argv) > 1:
        command = sys.argv[1]
        project_path = os.getcwd()
        
        if should_block_command(command):
            log_blocked_command(command, project_path)
            print(f"🚫 BLOCKED: Dangerous command detected: {command}")
            print("This command has been blocked for security reasons.")
            print("Check ~/.claude/hooks/blocked.log for details.")
            sys.exit(1)
    
    # If we get here, the command is allowed
    sys.exit(0)

if __name__ == "__main__":
    main()