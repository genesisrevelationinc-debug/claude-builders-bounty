#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook that blocks destructive bash commands.
"""

import sys
import os
import re
from datetime import datetime
import subprocess

# Destructive patterns to block
DESTRUCTIVE_PATTERNS = [
    r'rm\s+-rf',
    r'DROP\s+TABLE',
    r'git\s+push\s+--force',
    r'TRUNCATE',
    r'DELETE\s+FROM\s+\w+\s*;?$'  # DELETE FROM without WHERE clause
]

def block_destructive_commands(command_line, tool_name, tool_args):
    # Only check bash commands
    if tool_name != 'bash':
        return None, None
    
    # Check if command matches any destructive patterns
    full_command = ' '.join(tool_args)
    for pattern in DSTRUCTIVE_PATTERNS:
        if re.search(pattern, full_command, re.IGNORECASE):
            # Log the blocked attempt
            log_entry = f"[{datetime.now().isoformat()}] Blocked: {full_command} | Project: {os.getcwd()}\n"
            os.makedirs(os.path.expanduser('~/.claude/hooks'), exist_ok=True)
            with open(os.path.expanduser('~/.claude/hooks/blocked.log'), 'a') as f:
                f.write(log_entry)
            
            block_message = f"🚫 Blocked destructive command: {full_command}\n"
            block_message += "The following destructive commands are blocked for your safety:\n"
            block_message += "- rm -rf\n- DROP TABLE\n- git push --force\n- TRUNCATE\n- DELETE FROM without WHERE clause\n"
            return False, block_message
    
    # If we get here, no destructive patterns matched
    return None, None

def main():
    if len(sys.argv) < 3:
        return
    
    tool_name = sys.argv[1]
    tool_args = sys.argv[2:]
    command_line = ' '.join(sys.argv[2:]) if len(sys.argv) > 2 else ""
    
    block_result, message = block_destructive_commands(command_line, tool_name, tool_args)
    if message:
        print(message)
    if block_result is False:
        sys.exit(1)

if __name__ == "__main__":
    main()