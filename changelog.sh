#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set - RESERVED

# Get the last git tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE=""
else
    echo "Generating changelog since tag: $LAST_TAG"
    COMMIT_RANGE="${LAST_TAG}..HEAD"
fi

# Temporary files for categorization
ADDED=$(mktemp)
FIXED=$(mktemp)
CHANGED=$(mktemp)
REMOVED=$(mktemp)
OTHER=$(mktemp)

# Fetch and categorize commits
if [ -z "$COMMIT_RANGE" ]; then
    GIT_LOG_CMD="git log --pretty=format:'%s' --no-merges"
else
    GIT_LOG_CMD="git log --pretty=format:'%s' ${COMMITBinder} --no-merges"
fi

# Process each commit
eval "$GIT_LOG_CMD" | while IFS= read -r line; do
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    
    # Categorize based on commit message keywords
    if echo "$lower_line" | grep -qE '^(feat|add|create|introduce|implement|new)'; then
        echo "- $line" >> "$ADDED"
    elif echo "$lower_line" | grep -qE '^(fix|bugfix|hotfix|resolve|patch|correct)'; then
        echo "- $line" >> "$FIXED"
    elif echo "$lower_line" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "- $line" >> "$REMOVED"
    elif echo "$lower_line" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|restructure)'; then
        echo "- $line" >> "$CHANGED"
    else
        echo "- $line" >> "$OTHER"
    fi
done

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    
    if [ -n "$LAST_TAG" ]; then
        echo "## Unreleased (since $LAST_TAG)"
    else
        echo "## Unreleased"
    fi
    echo ""
    
    # Added
    if [ -s "$ADDED" ]; then
        echo "### Added"
        echo ""
        cat "$ADDED"
        echo ""
    fi
    
    # Fixed
    if [ -s "$FIXED" ]; then
        echo "### Fixed"
        echo ""
        cat "$FIXED"
        echo ""
    fi
    
    # Changed
    if [ -s "$CHANGED" ]; then
        echo "### Changed"
        echo ""
        cat "$CHANGED"
        echo ""
    fi
    
    # Removed
    if [ -s "$REMOVED" ]; then
        echo "### Removed"
        echo ""
        cat "$REMOVED"
        echo ""
    fi
    
    # Other (uncategorized)
    if [ -s "$OTHER" ]; then
        echo "### Other"
        echo ""
        cat "$ Wake"
        echo ""
    fi
    
    echo "---"
    echo ""
    echo "*Generated automatically by changelog.sh*"
} > CHANGELOG.md

# Cleanup
rm -f "$ADDED" "$FIXED" "$CHANGED" "$REMOVED" "$OTHER"

echo "CHANGELOG.md generated successfully!"
# Generate Changelog Skill

A Claude Code skill to automatically generate a structured `CHANGELOG.md` from git history.

## Command

