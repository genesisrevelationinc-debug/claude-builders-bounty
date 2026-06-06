#!/bin/bash

# Pre-tool-use hook to block destructive bash commands
# This hook prevents dangerous operations like rm -rf, DROP TABLE, etc.

HOOK_DIR="$HOME/.claude/hooks"
LOG_FILE="$HOOK_DIR/blocked.log"

# Ensure log directory exists
mkdir -p "$HOOK_DIR"

# Function to log blocked commands
log_blocked_command() {
    local command="$1"
    local project_path="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] Blocked command: $command | Project: $project_path" >> "$LOG_FILE"
}

# Check if the command matches any blocked patterns
is_dangerous_command() {
    local cmd="$1"
    
    # Check for destructive patterns
    if [[ "$cmd" == *"rm -rf"* ]] || 
       [[ "$cmd" == *"DROP TABLE"* ]] || 
       [[ "$cmd" == *"git push --force"* ]] || 
       [[ "$cmd" == *"TRUNCATE"* ]] ||
       [[ "$cmd" == *"DELETE FROM"* && "$cmd" != *"WHERE"* ]]; then
        return 0  # true in bash
    else
        return 1  # false in bash
    fi
}

# Main logic
if [ "$TOOL_NAME" = "bash" ]; then
    # Check if we're running a destructive command
    if is_dangerous_command "$TOOL_INPUT"; then
        # Log the blocked attempt
        log_blocked_command "$TOOL_INPUT" "$PROJECT_PATH"
        
        # Output explanation to Claude
        if [[ "$TOOL_INPUT" == *"rm -rf"* ]]; then
            echo "BLOCKED: rm -rf command detected. This command is considered destructive and has been blocked for your safety."
        elif [[ "$TOOL_INPUT" == *"DROP TABLE"* ]]; then
            echo "BLOCKED: DROP TABLE command detected. This command is considered destructive and has been blocked for your safety."
        elif [[ "$TOOL_INPUT" == *"git push --force"* ]]; then
            echo "BLOCKED: git push --force command detected. This command is considered destructive and has been blocked for your safety."
        elif [[ "$TOOL_INPUT" == *"TRUNCATE"* ]]; then
            echo "BLOCKED: TRUNCATE command detected. This command is considered destructive and has been blocked for your safety."
        elif [[ "$TOOL_INPUT" == *"DELETE FROM"* ]] && [[ "$TOOL_INPUT" != *"WHERE"* ]]; then
            echo "BLOCKED: Unqualified DELETE command detected. This command is considered destructive and has been blocked for your safety."
        fi
        
        # Exit with error to prevent command execution
        exit 1
    fi
fi

# If we reach here, the command is not blocked, so let it run normally
exit 0