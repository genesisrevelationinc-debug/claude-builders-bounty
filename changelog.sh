#!/bin/bash

# Get the latest tag, or default to v0.0.0 if no tags exist
TAG=$(git describe --tags --abbrev=0 2>/dev/null) || TAG="v0.0.0"

# If there are no commits, exit
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository. Please run this in a git repository."
  exit 1
fi

# Get commits from the last tag or all commits if no tags exist
if [ "$TAG" = "v0.0.0" ]; then
  COMMITS=$(git log --pretty=format:"%s" --reverse)
else
  COMMITS=$(git log $TAG..HEAD --pretty=format:"%s" --reverse)
fi

# Create the changelog
echo "## Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [v$(date +%Y-%m-%d)]" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Categories for changelog entries
CATEGORIES=("Added" "Fixed" "Changed" "Removed")

# Process commits and categorize
echo "$COMMITS" | while read -r commit; do
  if [ -n "$commit" ]; then
    # Try to categorize based on conventional commit format
    if [[ $commit == *"feat:"* ]]; then
      echo "- $commit" >> CHANGELOG.md
    elif [[ $commit == *"fix:"* ]]; then
      echo "- $commit" >> CHANGELOG.md
    else
      echo "- $commit" >> CHANGELOG.md
    fi
  fi
done

# Write categorized commits to changelog
echo "### ${CATEGORIES[0]}" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### ${CATEGORIES[1]}" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### ${CATEGORIES[2]}" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### ${CATEGORIES[3]}" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "Done! See CHANGELOG.md for the generated changelog."