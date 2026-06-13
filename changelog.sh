#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the latest git tag, or empty if none
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [ -z "$LATEST_TAG" ]; then
    echo "⚠️  No tags found. Using all commits."
    COMMIT_RANGE=""
else
    echo "📌 Latest tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# Fetch commits since last tag (or all commits)
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%s" --no-merges 2>/dev/null || true)
else
    COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%s" --no-merges 2>/dev/null || true)
fi

if [ -z "$COMMITS" ]; then
    echo "✅ No new commits since ${LATEST_TAG:-the beginning}."
    rm -f "$TEMP_FILE"
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue

    # Categorize based on conventional commit prefixes and keywords
    if echo "$line" | grep -qiE '^(feat|add|new|introduce)|^[a-z]+:.*\b(add|added|adding|introduce|introduces|introduced)\b'; then
        ADDED="${ADDED}- ${line}"$'\n'
    elif echo "$line" | grep -qiE '^(fix|bugfix|hotfix)|^[a-z]+:.*\b(fix|fixed|fixes|fixing|resolve|resolves|resolved|resolving)\b'; then
        FIXED="${FIXED}- ${line}"$'\n'
    elif echo "$line" | grep -qiE '^(remove|delete|drop|revert)|^[a-z]+:.*\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted)\b'; then
        REMOVED="${REMOVED}- ${line}"$'\n'
    elif echo "$line" | grep -qiE '^(change|update|refactor|modify|improve|upgrade|deprecate)|^[a-z]+:.*\b(change|changed|changing|update|updated|updating|refactor|refactored|modify|modified|improve|improved|upgrade|upgraded|deprecate|deprecated)\b'; then
        CHANGED="${CHANGED}- ${line}"$'\n'
    else
        OTHER="${OTHER}- ${line}"$'\n'
    fi
done <<< "$COMMITS"

# Build changelog content
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [Unreleased] — $(date +%Y-%m-%d)"
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

    if [ -n "$OTHER" ]; then
        echo "### Other"
        echo ""
        echo -n "$OTHER"
        echo ""
    fi
} > "$TEMP_FILE"

# Write to CHANGELOG.md
cat "$TEMP_FILE" > "$CHANGELOG_FILE"
rm -f "$TEMP_FILE"

echo "✅ CHANGELOG.md generated successfully!"
echo "📄 Output: $(pwd)/$CHANGELOG_FILE"