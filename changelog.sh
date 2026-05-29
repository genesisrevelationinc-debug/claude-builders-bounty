#!/bin/bash

# Get the last tag or use initial commit if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -z "$LAST_TAG" ]; then
    LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commits since last tag
COMMITS=$(git log --pretty=format:"%s" $LAST_TAG..HEAD)

# Initialize changelog sections
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Categorize commits
while IFS= read -r line; do
    if [[ $line == *"add"* ]] || [[ $line == *"Add"* ]] || [[ $line == *"new"* ]] || [[ $line == *"New"* ]]; then
        ADDED+="- $line"$'\n'
    elif [[ $line == *"fix"* ]] || [[ $line == *"Fix"* ]] || [[ $line == *"bug"* ]] || [[ $line == *"Bug"* ]]; then
        FIXED+="- $line"$'\n'
    elif [[ $line == *"remove"* ]] || [[ $line == *"Remove"* ]] || [[ $line == *"delete"* ]] || [[ $line == *"Delete"* ]]; then
        REMOVED+="- $line"$'\n'
    else
        CHANGED+="- $line"$'\n'
    fi
done <<< "$COMMITS"

# Generate changelog content
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [Unreleased]" >> CHANGELOG.md
echo "" >> CHANGELOG.md

[[ -n "$ADDED" ]] && echo "### Added" >> CHANGELOG.md && echo "$ADDED" >> CHANGELOG.md
[[ -n "$FIXED" ]] && echo "### Fixed" >> CHANGELOG.md && echo "$FIXED" >> CHANGELOG.md
[[ -n "$REMOVED" ]] && echo "### Removed" >> CHANGELOG.md && echo "$REMOVED" >> CHANGELOG.md
[[ -n "$CHANGED" ]] && echo "### Changed" >> CHANGELOG.md && echo "$CHANGED" >> CHANGELOG.md

echo "CHANGELOG.md has been generated successfully!"