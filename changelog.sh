#!/bin/bash

# Script to generate a structured CHANGELOG.md from git history

set -e

# Get the last tag or use empty string if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get commit range
if [ -z "$LAST_TAG" ]; then
  COMMIT_RANGE="HEAD"
  echo "No previous tag found. Generating changelog for all commits."
else
  COMMIT_RANGE="$LAST_TAG..HEAD"
  echo "Generating changelog from commits since tag: $LAST_TAG"
fi

# Temporary file to store commit messages
TEMP_FILE=$(mktemp)

# Get commits in the specified range
git log --pretty=format:"%s" $COMMIT_RANGE > "$TEMP_FILE"

# Initialize CHANGELOG.md if it doesn't exist
if [ ! -f "CHANGELOG.md" ]; then
  echo "# Changelog" > CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
  echo "" >> CHANGELOG.md
fi

# Get current date in YYYY-MM-DD format
DATE=$(date +"%Y-%m-%d")

# Add new version section
echo "## [Unreleased] - $DATE" > temp_changelog.md

# Categorize commits
echo "" >> temp_changelog.md
echo "### Added" >> temp_changelog.md
grep -i "^add\|^feat" "$TEMP_FILE" | sed 's/^/* /' >> temp_changelog.md 2>/dev/null || true

echo "" >> temp_changelog.md
echo "### Fixed" >> temp_changelog.md
grep -i "^fix\|^bug" "$TEMP_FILE" | sed 's/^/* /' >> temp_changelog.md 2>/dev/null || true

echo "" >> temp_changelog.md
echo "### Changed" >> temp_changelog.md
grep -i "^change\|^update\|^refactor" "$TEMP_FILE" | sed 's/^/* /' >> temp_changelog.md 2>/dev/null || true

echo "" >> temp_changelog.md
echo "### Removed" >> temp_changelog.md
grep -i "^remove\|^delete" "$TEMP_FILE" | sed 's/^/* /' >> temp_changelog.md 2>/dev/null || true

# Add a blank line
echo "" >> temp_changelog.md

# Prepend the new content to CHANGELOG.md
cat temp_changelog.md CHANGELOG.md > temp && mv temp CHANGELOG.md

# Clean up temporary files
rm "$TEMP_FILE" temp_changelog.md

echo "CHANGELOG.md has been updated successfully."