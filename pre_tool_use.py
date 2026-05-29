#!/usr/bin/env python3
import sys
import os
import re

def check_bash_command(command):
    # List of dangerous patterns to block
    dangerous_patterns = [
        r'rm\s+-rf', r'rm -rf',
        r'DROP\s+TABLE', r'DROP TABLE',
        r'git\s+push\s+--force', r'git push --force',
        r'TRUNCATE\s+', r'TRUNCATE',
        r'DELETE\s+FROM\s+(?![wW][hH][eE][rR][eE])', r'DELETE FROM'
    ]
    
    # Check if any dangerous patterns are present
    if re.search(r'|'.join(dangerous_patterns), command):
        return True
    return False

def check_destructive_commands(command):
    if check_bash_command(command):
        return "Blocked", command  # This returns the command that would be blocked
    return None