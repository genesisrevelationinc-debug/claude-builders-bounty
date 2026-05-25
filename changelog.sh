#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Get the last git tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE=""
else
    echo "Generating changelog since tag: $LAST_TAG"
    COMMIT_RANGE="${LAST_TAG}..HEAD"
fi

# Get commits since last tag (or all commits if no tag)
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%s" --no-merges)
else
    COMMITS=$(git log --pretty=format:"%s" --no-merges "$COMMIT_RANGE")
fi

if [ -z "$COMMITS" ]; then
    echo "No new commits found since $LAST_TAG"
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

while IFS= read -r commit; do
    # Skip empty lines
    [ -z "$commit" ] && continue
    
    # Categorize based on conventional commit prefixes or keywords
    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    if echo "$lower_commit" | grep -qE '^(feat|add|new|introduce)|\badd(ed|ing)?\b'; then
        ADDED="${ADDED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(fix|bug|patch)|\bfix(ed|ing)?\b'; then
        FIXED="${FIXED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(remove|delete|drop|revert)|\bremove(d|ing)?\b|\bdelete(d|ing)?\b'; then
        REMOVED="${REMOVED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(change|update|modify|refactor|improve|upgrade)|\bchange(d|ing)?\b|\bupdate(d|ing)?\b'; then
        CHANGED="${CHANGED}- ${commit}"$'\n'
    else
        # Default to Changed for uncategorized commits
        CHANGED="${CHANGED}- ${commit}"$'\n'
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
DATE=$(date +%Y-%m-%d)

# Determine version for header
if [ -n "$LAST_TAG" ]; then
    VERSION_HEADER="## [Unreleased] - ${DATE}"
else
    VERSION_HEADER="## [Unreleased] - ${DATE}"
fi

# Build the changelog content
CHANGELOG="# Changelog"$'\n\n'"All notable changes to this project will be documented in this file."$'\n\n'

CHANGELOG="${CHANGELOG}${VERSION_HEADER}"$'\n\n'

if [ -n "$ADDED" ]; then
    CHANGELOG="${CHANGELOG}### Added"$'\n\n'"${ADDED}"$'\n'
fi

if [ -n "$CHANGED" ]; then
    CHANGELOG="${CHANGELOG}### Changed"$'\n\n'"${CHANGED}"$'\n'
fi

if [ -n "$FIXED" ]; then
    CHANGELOG="${CHANGELOG}### Fixed"$'\n\n'"${FIXED}"$'\n'
fi

if [ -n "$REMOVED" ]; then
    CHANGELOG="${CHANGELOG}### Removed"$'\n\n'"${REMOVED}"$'\n'
fi

# Append existing changelog if it exists
if [ -f "CHANGELOG.md" ]; then
    # Extract content after the header to avoid duplication
    EXISTING=$(tail -n +4 CHANGELOG.md)
    CHANGELOG="${CHANGELOG}"$'\n'"${EXISTING}"
fi

# Write the changelog
echo "$CHANGELOG" > CHANGELOG.md

echo "✅ CHANGELOG.md generated successfully!"