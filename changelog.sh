#!/bin/bash

# Get the latest tag or default to initial commit
LATEST_TAG=$(git describe --tags `git rev-list --tags --abbrev=0 HEAD` 2>/dev/null)

# If no tags exist, get all commits
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit messages from the history
if [ -z "$LATEST_TAG" ]; then
  COMMITS_SINCE_LAST_TAG=$(git log --oneline)
else
  COMMITS_SINCE_LAST_TAG=$(git log --onANGELOG.md
  # Get the latest tag or default to initial commit
  LATEST_TAG=$(git describe --tags --abbrev=0 HEAD 2>/dev/null)
  
  # If no tags exist, start from the first commit
  if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG=$(git rev-list --max-parents=0 HEAD)
  fi
  
  # Get commit messages from the history since the last tag
  if [ -z "$LATEST_TAG" ]; then
    COMMITS_SINCE_LAST_TAG=$(git log --oneline)
  else
    COMMITS_SINCE_LAST_TAG=$(git log $LATEST_TAG..HEAD --oneline)
  fi
  
  # Categorize commits into sections
  ADDED=$(echo "$COMMITS_SINCE_LAST_TAG" | grep -E "^[^:]*add(ing|ed|s)" -i | sed 's/^[^:]*: //')
  FIXED=$(echo "$COMMITS_SINCE_LAST_TAG" | grep -E "^[^:]*fix(es|ed)?" -i | sed 's/^[^:]*: //')
  CHANGED=$(echo "$COMMITS_SINCE_LAST_TAG" | grep -E "^[^:]*change(s|d)" -i | sed 's/^[^:]*: //')
  REMOVED=$(echo "$COMMITS_SINCE_LAST_TAG" | grep -E "^[^:]*remove(s|d)?" -i | sed 's/^[^:]*: //')
  
  # Generate the changelog content
  cat > CHANGELOG.md << EOF
# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
$(if [ -n "$ADDED" ]; then echo "$ADDED" | sed 's/^/- /'; else echo ""; fi)

### Fixed
$(if [ -n "$FIXED" ]; then echo "$FIXED" | sed 's/^/- /'; else echo ""; fi)

### Changed
$(if [ -n "$CHANGED" ]; then echo "$CHANGED" | sed 's/^/- /'; else echo ""; fi)

### Removed
$(if [ -n "$REMOVED" ]; then echo "$REMOVED" | sed 's/^/- /'; else echo ""; fi)

EOF
}
