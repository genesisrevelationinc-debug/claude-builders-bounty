#!/usr/bin/env python3
"""
Pre-tool-use hook that blocks destructive bash commands.
"""

import json
import sys
import os
import re
from datetime import datetime
from pathlib import Path

def log_blocked_command(command: str, project_path: str):
    """Log blocked command to file"""
    log_file = Path.home() / ".claude/hooks/blocked.log"
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a") as f:
        f.write(f"[{timestamp}] {project_path} - Blocked: {command}\n")

def is_destructive_command(command: str) -> bool:
    """Check if command is destructive"""
    # Normalize command for checking
    cmd = command.strip().lower()
    
    # Check for rm -rf
    if "rm -rf" in cmd or "rm -fr" in cmd:
        return True
        
    # Check for DROP TABLE
    if "drop table" in cmd:
        return True
        
    # Check for git push --force
    if "git push --force" in cmd or "git push -f" in cmd:
        return True
        
    # Check for TRUNCATE
    if re.search(r'\btruncate\b', cmd):
        return True
        
    # Check for DELETE FROM without WHERE
    # Match DELETE FROM followed by table name but not WHERE clause
    if re.search(r'\bdelete\s+from\s+\w+\s*$', cmd) or \
       re.search(r'\bdelete\s+from\s+\w+\s*;', cmd):
        return True
        
    return False

def main():
    """Main hook function"""
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
        
        # Extract command and project path
        command = input_data.get("command", "")
        project_path = input_data.get("project_path", "unknown")
        
        # Check if command is destructive
        if is_destructive_command(command):
            # Log the blocked command
            log_blocked_command(command, project_path)
            
            # Return blocking response
            response = {
                "blocked": True,
                "reason": f"Blocked destructive command: {command}",
                "message": f"⚠️  Command blocked for safety: '{command}'\n\n"
                          f"This command contains destructive patterns that could cause data loss:\n"
                          f"- rm -rf\n"
                          f"- DROP TABLE\n"
                          f"- git push --force\n"
                          f"- TRUNCATE\n"
                          f"- DELETE FROM without WHERE clause\n\n"
                          f"Check ~/.claude/hooks/blocked.log for details."
            }
            print(json.dumps(response))
            sys.exit(0)
            
        # Allow non-destructive commands
        print(json.dumps({"blocked": False}))
        
    except Exception as e:
        # In case of error, don't block the command
        print(json.dumps({"blocked": False, "error": str(e)}))

if __name__ == "__main__":
    main()