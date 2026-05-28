#!/bin/bash

# Claude Code pre-tool-use hook to block destructive bash commands
# Usage: Place in ~/.claude/hooks/ and make executable

set -euo pipefail

# Log file location
LOG_FILE="$HOME/.claude/hooks/blocked.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log blocked commands
log_blocked() {
    local timestamp=$(date -Iseconds)
    local command="$1"
    local project_path="${PWD}"
    echo "[$timestamp] Blocked: $command (Project: $project_path)" >> "$LOG_FILE"
}

# Function to block destructive commands
block_destructive_commands() {
    local cmd="$1"
    
    # Check for rm -rf
    if [[ "$cmd" == "rm -rf "* || "$cmd" == "rm -rf" ]]; then
        log_blocked "$cmd"
        echo "BLOCKED: Dangerous 'rm -rf' command detected. This command has been blocked for your safety."
        exit 1
    fi
    
    # Check for DROP TABLE
    if [[ "$cmd" == *"DROP TABLE"* ]]; then
        log_blocked "$cmd"
        echo "BLOCKED: Dangerous 'DROP TABLE' command detected. This command has been blocked for your safety."
        exit 1
    fi
    
    # Check for git push --force
    if [[ "$cmd" == "git push --force"* || "$cmd" == *" git push --force "* ]]; then
        log_blocked "$cmd"
        echo "BLOCKED: Dangerous 'git push --force' command detected. This command has been blocked for your safety."
        exit 1
    fi
    
    # Check for TRUNCATE
    if [[ "$cmd" == *"TRUNCATE"* ]]; then
        log_blocked "$cmd"
        echo "BLOCKED: Dangerous 'TRUNCATE' command detected. This command has been blocked for your safety."
        exit 1
    fi
    
    # Check for DELETE FROM without WHERE
    if [[ "$cmd" == *"DELETE FROM"* && ! "$cmd" == *"WHERE"* ]]; then
        log_blocked "$cmd"
        echo "BLOCKED: Dangerous 'DELETE FROM' without WHERE clause detected. This command has been blocked for your safety."
        exit 1
    fi
}

# Main execution
if [[ "${1:-}" == "pre-tool-use" ]]; then
    block_destructive_commands "$2"
fi