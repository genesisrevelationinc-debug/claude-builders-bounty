#!/usr/bin/env python3

import sys
import json
import re
from datetime import datetime
import os
import logging

# Set up logging
log_file = os.path.expanduser("~/.claude/hooks/blocked.log")
os.makedirs(os.path.dirname(log_file), exist_ok=True)

logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format='%(asctime)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

def block_destructive_commands():
    try:
        # Read the tool use request from stdin
        tool_use = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("Error: Invalid JSON input")
        sys.exit(1)

    # Check if this is a bash tool use request
    if tool_use.get("tool") != "bash" or not tool_use.get("command"):
        # If not a bash command, allow it to proceed
        json.dump(tool_use, sys.stdout)
        sys.exit(0)

    command = tool_use["command"]
    project_path = tool_use.get("project_path", "Unknown")

    # Define destructive patterns
    destructive_patterns = [
        r"rm\s+-rf",
        r"DROP\s+TABLE",
        r"git\s+push\s+--force",
        r"TRUNCATE",
        r"DELETE\s+FROM(?!\s+\w+\s+WHERE).*(?=;|$",  # DELETE FROM without WHERE clause
    ]

    # Check for destructive patterns
    for pattern in destructive_patterns:
        if re.search(pattern, command, re.IGNORECASE):
            # Log the blocked attempt
            logging.info(f"Blocked command: {command} | Project path: {project_path}")
            
            # Print explanation to Claude
            print(f"❌ Blocked execution of destructive command: {command}")
            print("This command has been blocked for safety.")
            if "rm -rf" in command:
                print("Use 'rm' with specific files only, not 'rm -rf /'")
            elif "DROP TABLE" in command:
                print("Database table drops require manual confirmation")
            elif "git push --force" in command:
                print("Destructive git pushes are blocked. Use '--force-with-lease' instead")
            elif "TRUNCATE" in command:
                print("TRUNCATE operations are not allowed")
            elif "DELETE FROM" in command:
                print("DELETE operations without WHERE clauses are not allowed")
            print("\nTo execute this command, remove the pre-tool-use hook or whitelist it manually.")
            
            # Exit with error code to prevent command execution
            sys.exit(1)

    # If no destructive patterns found, allow the command
    json.dump(tool_use, sys.stdout)

if __name__ == "__main__":
    block_destructive_commands()