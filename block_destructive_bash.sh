#!/bin/bash

# Log file for blocked commands
BLOCKED_LOG="$HOME/.claude/hooks/blocked.log"

# Function to log blocked attempts
log_blocked() {
    echo "$(date -u): $PWD: $*" >> "$BLOCKED_LOG" 
}

# Check if command matches destructive patterns
is_destructive() {
    local cmd="$1"
    if [[ "$cmd" == *"rm -rf"* ]] || 
       [[ "$cmd" == *"DROP TABLE"* ]] || 
       [[ "$cmd" == *"git push --force"* ]] || 
       [[ "$cmd" == *"TRUNCATE"* ]] || 
       [[ "$cmd" == *"DELETE FROM"* && ! "$cmd" == *"WHERE "* ]]; then
        return 0
    fi
    return 1
}

# Main hook logic
if is_destructive "$*"; then
    echo "🚫 ⛔️ Destructive command blocked: $*" >&2
    echo "Blocked potentially destructive command: $*" >&2
    echo "  - rm -rf" >&2
    echo "  - DROP TABLE" >&2
    echo "  - TRUNCATE" >&2
    echo "  - DELETE FROM (without WHERE)" >&2
    echo "  - git push --force" >&2
    log_blocked "$*"
    exit 1
fi

# If not blocked, execute the command
exec "$@"
