#!/usr/bin/env python3
import sys
import os
import re
import json
import datetime
import subprocess

def get_claude_code_dir():
    """Get Claude Code project directory from environment or default to current directory."""
    return os.environ.get('CLAUDE_CODE_DIR', os.getcwd())

def log_blocked_command(command, project_path):
    """Log blocked command to file"""
    log_file = os.path.expanduser('~/.claude/hooks/blocked.log')
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_entry = {
        'timestamp': timestamp,
        'command': command,
        'project_path': project_path
    }
    
    with open(log_file, 'a') as f:
        f.write(f"[{timestamp}] Blocked command: {command} in {project_path}\n")

def block_destructive_commands():
    """Main function to check and block destructive commands"""
    # Read the tool use request from stdin
    input_data = json.load(sys.stdin)
    tool_name = input_data.get('tool_name', '')
    tool_input = input_data.get('input', {})
    
    # Check if it's a bash command
    if tool_name == 'bash' or tool_name == 'shell':
        command = tool_input.get('command', '')
        if is_destructive_command(command):
            project_path = get_claude_code_dir()
            log_blocked_command(command, project_path)
            print(f"❌ BLOCKED: {command}", file=sys.stderr)
            print("This command has been blocked for security reasons.", file=sys.stderr)
            sys.exit(1)
        else:
            # Command is safe, allow it
            print(json.dumps(input_data))
            return
    
    # Default: pass through the input data
    print(json.dumps(input_data))

def is_destructive_command(command):
    """Check if command contains destructive patterns"""
    destructive_patterns = [
        r'rm\s+-rf',
        r'DROP\s+TABLE',
        r'TRUNCATE',
        r'DELETE\s+FROM(?!\s+WHERE)',
        r'git\s+push\s+--force'
    ]
    
    for pattern in destructive_patterns:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False