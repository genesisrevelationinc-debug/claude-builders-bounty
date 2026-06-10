#!/bin/bash

# Exit on error
set -e

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Get commits since the latest tag
COMMITS=$(git log "$LATEST_TAG"..HEAD --oneline --no-merges)

# If no commits, exit
if [ -z "$COMMITS" ]; then
    echo "No commits since last tag ($LATEST_TAG)"
    exit 0
fi

# Initialize changelog sections
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Categorize commits
echo "$COMMITS" | while read -r commit; do
    if [[ $commit == *"add:"* ]] || [[ $commit == *"feat:"* ]]; then
        ADDED+="- $commit"$'\n'
    elif [[ $commit == *"fix:"* ]]; then
        FIXED+="- $commit"$'\n'
    elif [[ $commit == *"change:"* ]] || [[ $commit == *"refactor:"* ]] || [[ $commit == *"perf:"* ]]; then
        CHANGED+="- $commit"$'\n'
    elif [[ $commit == *"remove:"* ]] || [[ $commit == *"delete:"* ]] || [[ $commit == *"del:"* ]]; then
        REMOVED+="- $commit"$'\n'
    else
        # Default to "Changed" if no prefix
        CHANGED+="- $commit"$'\n'
    fi
done

# Create a temporary file to store the categorized commits
TEMP_FILE=$(mktemp)
echo "$COMMITS" | while read -r commit; do
    echo "$commit" >> "$TEMP_FILE"
done

# Process the commits from the temp file
while IFS= read -r commit; do
    # Same processing logic as above
done < "$TEMP_FILE"

# Generate the changelog
echo "# Changelog"
echo ""
echo "## Unreleased"
echo ""
[ -n "$ADDED" ] && echo "### Added" && echo "$ADDED"
[ -n "$FIXED" ] && echo "### Fixed" && echo "$FIXED"
[ -n "$CHANGED" ] && echo "### Changed" && echo "$CHANGED"
[ -n "$REMOVED" ] && echo "### Removed" && echo "$REMOVED"