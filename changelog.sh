#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

set -e

# Default output file
OUTPUT_FILE="CHANGELOG.md"

# Get the latest tag, or default to initial commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get commit hash for the last tag, or initial commit
if [ -n "$LAST_TAG" ]; then
  LAST_TAG_HASH=$(git rev-parse "$LAST_TAG" 2>/dev/null || echo "")
else
  # If no tags, use initial commit
  LAST_TAG_HASH=$(git rev-list --max-parents=0 HEAD)
fi

# If we have a valid last tag hash, get commits since then, otherwise get all commits
if [ -n "$LAST_TAG_HASH" ]; then
  COMMITS_SINCE=$(git log "$LAST_TAG_HASH"..HEAD --oneline --no-merges 2>/dev/null || git log --oneline --no-merges)
else
  COMMITS_SINCE=$(git log --oneline --no-merges)
fi

# Function to categorize commits based on prefixes
categorize_commits() {
  local commits="$1"
  echo "### Added"
  echo "$commits" | grep -E "^(feat|add|new):" | sed 's/^.*: /* /' | while read line; do
    echo "$line"
  done
  echo

  echo "### Fixed"
  echo "$commits" | grep -E "^(fix|bug):" | sed 's/^.*: /* /' | while read line; do
    echo "$line"
  done
  echo

  echo "### Changed"
  echo "$commits" | grep -E "^(change|update|modify):" | sed 's/^.*: /* /' | while read line; do
    echo "$line"
  done
  echo

  echo "### Removed"
  echo "$commits" | grep -E "^(remove|delete):" | sed 's/^.*: /* /' | while read line; do
    echo "$line"
  done
  echo
}

# Generate the changelog content
generate_changelog() {
  echo "# Changelog"
  echo
  echo "All notable changes to this project will be documented in this file."
  echo
  echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
  echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.0.html)."
  echo
  echo "## [Unreleased]"
  echo
  categorize_commits "$COMMITS_SINCE"
}

# Write to CHANGELOG.md
generate_changelog > "$OUTPUT_FILE"

echo "CHANGELOG.md has been generated successfully!"