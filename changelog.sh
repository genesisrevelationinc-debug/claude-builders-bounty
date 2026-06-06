#!/bin/bash

# Script to generate a structured CHANGELOG.md from git history

set -e

# Check if CHANGELOG.md exists, if not create it
if [ ! -f "CHANGELOG.md" ]; then
    echo "# Changelog" > CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

# Get the last tag or default to first commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "$(git rev-list --max-parents=0 HEAD)")

# Get commit hash for the last tag
if [ "$LAST_TAG" != "" ]; then
    LAST_TAG_COMMIT=$(git rev-list -n 1 $LAST_TAG 2>/dev/null)
else
    # Fallback if no tags exist, get first commit
    LAST_TAG_COMMIT=$(git rev-list --max-parents=0 HEAD)
fi

# Get commits since last tag
COMMITS_SINCE_TAG=$(git log $LAST_TAG_COMMIT..HEAD --reverse --pretty=format:"%s" --no-merges 2>/dev/null | grep -v "Merge branch" | grep -v "Merge pull request")

# If no new commits since last tag, exit
if [ -z "$COMMITS_SINCE_TAG" ]; then
    echo "No new commits since last tag. Exiting."
    exit 0
fi

# Create a temporary file to store the new changelog entries
TEMP_CHANGELOG=$(mktemp)

# Write the changelog header
echo "## [$(date +'%Y-%m-%d')] - $(git describe --tags --abbrev=0 2>/dev/null || echo "Unreleased")" > "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Categorize commits
echo "$COMMITS_SINCE_TAG" | while IFS= read -r commit; do
    # Default to "Changed" if no match
    category="Changed"
    
    # Categorize based on the prefix of the commit message
    if [[ $commit == "feat:"* ]] || [[ $commit == "feature:"* ]]; then
        category="Added"
    elif [[ $commit == "fix:"* ]]; then
        category="Fixed"
    elif [[ $commit == "remove:"* ]] || [[ $commitITS_SINCE_TAG" ]]; then
        category="Removed"
    fi
    
    # Add to the appropriate category
    echo "* $commit" >> "$TEMP_CHANGELOG"
done

# Prepend the new content to the changelog file
cat - CHANGELOG.md < "$TEMP_CHANGELOG" > temp_changelog.md
mv temp_changelog.md CHANGELOG.md

# Clean up
rm "$TEMP_CHANGELOG"

echo "CHANGELOG.md has been updated."