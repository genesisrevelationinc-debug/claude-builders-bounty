#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Get the last git tag, or use empty string if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get commits since last tag (or all commits if no tag)
if [ -n "$LAST_TAG" ]; then
    COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s" 2>/dev/null || echo "")
else
    COMMITS=$(git log --pretty=format:"%s" 2>/dev/null || echo "")
fi

# If no commits found, exit
if [ -z "$COMMITS" ]; then
    echo "No commits found since last tag."
    exit 0
fi

# Initialize category arrays
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

# Categorize each commit
while IFS= read -r commit; do
    # Skip empty lines
    [ -z "$commit" ] && continue
    
    # Extract the message (remove conventional commit prefix if present)
    message="$commit"
    
    # Categorize based on keywords and conventional commit prefixes
    if echo "$message" | grep -qiE '^(feat|add|new|introduce)|\b(add|adds|added|adding|new|introduce|introduces|introduced|feature)\b'; then
        ADDED+=("$message")
    elif echo "$message" | grep -qiE '^(fix|bugfix|hotfix)|\b(fix|fixes|fixed|fixing|bug|bugs|bugfix|resolve|resolves|resolved|patch|patches|patched)\b'; then
        FIXED+=("$message")
    elif echo "$message" | grep -qiE '^(remove|delete|drop)|\b(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|deprecate|deprecates|deprecated)\b'; then
        REMOVED+=("$message")
    elif echo "$message" | grep -qiE '^(change|update|refactor|improve|modify|enhance|upgrade)|\b(change|changes|changed|changing|update|updates|updated|updating|refactor|refactored|refactoring|improve|improves|improved|improving|modify|modifies|modified|modifying|enhance|enhances|enhanced|enhancing|upgrade|upgrades|upgraded|rework|reworked|optimize|optimized|polish|polished)\b'; then
        CHANGED+=("$message")
    else
        OTHER+=("$message")
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    
    # Date header
    DATE=$(date +%Y-%m-%d)
    if [ -n "$LAST_TAG" ]; then
        echo "## [Unreleased] - $DATE"
    else
        echo "## [$DATE]"
    fi
    echo ""
    
    # Added
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        for item in "${ADDED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    # Fixed
    if [ ${#FIXED[@]} -gt 0 ]; then
        echo "### Fixed"
        for item in "${FIXED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    # Changed
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "### Changed"
        for item in "${CHANGED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    # Removed
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        for item in "${REMOVED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    # Other (uncategorized)
    if [ ${#OTHER[@]} -gt 0 ]; then
        echo "### Other"
        for item in "${OTHER[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
} > CHANGELOG.md

echo "CHANGELOG.md generated successfully!"
if [ -n "$LAST_TAG" ]; then
    echo "Commits since tag: $LAST_TAG"
else
    echo "No previous tag found — included all commits."
fi