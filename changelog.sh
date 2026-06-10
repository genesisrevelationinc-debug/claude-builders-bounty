#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# This script generates a CHANGELOG.md file based on commit history since the last tag.
# It categorizes changes into Added, Fixed, Changed, and Removed sections.
#
# Usage: ./changelog.sh
#
# Requirements:
# - Git repository with at least one tag
# - Conventional commit messages (optional but recommended)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error:${NC} Not a git repository"
    exit 1
fi

# Get the last tag or initial commit if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)
echo -e "${BLUE}Last tag:${NC} $LAST_TAG"

# Get commits since last tag
COMMITS=$(git log --pretty=format:"%s" $LAST_TAG..HEAD 2>/dev/null)

# If no new commits, exit
if [ -z "$COMMITS" ]; then
    echo -e "${BLUE}No new commits since last tag.${NC}"
    exit 0
fi

# Create temporary file for changelog entries
TEMP_FILE=$(mktemp)

# Function to categorize commits
categorize_commit() {
    local commit_msg="$1"
    
    # Convert to lowercase for case-insensitive matching
    local msg_lower=$(echo "$commit_msg" | tr '[:upper:]' '[:lower:]')
    
    # Categorization based on keywords
    if echo "$msg_lower" | grep -qE "(add|new|feature|implement)"; then
        echo "### Added" >> "$TEMP_FILE"
        echo "- $commit_msg" >> "$TEMP_FILE"
    elif echo "$msg_lower" | grep -qE "(fix|bug|resolve)"; then
       echo "### Fixed" >> "$TEMP_FILE"
        echo "- $commit_msg" >> "$TEMP_FILE"
    elif echo "$msg_lower" | grep -qE "(change|update|modify|improve)"; then
        echo "### Changed" >> "$TEMP_FILE"
        echo "- $commit_msg" >> "$TEMP_FILE"
    elif echo "$msg_lower" | grep -qE "(remove|delete|deprecate)"; then
        echo "### Removed" >> "$TEMP_FILE"
        echo "- $commit_msg" >> "$TEMP_FILE"
    else
        # Default to Added if no match
        echo "### Added" >> "$TEMP_FILE"
        echo "- $commit_msg" >> "$TEMP_FILE"
    fi
}

# Process each commit
echo "$COMMITS" | while IFS= read -r commit; do
    if [ -n "$commit" ]; then
        categorize_commit "$commit"
    fi
done

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%Y-%m-%d)

# Create new changelog content
NEW_CONTENT=$(cat <<EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

$(cat "$TEMP_FILE")

## [$CURRENT_DATE] - $(git describe --tags --abbrev=0 2>/dev/null || echo "0.1.0")

EOF
)

# Write to CHANGELOG.md
echo "$NEW_CONTENT" > CHANGELOG.md

# Clean up
rm "$TEMP_FILE"

echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"