#!/usr/bin/env python3

import sys
import os
import json
import re
from datetime import datetime
from pathlib import Path

def log_blocked_command(command: str, project_path: str):
    """Log blocked command to file"""
    log_file = Path.home() / ".claude" / "hooks" / "blocked.log"
    timestamp = datetime.now().isoformat()
    log_entry = f"[{timestamp}] Blocked command: {command} in project: {project_path}\n"
    
    # Ensure log directory exists
    log_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(log_file, "a") as f:
        f.write(log_entry)

def block_destructive_command(command_data):
    """Check if command is destructive and should be blocked"""
    # Extract command and project path
    command = command_data.get("command", "")
    project_path = command_data.get("cwd", "")
    
    # Destructive patterns to block
    destructive_patterns = [
        r"rm\s+-rf",
        r"DROP\s+TABLE",
        r"git\s+push\s+--force",
        r"TRUNCATE",
        r"DELETE\s+FROM(?!\s+\w+\s+WHERE)"
    ]
    
    # Check if any destructive pattern matches
    for pattern in destructive_patterns:
        if re.search(pattern, command, re.IGNORECASE):
            log_blocked_command(command, project_path)
            return True, f"Blocked destructive command: {command}"
    
    return False, None

def main():
    # Read input from stdin
    input_data = sys.stdin.read().strip()
    if not input_data:
        print(json.dumps({"result": "allow"}))
        return
    
    try:
        # Parse the input as JSON
        data = json.loads(input_data)
    except json.JSONDecodeError:
        # If not valid JSON, treat as plain text
        print(json.dumps({"result": "allow"}))
        return
    
    # Extract command information
    if isinstance(data, dict) and "tool" in data and data["tool"] == "bash":
        command_info = {
            "command": data.get("command", ""),
            "cwd": data.get("cwd", "")
        }
        is_blocked, message = block_destructive_command(command_info)
        if is_blocked:
            response = {
                "result": "block",
                "explanation": message
            }
            print(json.dumps(response))
            return
    
    # Default allow if not blocked
    print(json.dumps({"result": "allow"}))

if __name__ == "__main__":
    main()

"""
Sample input (from Claude):
{
  "tool": "bash",
  "command": "rm -rf /",
  "cwd": "/home/user/project"
}

Sample output (if blocked):
{
  "result": "block",
  "explanation": "Blocked destructive command: rm -rf /"
}

Sample output (if allowed):
{"result": "allow"}
"""