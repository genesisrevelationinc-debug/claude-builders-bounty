#!/bin/bash

# Claude Code pre-tool-use hook to block destructive bash commands
# This script should be placed in ~/.claude/hooks/pre-tool-use

# Exit codes:
# 0 - Allow command to proceed
# 1 - Block command (with error message)

# Log file for blocked commands
LOG_FILE="$HOME/.claude/hooks/blocked.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log blocked commands
log_blocked() {
    local timestamp=$(date -Iseconds)
    local project_path=$(pwd)
    echo "[$timestamp] [BLOCKED] $1 [PROJECT: $project_path]" >> "$LOG_FILE"
}

# Check if the command is bash
if [[ "$TOOL_NAME" != "bash" ]]; then
    exit 0
fi

# Get the command being executed
cmd="$TOOL_INPUT"

# Define dangerous patterns
patterns=(
    "rm -rf"
    "DROP TABLE"
    "git push --force"
    "TRUNCATE"
)

# Check for DELETE FROM without WHERE clause (case insensitive)
if echo "$cmd" | grep -iqE "DELETE FROM [^;]*;?" && ! echo "$cmd" | grep -iqE "DELETE FROM [^;]*WHERE"; then
    echo "BLOCKED: DELETE command without WHERE clause is not allowed for safety reasons."
    log_blocked "$cmd"
    exit 1
fi

# Check for other dangerous patterns
for pattern in "${patterns[@]}"; do
    if echo "$cmd" | grep -i "$pattern" >/dev/null; then
        echo "BLOCKED: Dangerous command pattern detected: $pattern"
        log_blocked "$cmd"
        exit 1
    fi
done

# Special handling for rm -rf with slash patterns
if echo "$cmd" | grep -E "rm.*-.*r.*f.*/" >/dev/null || echo "$cmd" | grep -E "rm.*-.*f.*r.*/" >/dev/null; then
    echo "BLOCKED: rm -rf with directory path is not allowed for safety reasons."
    log_blocked "$cmd"
    exit 1
fi

# If we get here, the command is allowed
exit 0