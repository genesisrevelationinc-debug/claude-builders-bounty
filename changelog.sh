#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag, or empty if none
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

# Determine commits to include
if [ -z "$LATEST_TAG" ]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE="HEAD"
else
    echo "Last tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# Get commits: hash and subject
COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" 2>/dev/null || true)

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
    [ -z "$line" ] && continue

    lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if echo "$lower" | grep -qE "^(feat|add|new|create|introduce|implement)"; then
        ADDED="${ADDED}- ${line}"$'\n'
    elif echo "$lower" | grep -qE "^(fix|bugfix|hotfix|resolve|patch|correct)"; then
        FIXED="${FIXED}- ${line}"$'\n'
    elif echo "$lower" | grep -qE "^(remove|delete|drop|revert|deprecate)"; then
        REMOVED="${REMOVED}- ${line}"$'\n'
    elif echo "$lower" | grep -qE "^(update|change|modify|refactor|improve|enhance|upgrade|rework)"; then
        CHANGED="${CHANGED}- ${line}"$'\n'
    else
        # Default to Changed if no match
        CHANGED="${CHANGED}- ${line}"$'\n'
    fi
done <<< "$COMMITS"

# Build changelog content
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [Unreleased] - $DATE"
    echo ""

    if [ -n "$ADDED" ]; then
        echo "### Added"
        echo "$ADDED"
        echo ""
    fi

    if [ -n "$CHANGED" ]; then
        echo "### Changed"
        echo "$CHANGED"
        echo ""
    fi

    if [ -n "$FIXED" ]; then
        echo "### Fixed"
        echo "$FIXED"
        echo ""
    fi

    if [ -n "$REMOVED" ]; then
        echo "### Removed"
        echo "$REMOVED"
        echo ""
    fi
} > "$CHANGELOG_FILE"

echo "✅ CHANGELOG.md generated successfully!"
echo "Preview:"
cat "$CHANGELOG_FILE"