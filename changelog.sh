#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag; if none, use the first commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LATEST_TAG" ]; then
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    echo "Generating changelog for commits since ${LATEST_TAG}..."
else
    COMMIT_RANGE="HEAD"
    echo "No tags found. Generating changelog from all commits..."
fi

# Get commits since last tag (or all commits)
COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%s" 2>/dev/null || true)

if [ -z "$COMMITS" ]; then
    echo "No new commits found since last tag."
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

    # Categorize based on conventional commit keywords
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if echo "$lower_line" | grep -qE '^(feat|add|new|introduce|implement)'; then
        ADDED="${ADDED}- ${line}"$'\n'
    elif echo "$lower_line" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        FIXED="${FIXED}- ${line}"$'\n'
    elif echo "$lower_line" | grep -qE '^(remove|delete|drop|deprecate|revert)'; then
        REMOVED="${REMOVED}- ${line}"$'\n'
    elif echo "$lower_line" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|chore|docs|style|test)'; then
        CHANGED="${CHANGED}- ${line}"$'\n'
    else
        # Fallback: categorize based on keywords in the message
        if echo "$lower_line" | grep -qE '\b(add|added|adding|new|feature|introduce|implement|create)\b'; then
            ADDED="${ADDED}- ${line}"$'\n'
        elif echo "$lower_line" | grep -qE '\b(fix|fixed|fixing|bug|resolve|solved|correct|patch)\b'; then
            FIXED="${FIXED}- ${line}"$'\n'
        elif echo "$lower_line" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|reverted)\b'; then
            REMOVED="${REMOVED}- ${line}"$'\n'
        elif echo "$lower_line" | grep -qE '\b(update|updated|updating|change|changed|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
            CHANGED="${CHANGED}- ${line}"$'\n'
        else
            OTHER="${OTHER}- ${line}"$'\n'
        fi
    fi
done <<< "$COMMITS"

# Build changelog content
CHANGELOG_CONTENT=""

if [ -n "$ADDED" ]; then
    CHANGELOG_CONTENT="${CHANGELOG_CONTENT}### Added"$'\n\n'"${ADDED}"$'\n'
fi

if [ -n "$CHANGED" ]; then
    CHANGELOG_CONTENT="${CHANGELOG_CONTENT}### Changed"$'\n\n'"${CHANGED}"$'\n'
fi

if [ -n "$FIXED" ]; then
    CHANGELOG_CONTENT="${CHANGELOG_CONTENT}### Fixed"$'\n\n'"${FIXED}"$'\n'
fi

if [ -n "$REMOVED" ]; then
    CHANGELOG_CONTENT="${CHANGELOG_CONTENT}### Removed"$'\n\n'"${REMOVED}"$'\n'
fi

if [ -n "$OTHER" ]; then
    CHANGELOG_CONTENT="${CHANGELOG_CONTENT}### Other"$'\n\n'"${OTHER}"$'\n'
fi

# Generate the new changelog section
NEW_ENTRY="## [Unreleased] - ${DATE}"$'\n\n'"${CHANGELOG_CONTENT}"

# Write to CHANGELOG.md (prepend to existing or create new)
if [ -f "$CHANGELOG_FILE" ]; then
    EXISTING=$(cat "$CHANGELOG_FILE")
    echo -e "# Changelog\n\n${NEW_ENTRY}${EXISTING#*$'# Changelog\n\n'}" > "$CHANGELOG_FILE"
else
    echo -e "# Changelog\n\n${NEW_ENTRY}" > "$CHANGELOG_FILE"
fi

echo "✅ CHANGELOG.md generated successfully!"
echo ""
echo "Preview:"
echo "--------"
head -n 50 "$CHANGELOG_FILE"