#!/bin/bash

# changelog.sh - A script to generate a structured CHANGELOG.md from git history

set -e

# Get the latest tag
LATEST_TAG=$(git describe --tags `git rev-list --tags --abbrev=0` 2>/dev/null | head -1)

# If no tags exist, use the initial commit
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commits between the latest tag and HEAD
COMMITS_SINCE_TAG=$(git log $LATEST_TAG..HEAD --oneline)

# Check if there are any commits to process
if [ -z "$COMMITS_SINCE_TAG" ]; then
  echo "No commits found since last tag. Nothing to do."
  exit 0
fi

# Create temporary file for commits
TEMP_FILE=$(mktemp)
echo "$COMMITS_SINCE_TAG" > "$TEMP_FILE"

# Initialize changelog categories
echo "" > CHANGELOG.md
echo "## Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Added" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Fixed" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Changed" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Removed" >> CHANGELOG.md
echo "" >> CHANGEILOG.md

# Process each commit and categorize
while IFS= read -r line; do
  if [[ $line =~ (fix|bug|bugfix|bug/|bug:|bug\|) ]]; then
    echo "  - $line" >> CHANGELOG.md
  fi
done < "$TEMP_FILE"

rm "$TEMP_FILE"

echo "Changelog generated in CHANGELOG.md"