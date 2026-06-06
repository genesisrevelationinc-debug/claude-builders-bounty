#!/bin/bash

# Generate a structured CHANGELOG.md from git history

set -e

echo "Generating CHANGELOG.md..."

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get commits since the latest tag or all commits if no tags exist
if [ -n "$LATEST_TAG" ]; then
    COMMITS=$(git log "$LATEST_TAG"..HEAD --oneline)
    echo "Commits since tag $LATEST_TAG:"
else
    COMMITS=$(git log --oneline)
    echo "No tags found. Processing all commits:"
fi

# Initialize categories
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Categorize commits
while IFS= read -r commit; do
    if [[ $commit =~ (add|feature|implement) ]]; then
        ADDED+="- $commit"$'\n'
    elif [[ $commit =~ (fix|bug|resolve) ]]; then
        FIXED+="- $commit"$'\n'
    elif [[ $commit =~ (remove|delete|cleanup) ]]; then
        REMOVED+="- $commit"$'\n'
    elif [[ $commit =~ (change|update|modify) ]]; then
        CHANGED+="- $commit"$'\n'
    else
        CHANGED+="- $commit"$'\n'
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "## [Unreleased]"
    echo ""
    
    if [ -n "$ADDED" ]; then
        echo "### Added"
        echo "$ADDED"
    fi
    
    if [ -n "$FIXED" ]; then
        echo "### Fixed"
        echo "$FIXED"
    fi
    
    if [ -n "$CHANGED" ]; then
        echo "### Changed"
        echo "$CHANGED"
    fi
    
    if [ -n "$REMOVED" ]; then
        echo "### Removed"
        echo "$REMOVED"
    fi
} > CHANGELOG.md

echo "CHANGELOG.md generated successfully!"