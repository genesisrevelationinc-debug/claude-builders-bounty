#!/bin/bash

# pre-tool-use hook to block destructive bash commands
# Save as: ~/.claude/hooks/pre_tool_use

set -e

# Configuration
HOOKS_DIR="$HOME/.claude/hooks"
BLOCKED_LOG="$HOOKS_DIR/blocked.log"
PROJECT_PATH=$(pwd)

# Ensure log directory exists
mkdir -p "$HOOKS_DIR"

# Log file for blocked commands
BLOCKED_LOG_FILE="$BLOCKED_LOG"

# Create log file if it doesn't exist
if [ ! -f "$BLOCKED_LOG_FILE" ]; then
    touch "$BLOCKED_LOG_FILE"
fi

# Destructive patterns to check
is_destructive() {
    local cmd="$1"
    
    # Check for destructive patterns
    if [[ "$cmd" == *"rm -rf"* ]]; then
        return 0
    elif [[ "$cmd" == *"DROP TABLE"* ]]; then
        return 0
    elif [[ "$cmd" == *"TRUNCATE"* ]]; then
        return 0
    elif [[ "$cmd" == *"git push --force"* ]]; then
        return 0
    elif [[ "$cmd" == *"DELETE FROM"* ]]; then
        # Special handling for DELETE FROM - only block if no WHERE clause
        if [[ ! "$cmd" == *WHERE* ]] && [[ ! "$cmd" == *where* ]]; then
            return 0
        fi
    fi
    
    return 1
}

block_destructive_command() {
    local cmd="$1"
    local project_path="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S%z")
    
    # Log the blocked command
    echo "$timestamp|$cmd|$project_path" >> "$BLOCKED_LOG_FILE"
    
    # Output message to Claude
    echo "I cannot execute this command as it appears to be destructive: $cmd"
    
    exit 1
}

# Main execution
if is_destructive "$1"; then
    block_destructive_command "$1" "$PROJECT_PATH"
fi

# If we get here, the command is allowed
exec <&3 3<&0
exec 3<&-

exit 0