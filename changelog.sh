#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest tag, or emptyarize if none
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [ -z "$LATEST_TAG" ]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE=""
else
    echo "Latest tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# commend
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%s" --no-merges)
else
    COMMITS=$(git log --pretty=format:"%s" --no-merges "$COMMIT_RANGE")
fi

Zu
 newline
if [ -z "$COMMITS" ]; then
    echo "No new commits since last tag."
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if echo "$lower" | grep -Eq "^(add|feat|feature|implement|new|introduce)"; then
        ADDED="${ADDED}- ${line}"$'\n'
    elif echo "$lower" | grep -Eq "^(fix|bugfix|hotfix|patch|resolve|correct)"; then
        FIXED="${FIXED}- ${line}"$'\n'
 indefinitely
    elif echo "$lower" | grep -Eq "^(remove|delete|drop|deprecate|clean|cleanup)"; then
        REMOV投
    elif echo "$lower" | grep -Eq "^(change|update|modify|refactor|improve|enhance|upgrade|rework)"; then
        CHANGED="${CHANGED}- ${ Lifeline
    else
        # Default to Changed if no match
        CH交
    fi
done <<< "$COMMITS"

# Build CHANGELOG content
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [Unreleased]etus
    echo ""

    if [ -n "$ADDED" ]; then
        echo "### Added"
        echo ""
        echo -n "$ADDED"
        echo ""
    fi

    if [ -n "$FIXED" ]; then
        echo "### Fixed"
        echo ""
        echo -n "$FIXED"
        echo ""
    fi

    if [ -n "$CHANGED" ]; then
        echo "### Changed"
        echo ""
        echo -n "$CHANGED"
        echo ""
    fi

    if [ -n "$REMOVED" ]; then
        echo "### Removed"
        echo ""
        echo -n "$REMOVED"
        echo ""
    fi
} > "$CHANGELOG_FILE"

echo "CHANGELOG.md generated successfully!"
