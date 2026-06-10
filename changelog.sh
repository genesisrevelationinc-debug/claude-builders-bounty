#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Get the last tag, or initial commit if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 --always)
if [ -z "$LAST_TAG" ] || [ "$LAST_TAG" = "" ]; then
  LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit types for categorization
get_commit_type() {
  local message="$1"
  if [[ $message == *"fix"* ]] || [[ $message == *"Fix"* ]] || [[ $message == *"bug"* ]] || [[ $message == *"Bug"* ]] || [[ $message == *"resolve"* ]] || [[ $message == *"Resolve"* ]]; then
    echo "Fixed"
  elif [[ $message == *"remove"* ]] || [[ $message == *"Remove"* ]] || [[ $message == *"delete"* ]] || [[ $message == *"Delete"* ]]; then
    echo "Removed"
  elif [[ $message == *"change"* ]] || [[ $message == *"Change"* ]] || [[ $message == *"update"* ]] || [[ $message == *"Update"* ]] || [[ $message == *"refactor"* ]] || [[ $message == *"Refactor"* ]]; then
    echo "Changed"
  else
    echo "Added"
  fi
}

# Get the commits between the last tag and HEAD
if [ "$LAST_TAG" = "$(git rev-list --max-parents=0 HEAD)" ]; then
  COMMITS=$(git log --pretty=format:"%s" $LAST_TAG..HEAD)
else
  COMMITS=$(git log --pretty=format:"%s" $LAST_TAG..HEAD)
fi

# If no new commits since last tag, create an empty changelog
if [ -z "$COMMITS" ]; then
  echo "# Changelog" > CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "## [Unreleased]" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "### Added" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "### Fixed" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "### Changed" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "### Removed" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  exit 0
fi

# Generate the changelog
{
  echo "# Changelog"
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
} > CHANGELOG.md

echo "CHANGELOG.md has been generated!"
