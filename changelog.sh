#!/bin/bash

# Exit on error
set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Change to that directory
cd "$SCRIPT_DIR" || exit 1

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Get commit hash of the last tag
LAST_TAG_COMMIT=$(git rev-list -n 1 "$LAST_TAG" 2>/dev/null || echo "HEAD")

# Get commits since last tag
COMMITS=$(git log --pretty=format:"%s" "$LAST_TAG_COMMIT"..HEAD)

# For generating changelog we only want the commits from last tag to head
COMMITS_TO_HEAD=$(git log --pretty=format:"%h|%an|%s" "$LAST_TAG_COMMIT"..HEAD)

# Create a temporary file to store the commits
TEMP_FILE=$(mktemp)
echo "$COMMITS_TO_HEAD" > "$TEMP_FILE"

# Create the initial CHANGELOG.md content
{
  echo "# Changelog"
  echo ""
  echo "All notable changes to this project will be documented in this file."
  echo ""
  echo "## [Unreleased]"
  echo ""
  echo "### Added"
  echo ""
  echo "### Fixed"
  echo ""
  echo "### Changed"
  echo ""
  echo "### Removed"
  echo ""
  
  # Process commits and categorize them
  while IFS='|' read -r hash author message; do
    if [[ $message == *"add:"* ]] || [[ $message == *"feat:"* ]] || [[ $message == *"new:"* ]] || [[ $message == *"Add:"* ]] || [[ $message == *"ADD:"* ]] || [[ $message == *"add "* ]] || [[ $message == *"feat "* ]] || [[ $message == *"new "* ]]; then
      echo "### Added"
      echo "- $message"
    elif [[ $message == *"fix:"* ]] || [[ $message == *"Fix:"* ]] || [[ $message == *"fix "* ]] || [[ $message == *"bug"* ]]; then
      echo "### Fixed"
      echo "- $message"
    elif [[ $message == *"change:"* ]] || [[ $message == *"Change:"* ]] || [[ $message == *"CHANGE:"* ]] || [[ $message == *"change "* ]] || [[ $message == *"update"* ]] || [[ $message == *"refactor"* ]]; then
      echo "### Changed"
      echo "- $message"
    elif [[ $message == *"remove:"* ]] || [[ $message == *"delete:"* ]] || [[ $message == *"Remove:"* ]] || [[ $message == *"Delete:"* ]] || [[ $message == *"remove "* ]] || [[ $message == *"delete "* ]]; then
      echo "### Removed"
      echo "- $message"
    fi
  done < "$TEMP_FILE"
  
  echo ""
} > CHANGELOG.md

# Clean up
rm "$TEMP_FILE"

echo "CHANGELOG.md has been generated successfully."