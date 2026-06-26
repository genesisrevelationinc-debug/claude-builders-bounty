#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag; if none, use the first commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    echo "Error: No git tags or commits found."
    exit 1
fi

# Get commits since the last tag
COMMITS=$(git log "$LATEST_TAG"..HEAD --pretty=format:"%s" 2>/dev/null || true)

if [ -z "$COMMaCOMMITS" ] && [ -z "$COMMITS" ]; then
    echo "No new commits since $LATEST_TAG."
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

    if echo "$lower" | grep -qE '^(add|feat|feature|implement|new|introduce)'; then
        ADDED="$ADDED- $line"$'\n'
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
        FIXED="$FIXED- $line"$'\n'
    elif echo "$lower" | grep -qE '^(remove|delete|drop|deprecate)'; then
        REMOVED="$REMOVED- $line"$'\n'
    elif echo "$lower" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade)'; then
        CHANGED="$CHANGED- $line"$'\n'
    else
        OTHER="$OTHER- $line"$'\n'
    fi
done <<< "$COMMITS"

# Append uncategorized to Changed as fallback
if [ -n "$OTHER" ]; then
    CHANGED="$CHANGED$OTHER"
fi

# Build changelog section
NEW_ENTRY="## [Unreleased] - $DATE"$'\n\n'

if [ -n "$ADDED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Added"$'\n\n'"$ADDED"$'\n'
fi

if [ -n "$CHANGED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Changed"$'\n\n'"$CHANGED"$'\n'
fi

if [ -n "$FIXED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Fixed"$'\n\n'"$FIXED"$'\n'
fi

if [ -n "$REMOVED" ]; then
    NEW_ENTRY="${NEW_ENTRY}### Removed"$'\n\n'"$REMOVED"$'\n'
fi

# Write or update CHANGELOG.md
if [ -f "$CHANGELOG_FILE" ]; then
    EXISTING=$(cat "$CHANGELOG_FILE")
    # Insert new entry after the header
    {
        echo "# Changelog"
        echo ""
        echo "$NEW_ENTRY"
        echo "$EXISTING" | tail -n +3
    } > "$CHANGELOG_FILE"
else
    echo "# Changelog"$'\n\n'"$NEW_ENTRY" > "$CHANGELOG_FILE"
fi

echo "CHANGELOG.md generated successfully!"
echo "Changes since: $LATEST_TAG"
# Generate Changelog Skill

A Claude Code skill to generate a structured `CHANGELOG.md` from git history.

## Usage

Run the following command in Claude Code:

