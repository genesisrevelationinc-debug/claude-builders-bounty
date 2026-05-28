#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# This script will:
# 1. Find commits since the last git tag
# 2. Categorize changes into Added/Fixed/Changed/Removed
# 3. Output a properly formatted CHANGELOG.md

set -e

# Function to display usage
usage() {
  echo "Usage: $0 [-h]"
  echo "Generate a CHANGELOG.md from git history"
  echo ""
  echo "Options:"
  echo "  -h, --help    Display this help message"
  echo ""
  echo "Examples:"
  echo "  $0              # Generate changelog"
  echo "  $0 --help       # Show help"
  exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help) usage ;;
    *) echo "Unknown parameter: $1"; usage ;;
  esac
  shift
done

# Get the latest tag or default to initial commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
  echo "No tags found. Using initial commit as starting point."
  COMMITS=$(git log --pretty=format:"%H %s" --reverse)
else
  echo "Generating changelog for commits since tag: $LATEST_TAG"
  COMMITS=$(git log --pretty=format:"%H %s" $LATEST_TAG..HEAD --reverse)
fi

# Create temporary file for changelog content
TEMP_FILE=$(mktemp)

# Initialize sections
echo "## [Unreleased]" > "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Process commits and categorize
while IFS= read -r line; do
  if [ -n "$line" ]; then
    COMMIT_MSG=$(echo "$line" | cut -d' ' -f2-)
    if [[ $COMMIT_MSG == feat:* ]]; then
      ADDED+="- ${COMMIT_MSG#feat: }"$'\n'
    elif [[ $COMMIT_MSG == fix:* ]]; then
      FIXED+="- ${COMMIT_MSG#fix: }"$'\n'
    elif [[ $COMMIT_MSG == remove:* ]]; then
      REMOVED+="- ${COMMIT_MSG#remove: }"$'\n'
    else
      CHANGED+="- $COMMIT_MSG"$'\n'
    fi
  fi
done <<< "$COMMITS"

# Write sections to changelog
[ -n "$ADDED" ] && echo "### Added" >> "$TEMP_FILE" && echo "$ADDED" >> "$TEMP_FILE"
[ -n "$FIXED" ] && echo "### Fixed" >> "$TEMP_FILE" && echo "$FIXED" >> "$TEMP_FILE"
[ -n "$CHANGED" ] && echo "### Changed" >> "$TEMP_FILE" && echo "$CHANGED" >> "$TEMP_FILE"
[ -n "$REMOVED" ] && echo "### Removed" >> "$TEMP_FILE" && echo "$REMOVED" >> "$TEMP_FILE"

# Generate final changelog
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
echo "" >> CHANGELOG.md
cat "$TEMP_FILE" >> CHANGELOG.md

# Cleanup
rm "$TEMP_FILE"

echo "CHANGELOG.md has been generated successfully!"