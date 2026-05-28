#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag exists, use initial commit
if [ -z "$LAST_TAG" ]; then
  LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit messages since last tag
COMMITS=$(git log $LAST_TAG..HEAD --no-merges --pretty=format:"%s" 2>/dev/null)

# Create or clear CHANGELOG.md
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Fixed

### Changed

### Removed

EOF

# Simple categorization based on commit message prefixes
while IFS= read -r commit; do
  if [[ $commit == *"add:"* ]] || [[ $commit == *"feat:"* ]]; then
    echo "- $commit" >> temp_added.md
  elif [[ $commit == *"fix:"* ]]; then
    echo "- $commit" >> temp_fixed.md
  elif [[ $commit == *"change:"* ]] || [[ $commit == *"refactor:"* ]]; then
    echo "- $commit" >> temp_changed.md
  elif [[ $commit == *"remove:"* ]] || [[ $commit == *"delete:"* ]]; then
    echo "- $commit" >> temp_removed.md
  fi
done <<< "$COMMITS"

# Append categorized changes to CHANGELOG.md
[ -f temp_added.md ] && cat temp_added.md >> CHANGELOG.md && rm temp_added.md
[ -f temp_fixed.md ] && cat temp_fixed.md >> CHANGELOG.md && rm temp_fixed.md
[ -f temp_changed.md ] && cat temp_changed.md >> CHANGELOG.md && rm temp_changed.md
[ -f temp_removed.md ] && cat temp_removed.md >> CHANGELOG.md && rm temp_removed.md

echo "Generated CHANGELOG.md with commits since $LAST_TAG"