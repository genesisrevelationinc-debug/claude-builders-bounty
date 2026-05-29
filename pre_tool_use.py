#!/usr/bin/env python3
import sys
import json
import re

def check_bash_command(command):
    # Check if command contains dangerous patterns
    dangerous_patterns = [
        r'rm\s+-rf.*',
        r'DROP\s+TABLE',
        r'TRUNCATE\s+',
        r'DELETE\s+FROM\s+(?![wW][hH][eE][rR][eE])',
        r'git\s+push\s+--force'
    ]
    
    for pattern in dangerous_patterns:
        if re.search(pattern, command, re.IGNORECASE):
            return True
    return False

def handle_command(command):
    if check_destructive_commands(command):
        return "blocked command"
    return None
