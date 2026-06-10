#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the last git tag, or empty if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [ -z "$LAST_TAG" ]; then
    echo "ℹ️  No tags found. Using all commits."
    COMMIT_RANGE="HEAD"
    VERSION="v0.0.0"
else
    COMMIT_RANGE="${LAST_TAG}..HEAD"
    VERSION="$LAST_TAG"
fi

# Get commits since last tag (or all if no tag)
COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" 2>/dev/null || true)

if [ -z "$COMMITS" ]; then
    echo "ℹ️  No new commits since $VERSION."
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

    # Categorize based on conventional commit prefixes or keywords
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if echo "$lower_line" | grep -qE '^(feat|add|new|introduce|implement)'; then
        ADDED="${ADDED}- ${line}"$'\n'
    elif echo "$lower_line" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        FIXED="${FIXED}- ${line}"$'\n'
    elif echo "$lower_line" | grep -qE '^(remove|delete|drop|deprecate|revert)'; then
        REMOVED="${REMOVED}- ${line}"$'\n'
    elif echo "$lower_line" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|chore|docs|style|test|perf)'; then
        CHANGED="${CHANGED}- ${line}"$'\n'
    else
        # Default to Changed for uncategorized
        CHANGED="${CHANGED}- ${line}"$'\n'
    fi
done <<< "$COMMITS"

# Build the new changelog section
NEW_SECTION="## [Unreleased] - ${DATE}

"

if [ -n "$ADDED" ]; then
    NEW_SECTION="${NEW_SECTION}### Added

${ADDED}
"
fi

if [ -n "$CHANGED" ]; then
    NEW_SECTION="${NEW_SECTION}### Changed

${CHANGED}
"
fi

if [ -n "$FIXED" ]; then
    NEW_SECTION="${NEW_SECTION}### Fixed

${FIXED}
"
fi

if [ -n "$REMOVED" ]; then
    NEW_SECTION="${NEW_SECTION}### Removed

${REMOVED}
"
fi

# Prepend to existing CHANGELOG or create new one
if [ -f "$CHANGELOG_FILE" ]; then
    EXISTING=$(cat "$CHANGELOG_FILE")
    echo -e "# Changelog\n\n${NEW_SECTION}\n${EXISTING#*$'# Changelog\n\n'}" > "$CHANGELOG_FILE"
else
    echo -e "# Changelog\n\n${NEW_SECTION}" > "$CHANGELOG_FILE"
fi

echo "✅ CHANGELOG.md generated successfully!"
echo "   Version: $VERSION → Unreleased"
echo "   Commits processed: $(echo "$COMMITS" | wc -l | tr -d ' ')"