#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: bash changelog.sh [OPTIONS]"
  echo "Options:"
  echo "  -h, --help    Display this help message"
  echo ""
  echo "This script generates a CHANGELOG.md file from git commit history."
  echo "It requires git to be initialized in the current directory."
  exit 1
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

# Get the last tag or initial commit if no tags exist
last_ref=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -z "$last_ref" ]; then
  last_ref=$(git rev-list --max-parents=0 HEAD)
fi

# Get commits between last tag and HEAD
commits=$(git log --oneline "$last_ref"..HEAD)

# Create or clear the changelog file
echo "# Changelog" > CHANGELOG.md
echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Add unreleased changes section
echo "## [Unreleased]" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Categorize commits
added=$(echo "$commits" | grep -i "add\|feat" || true)
fixed=$(echo "$commits" | grep -i "fix\|bug" || true)
changed=$(echo "$commits" | grep -i "change\|update\|modify" || true)
removed=$(echo "$commits" | grep -i "remove\|delete" || true)

# Write categorized changes to the changelog
if [ -n "$added" ]; then
  echo "### Added" >> CHANGELOG.md
  echo "$added" | while read -r line; do
    echo "- $line" >> CHANGELOG.md
  done
  echo "" >> CHANGELOG.md
fi

if [ -n "$fixed" ]; then
  echo "### Fixed" >> CHANGELOG.md
  echo "$fixed" | while read -r line; do
    echo "- $line" >> CHANGELOG.md
  done
  echo "" >> CHANGELOG.md
fi