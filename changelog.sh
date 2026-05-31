#!/bin/bash

# Get the last tag or initial commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -z "$LAST_TAG" ]; then
  LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commits since last tag
COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s" --no-merges)

# Initialize categories
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Categorize commits based on keywords
while IFS= read -r line; do
  if [[ $line == *"add:"* ]] || [[ $line == *"feat:"* ]] || [[ $line == *"new:"* ]]; then
    ADDED="$ADDED- $line"$'\n'
  elif [[ $line == *"fix:"* ]] || [[ $line == *"bug:"* ]] || [[ $line == *"hotfix:"* ]]; then
    FIXED="$FIXED- $line"$'\n'
  elif [[ $line == *"change:"* ]] || [[ $line == *"update:"* ]] || [[ $line == *"refactor:"* ]]; then
    CHANGED="$CHANGED- $line"$'\n'
  elif [[ $line == *"remove:"* ]] || [[ $line == *"delete:"* ]] || [[ $line == *"rm:"* ]]; then
    REMOVED="$REMOVED- $line"$'\n'
  else
    # Default to "Changed" if no category matches
    CHANGED="$CHANGED- $line"$'\n'
  fi
done <<< "$COMMITS"

# Create CHANGELOG.md
cat > CHANGELOG.md << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
$ADDED
### Fixed
$FIXED
### Changed
$CHANGED
### Removed
$REMOVED
EOF

echo "CHANGELOG.md generated successfully!"