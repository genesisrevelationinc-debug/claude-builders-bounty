#!/bin/bash

# changelog.sh - A script to generate a structured CHANGELOG.md from git history
#
# This script fetches commits since the last git tag and categorizes them into:
# - Added
# - Fixed
# - Changed
# - Removed
#
# Usage: bash changelog.sh

set -e

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tags exist, use --all to get all commits
if [ -z "$LATEST_TAG" ]; then
  # Get all commits if no tags
  COMMIT_RANGE=""
else
  # Get commits since the latest tag
  COMMIT_RANGE="$LATEST_TAG..HEAD"
fi

# Create a temporary file for commit messages
TEMP_FILE=$(mktemp)

# Get commit messages
if [ -z "$COMMIT_RANGE" ]; then
  # If no tags, get all commits
  git log --pretty=format:"%h %s" > "$TEMP_FILE"
else
  # Get commits in range
  git log --pretty=format:"%h %s" "$COMMIT_RANGE" > "$TEMP_FILE"
fi

# Create or clear CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

# Try to get the latest tag name for the version
VERSION_HEADER="## [Unreleased]"
if [ -n "$LATEST_TAG" ]; then
  VERSION_HEADER="## $LATEST_TAG"
fi

echo "$VERSION_HEADER" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Categorize commits
ADDED_SECTION="### Added"
FIXED_SECTION="### Fixed"
CHANGED_SECTION="### Changed"
REMOVED_SECTION="### Removed"

ADDED_LINES=$(mktemp)
FIXED_LINES=$(mktemp)
CHANGED_LINES=$(mktemp)
REMOVED_LINES=$(mktemp)

# Process each commit
while IFS= read -r line; do
  # Extract the commit message (skip the hash)
  commit_msg="${line#* }"
  
  # Categorize based on commit message prefixes
  if [[ $commit_msg == feat:* ]] || [[ $commit_msg == add:* ]] || [[ $commit_msg == create:* ]]; then
    echo "* $line" >> "$ADDED_LINES"
  elif [[ $commit_msg == fix:* ]] || [[ $commit_msg == fixed:* ]]; then
    echo "* $line" >> "$FIXED_LINES"
  elif [[ $commit_msg == refactor:* ]] || [[ $commit_msg == update:* ]] || [[ $commit_msg == change:* ]]; then
    echo "* $line" >> "$CHANGED_LINES"
  elif [[ $commit_msg == remove:* ]] || [[ $commit_msg == delete:* ]] || [[ $commit_msg == rm:* ]]; then
    echo "* $line" >> "$REMOVED_LINES"
  else
    # Default to "Changed" if no specific category
    echo "* $line" >> "$CHANGED_LINES"
  fi
done < "$TEMP_FILE"

# Append categorized commits to CHANGELOG.md
if [ -s "$ADDED_LINES" ]; then
  echo "$ADDED_SECTION" >> CHANGELOG.md
  cat "$ADDED_LINES" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
fi

if [ -s "$FIXED_LINES" ]; then
  echo "$FIXED_SECTION" >> CHANGELOG.md
  cat "$FIXED_LINES" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
fi

if [ -s "$CHANGED_LINES" ]; then
  echo "$CHANGED_SECTION" >> CHANGELOG.md
  cat "$CHANGED_LINES" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
fi

if [ -s "$REMOVED_LINES" ]; then
  echo "$REMOVED_SECTION" >> CHANGELOG.md
  cat "$REMOVED_LINES" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
fi

# Clean up temporary files
rm -f "$TEMP_FILE" "$ADDED_LINES" "$FIXED_LINES" "$CHANGED_LINES" "$REMOVED_LINES"

echo "CHANGELOG.md has been generated."