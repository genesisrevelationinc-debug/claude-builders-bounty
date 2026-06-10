#!/bin/bash

set -e

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$latest_tag" ]; then
    # No tags found, use the initial commit as starting point
    latest_tag=$(git rev-list --max-parents=0 HEAD)
fi

# Get the commit hash for the latest tag
latest_tag_commit=$(git rev-parse $latest%)

# Get all commits since last tag
if [ -z "$(git rev-list --tags --no-walk --max-count=1 2>/dev/null)" ]; then
    commits=$(git log --oneline)
else
    commits=$(git log --oneline $latest_tag..HEAD)
fi

# Prepare the changelog file
changelog_content="# Changelog
All notable changes to this project will be documented in this file.\n"

# Write the header
echo -e "$changelog_content" > CHANGELOG.md

# Categorize commits
added=$(echo "$commits" | grep -i "add\|feat\|new" | sed 's/^/- /')
fixed=$(echo "$commits" | grep -i "fix\|bug" | sed 's/^/- /')
changed=$(echo "$commits" | grep -i "change\|update\|improve" | sed 's/^/- /')
removed=$(echo "$commits" | grep -i "remove\|delete" | sed 's/^/- /')

# Add to changelog
if [ -n "$added" ]; then
    echo "## Added" >> CHANGELOG.md
    echo "$added" >> CHANGELOG.md
fi

if [ -n "$fixed" ]; then
    echo "## Fixed" >> CHANGELOG.md
    echo "$fixed" >> CHANGELOG.md
fi

if [ -n "$changed" ]; then
    echo "## Changed" >> CHANGELOG.md
    echo "$changed" >> CHANGELOG.md
fi

if [ -n "$removed" ]; then
    echo "## Removed" >> CHANGELOG.md
    echo "$removed" >> CHANGELOG.md
fi

echo "Changelog generated in CHANGELOG.md"