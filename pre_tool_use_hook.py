#!/usr/bin/env python3
import re
import os
import sys
import time
import json

def pre_tool_use_hook(tool_name, tool_args=None, tool_call_id=None, project_path=None):
    # Define destructive command patterns to check
    destructive_patterns = [
        r'^\s*rm\s+-rf',
        r'^\s*DROP\s+TABLE',
        r'^\s*DELETE\s+FROM\s+(?!.*\bWHERE\b).*\b\)$',
        r'^\s*TRUNCATE\s+',
        r'^\s*git\s+push\s+--force',
    ]
    
    # Check if any of the tool arguments match destructive patterns
    if any(pattern in str(tool_args) for pattern in destructive_patterns):
        print(f"Blocked destructive command: {tool_args}")
        return True
    else:
