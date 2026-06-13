#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag; if none, use the first commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE=""
else
    echo "Latest tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# Build the git log command
if [ -z "$COMMIT_RANGE" ]; then
    GIT_LOG_CMD="git log --pretty=format:%s"
else
    GIT_LOG_CMD="git log ${COMMIT_RANGE} --pretty=format:%s"
fi

# Fetch commits
COMMITS=$($GIT_LOG_CMD 2>/dev/null || true)

if [ -z "$COMMITS" ]; then
    echo "No new commits since last tag."
    exit 0
fi

# Arrays for categories
ADDED=()
FIXED=()
CHANGED=()
REMOVED=()
OTHER=()

# Categorize commits
while IFS= read -r line; do
    [ -z "$line" ] && continue
    
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    
    if echo "$lower_line" | grep -qE '^(feat|add|new|introduce|implement|create|support)'; then
        ADDED+=("$line")
    elif echo "$lower_line" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
        FIXED+=("$line")
    elif echo "$lower_line" | grep -qE '^(remove|delete|drop|eliminate|deprecate|clean)'; then
        REMOVED+=("$line")
    elif echo "$lower_line" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize)'; then
        CHANGED+=("$line")
    else
        # Check for keywords anywhere in the message
        if echo "$lower_line" | grep -qE '\b(add|added|adding|feature|feat)\b'; then
            ADDED+=("$line")
        elif echo "$lower_line" | grep -qE '\b(fix|fixed|fixing|bug|patch|resolve)\b'; then
            FIXED+=("$line")
        elif echo "$lower_line" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|deprecate)\b'; then
            REMOVED+=("$line")
        elif echo "$lower_line" | grep -qE '\b(change|changed|changing|update|updated|updating|modify|modified|refactor|improve|improved|enhance|enhanced|upgrade|upgraded|rework|optimize|optimized)\b'; then
            CHANGED+=("$line")
        else
            OTHER+=("$line")
        fi
    fi
done <<< "$COMMITS"

# Generate CHANGELOG content
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [Unreleased] - $DATE"
    echo ""
    
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        for item in "${ADDED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    if [ ${#FIXED[@]} -gt 0 ]; then
        echo "### Fixed"
        for item in "${FIXED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "### Changed"
        for item in "${CHANGED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        for item in "${REMOVED[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    if [ ${#OTHER[@]} -gt 0 ]; then
        echo "### Other"
        for item in "${OTHER[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
} > "$CHANGELOG_FILE"

echo "✅ CHANGELOG.md generated successfully!"
echo "   Found: ${#ADDED[@]} added, ${#FIXED[@]} fixed, ${#CHANGED[@]} changed, ${#REMOVED[@]} removed, ${#OTHER[@]} other"