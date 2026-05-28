#!/bin/bash

# Claude Code Hook: Pre-tool-use blocker for destructive commands
# 
# This hook blocks dangerous bash commands before they are executed.
# It checks the command content against known dangerous patterns.
#
# Installation:
#   mkdir -p ~/.claude/hooks
#   cp pre-tool-use-blocker.sh ~/.claude/hooks/pre-tool-use-blocker.sh
#   chmod +x ~/.claude/hooks/pre-tool-use-blocker.sh

set -euo pipefail

# Log file location
LOG_FILE="$HOME/.claude/hooks/blocked.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log blocked commands
log_blocked() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local project_path
    project_path=$(pwd)
    echo "[$timestamp] Blocked command: $1 (Project: $project_path)" >> "$LOG_FILE"
}

# Function to check for dangerous patterns
is_dangerous() {
    local command_content="$1"
    
    # Check for rm -rf pattern
    if echo "$command_content" | grep -qE '\brm\s+-[^-]*r[^-]*f\b|\brm\s+-[^-]*f[^-]*r\b'; then
        return 0
    fi
    
    # Check for DROP TABLE pattern (case insensitive)
    if echo "$command_content" | grep -qiE '\bDROP\s+TABLE\b'; then
        return 0
    fi
    
    # Check for git push --force pattern
    if echo "$command_content" | grep -qE '\bgit\s+push\s+--force\b|\bgit\s+push\s+-f\b'; then
        return 0
    fi
    
    # Check for TRUNCATE pattern (case insensitive)
    if echo "$command_content" | grep -qiE '\bTRUNCATE\b'; then
        return 0
    fi
    
    # Check for DELETE FROM without WHERE pattern (case insensitive)
    if echo "$command_content" | grep -qiE '\bDELETE\s+FROM\b' && ! echo "$command_content" | grep -qiE '\bWHERE\b'; then
        return 0
    fi
    
    return 1
}

# Main execution
main() {
    # Read the command from stdin
    local command_content
    read -r command_content
    
    # Check if the command is dangerous
    if is_dangerous "$command_content"; then
        # Log the blocked command
        log_blocked "$command_content"
        
        # Output error message to stderr
        cat >&2 << EOF
========================================
 ⚠️  DANGEROUS COMMAND BLOCKED ⚠️
========================================

The following command was blocked for your safety:

$command_content

This hook prevents destructive operations like:
- rm -rf commands
- DROP TABLE statements
- git push --force commands
- TRUNCATE statements
- DELETE FROM without WHERE clauses

Blocked at: $(date '+%Y-%m-%d %H:%M:%S')
Project: $(pwd)

If you need to execute this command, temporarily disable the hook.
EOF
        
        # Exit with error code to prevent command execution
        exit 1
    fi
    
    # If not dangerous, output the command unchanged
    echo "$command_content"
}

# Run main function
main