#!/bin/bash

# A script to generate a structured CHANGELOG.md from git history

set -e

# Get the latest tag, or use the initial commit if no tags exist
if git describe --tags --abbrev=0 &>/dev/null; then
    LAST_TAG=$(git describe --tags --abbrev=0)
    echo "Generating changelog since last tag: $LAST_TAG"
    COMMITS_SINCE_TAG=$(git log --oneline $LAST_TAG..HEAD)
else
    echo "No tags found, using all commits"
    COMMITS_SINCE_TAG=$(git log --oneline)
    LAST_TAG="Initial commit"
fi

# Create a temporary file to store the changelog
CHANGELOG_TEMP=$(mktemp)

# Categorize commits
echo "## Changelog" > "$CHANGELOG_TEMP"
echo "" >> "$CHANGELOG_TEMP"
echo "Changes since $LAST_TAG:" >> "$CHANGELOG_TEMP"
echo "" >> "$CHANGELOG_TEMP"

{
    echo "### Added"
    echo "$(echo "$COMMITS_SINCE_TAG" | grep -i 'add\|feature\|implement' | sed 's/^/- /')"
    echo
    echo "### Fixed"
    echo "$(echo "$COMMITS_SINCE_TAG" | grep -i 'fix\|resolve\|close' | sed 's/^/- /')"
    echo
    echo "### Changed"
    echo "$(echo "$COMMITS_SINCE_TAG" | grep -i 'update\|change\|modify\|refactor' | sed 's/^/- /')"
    echo
    echo "### Removed"
    echo "$(echo "$COMMITS_SINCE_TAG" | grep -i 'remove\|delete\|cleanup' | sed 's/^/- /')"
} >> "$CHANGELOG_TEMP"

# Add the new changelog to the top of the existing one or create new
if [ -f "CHANGELOG.md" ]; then
    cat "$CHANGELOG_TEMP" CHANGELOG.md > CHANGELOG.md.tmp
    mv CHANGELOG.md.tmp CHANGELOG.md
else
    mv "$CHANGELOG_TEMP" CHANGELOG.md
fi