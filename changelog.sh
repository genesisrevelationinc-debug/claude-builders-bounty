#!/bin/bash

# Exit if no git repo found
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tags found, get all commits from the beginning
if [ -z "$LAST_TAG" ]; then
  COMMITS=$(git log --reverse --format="%s|%h")
else
  COMMITS=$(git log $LAST_TAG..HEAD --format="%s|%h")
fi

# Create a temporary file for changelog
CHANGELOG_TEMP=$(mktemp)

# Write changelog header
echo "# Changelog" > "$CHANGELOG_TEMP"
echo "" >> "$CHANGELOG_TEMP"

# Get commits and process them
echo "$COMMITS" | while IFS='|' read -r COMMIT_MSG COMMIT_HASH; do
  # Categorize based on commit message prefix
  if [[ $COMMIT_MSG == "feat:"* ]] || [[ $COMMIT_MSG == "add:"* ]] || [[ $COMMIT_MSG == "new:"* ]]; then
    echo "## Added" >> "$CHANGELOG_TEMP"
    echo "- $COMMIT_MSG ($COMMIT_HASH)" >> "$CHANGELOG_TEMP"
  elif [[ $COMMIT_MSG == "fix:"* ]] || [[ $COMMIT_MSG == "bug:"* ]]; then
   echo "## Fixed" >> "$CHANGELOG_TEMP"
  elif [[ $COMMIT_MSG == "change:"* ]] || [[ $COMMIT_MSG == "update:"* ]] || [[ $COMMIT_MSG == "refactor:"* ]]; then
    echo "## Changed" >> "$CHANGELOG_TEMP"
  elif [[ $COMMIT_MSG == "remove:"* ]] || [[ $COMMIT_MSG == "delete:"* ]]; then
    echo "## Removed" >> "$CHANGELOG_TEMP"
  fi
done

cat "$CHANGELOG_TEMP" > CHANGELOG.md
rm "$CHANGELOG_TEMP"