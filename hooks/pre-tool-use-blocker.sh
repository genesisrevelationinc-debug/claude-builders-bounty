#!/bin/bash

# Destructive command blocker hook for Claude Code
# Blocks destructive bash commands and logs attempts

# Configuration
LOG_FILE="$HOME/.claude/hooks/blocked.log"
HOOKS_PATH="$HOME/.claude/hooks"

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Function to log blocked commands
log_blocked() {
    local timestamp=$(date -Iseconds)
    local command="$1"
    local project_path="$2"
    echo "$timestamp - Command: $command - Project: $project_path" >> "$LOG_FILE"
}

# Block list of dangerous commands
is_dangerous() {
    case "$1" in
        *"rm -rf"*)
            return 0
            ;;
        *"DROP TABLE"*)
            return 0
            ;;
        *"git push --force"*)
            return 0
            ;;
        *"TRUNCATE"*)
            return 0
            ;;
        *"DELETE FROM"*"WHERE"*"*)
            return 1
            ;;
        *"DELETE FROM"*)
            # Check if it's a destructive DELETE without WHERE clause
            return 0
            ;;
    esac
    return 1
}

# Main function to check and block commands
check_and_block() {
    local command="$1"
    local project_path="$2"
    
    if is_dangerous "$command"; then
        echo "Blocked potentially destructive command: $command" >&2
        log_blocked "$command" "$project_path"
        exit 1
    fi
}