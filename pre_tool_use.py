#!/usr/bin/env python3
"""
Pre-tool-use hook for Claude Code that blocks destructive bash commands.
"""

import json
import sys
import os
import re
from datetime import datetime
import logging

# Set up logging
log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
os.makedirs(os.path.dirname(log_file), exist_ok=True)
logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format='%(asctime)s - %(message)s'
)

def block_destructive_commands(command):
    """Check if command is destructive and should be blocked"""
    destructive_patterns = [
        r"rm\s+-rf",
        r"DROP\s+TABLE",
        r"git\s+push\s+--force",
        r"TRUNCATE",
        r"DELETE\s+FROM(?!\s+.*\s+WHERE\b)"
    ]
    
    for pattern in destructive_patterns:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False

def is_delete_without_where(command):
    """Check if DELETE command lacks WHERE clause"""
    if "DELETE FROM" in command.upper():
        # Simple check: if there's no WHERE clause, block it
        if not re.search(r"\bWHERE\b", command, re.IGNORECASE):
            return True
    return False

def main():
    # Read input from Claude
    input_data = sys.stdin.read()
    if not input_data:
        # No input, allow the command
        sys.exit(0)
    
    try:
        data = json.loads(input_data)
    except json.JSONDecodeError:
        # Invalid JSON, allow the command
        sys.exit(0)
    
    # Extract command
    command = data.get("command", "")
    
    # Check if command should be blocked
    if block_destructive_commands(command) or is_delete_without_where(command):
        project_path = data.get("project_path", os.getcwd())
        logging.info(f"Blocked command: {command} | Project: {project_path}")
        
        # Print message to Claude
        print("I cannot execute this command because it has been blocked for being potentially destructive.")
        print("Blocked command:", command)
        print("Blocked at:", datetime.now().isoformat())
        print("Project path:", project_path)
        sys.exit(1)  # Non-zero exit will prevent command execution
    
    # Allow non-destructive commands
    sys.exit(0)

if __name__ == "__main__":
    # Check if we're running as a hook
    if len(sys.argv) > 1 and sys.argv[1] == "pre-tool-use":
        main()
    else:
        # For direct execution/testing
        if not sys.stdin.isatty():
            # Simulate being called as a hook
            main()
        else:
            print("This script is intended to be used as a Claude Code pre-tool-use hook")
            print("It should be placed in ~/.claude/hooks/ and configured in Claude Code settings")
            sys.exit(0)