#!/bin/bash

set -e

# Function to display usage
usage() {
    echo "Usage: bash changelog.sh"
    echo "  Generate a changelog from git history since the last tag"
    exit 1
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag exists, use all commits
if [ -z "$LAST_TAG" ]; then
    COMMITS=$(git log --oneline)
else
    COMMITS=$(git log --oneline $LAST_TAG..HEAD)
fi

# Initialize changelog sections
added=""
fixed=""
changed=""
removed=""

# Process commits
while read -r commit; do
    # Skip empty lines
    if [ -z "$commit" ]; then
        continue
    fi
    
    # Extract commit message
    message=$(echo "$commit" | sed 's/^[0-9a-f]* //')
    
    # Categorize based on prefixes
    if [[ $message == feat:* || $message == add:* ]]; then
        added="$added- $message"$'\n'
    elif [[ $message == fix:* ]]; then
        fixed="$fixed- $message"$'\n'
    elif [[ $message == refactor:* || $message == chore:* ]]; then
        changed="$changed- $message"$'\n'
    elif [[ $message == remove:* || $message == delete:* ]]; then
        removed="$removed- $message"$'\n'
    else
        # Default to changed if no prefix
        changed="$changed- $message"$'\n'
    fi
done <<< "$COMMITS"

# Generate the changelog content
changelog_content="## [Unreleased]

### Added

$added
### Changed

$changed
### Fixed

$fixed
### Removed

$removed"

# Write to CHANGELOG.md
echo "$changelog_content" > CHANGELOG.md

echo "CHANGELOG.md has been generated successfully."