#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest tag; if none, use the first commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LATEST_TAG" ]; then
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    echo "Generating changelog for commits since ${LATEST_TAG}..."
else
    COMMIT_RANGE="HEAD"
    echo "No tags found. Generating changelog from the first commit..."
fi

# Fetch commits with subject and body
COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%s" --no-merges 2>/dev/null || true)

if [ -z "$COMMITS" ]; then
    echo "No new commits found since the last tag."
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

while IFS= read -r line; do
    [ -z "$line" ] && continue

    lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if echo "$lower" | grep -qE '^(feat|add|new|introduce|implement|create|support)'; then
        ADDED="${ADDED}- ${line}"$'\n'
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|resolve|patch|correct)'; then
        FIXED="${FIXED}- ${line}"$'\n'
    elif echo "$lower" | grep -qE '^(remove|delete legend|delete|drop|deprecate|clean)'; then
        REMOVED="${REMOVED}- ${line}"$'\n'
    elif echo "$lower" | grep -qE '^(update|change|modify|refactor|improve|enhance|optimize|upgrade|rework)'; then
        CHANGED="${CHANGED}- ${line}"$'\n'
    else
        OTHER="${OTHER}- ${line}"$'\n'
    fi
done <<< "$COMMITS"

# Append other to changed if exists
if [ -n "$OTHER" ]; then
    CHANGED="${CHANGED}${OTHER}"
fi

# Build changelog content
{
    echo "## [Unreleased] - ${DATE}"
    echo ""

    if [ -n "$ADDED" ]; then
        echo "### Added"
        echo ""
        echo -n "$ADDED"
        echo ""
    fi

    if [ -n "$CHANGED" ]; then
        echo "### Changed"
        echo ""
        echo -n "$CHANGED"
        echo ""
    fi

    if [ -n "$FIXED" ]; then
        echo "### Fixed"
        echo ""
        echo -n "$FIXED"
        echo ""
    fi

    if [ -n "$REMOVED" ]; then
        echo "### Removed"
        echo ""
        echo -n "$REMOVED"
        echo ""
    fi

    echo ""
} > /tmp/changelog_new.md

# Prepend to existing CHANGELOG or create new
if [ -f "$CHANGELOG_FILE" ]; then
    # Insert after the header (assumes first line is title)
    {
        head -n 1 "$CHANGELOG_FILE"
        cat /tmp/changelog_new.md
        tail -n +2 "$CHANGELOG_FILE"
    } > /tmp/changelog_combined.md
    mv /tmp/changelog_combined.md "$CHANGELOG_FILE"
else
    mv /tmp/changelog_new.md "$CHANGELOG_FILE"
fi

echo "CHANGELOG.md updated successfully."
# Skill: Generate Changelog

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag and auto-categorizes them into:
- **Added** — new features, additions
- **Fixed** — bug fixes, patches
- **Changed** — updates, refactors, improvements
- **Removed** — deletions, deprecations

### Usage

