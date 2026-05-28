#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.

Blocks:
- rm -rf
- DROP TABLE
- git push --force
- TRUNCATE
- DELETE FROM without WHERE
"""

import os
import sys
import json
import re
from datetime import datetime
from pathlib import Path

def get_project_path():
    """Get the current project path (current working directory)"""
    return str(Path.cwd())

def log_blocked_command(command, project_path):
    """Log blocked command to the log file"""
    hook_dir = Path.home() / '.claude' / 'hooks'
    log_file = hook_dir / 'blocked.log'
    
    # Create directories if they don't exist
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] [{project_path}] BLOCKED: {command}\n"
    
    with open(log_file, 'a') as f:
        f.write(log_entry)

def is_destructive_command(command):
    """Check if command contains destructive patterns"""
    # Normalize command for case-insensitive matching
    cmd_lower = command.lower().strip()
    
    # Check for rm -rf pattern (including variants like rm -rf /)
    if re.search(r'rm\s+-(?:r?f|fr?)\s+', cmd_lower) or 'rm -rf' in cmd_lower:
        return True
    
    # Check for DROP TABLE (case insensitive)
    if 'drop table' in cmd_lower:
        return True
    
    # Check for git push --force and git push -f
    if 'git push' in cmd_lower and ('--force' in cmd_lower or '-f' in cmd_lower):
        return True
    
    # Check for TRUNCATE (case insensitive)
    if 'truncate' in cmd_lower:
        return True
    
    # Check for DELETE FROM without WHERE (case insensitive)
    # Match DELETE FROM followed by any non-whitespace chars, then end or newline or semicolon
    # but not followed by WHERE
    if re.search(r'delete\s+from\s+\w+(?!\s+where)', cmd_lower):
        return True
    
    return False

def main():
    """Main hook function"""
    try:
        # Read the JSON input from stdin
        input_data = json.load(sys.stdin)
        
        # Extract command and tool name
        tool_name = input_data.get('tool_name', '')
        command = input_data.get('command', '')
        project_path = get_project_path()
        
        # Only check bash commands
        if tool_name != 'bash':
            # Not a bash command, allow it
            json.dump({"allow": True}, sys.stdout)
            return
        
        # Check if it's a destructive command
        if is_destructive_command(command):
            # Log the blocked command
            log_blocked_command(command, project_path)
            
            # Block the command
            response = {
                "allow": False,
                "message": f"❌ BLOCKED: Destructive command detected!\n\n"
                          f"Command: {command}\n"
                          f"Project: {project_path}\n\n"
                          f"This command was blocked for security reasons.\n"
                          f"Blocked patterns: rm -rf, DROP TABLE, git push --force, TRUNCATE, DELETE FROM (without WHERE)"
            }
            json.dump(response, sys.stdout)
            return
        
        # Allow non-destructive commands
        json.dump({"allow": True}, sys.stdout)
        
    except Exception as e:
        # In case of any error, allow the command to proceed
        # We don't want to block legitimate commands due to hook errors
        error_response = {
            "allow": True,
            "message": f"⚠️  Hook error (allowing command to proceed): {str(e)}"
        }
        json.dump(error_response, sys.stdout)

if __name__ == "__main__":
    main()