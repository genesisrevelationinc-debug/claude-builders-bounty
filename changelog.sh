#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Get the latest git tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tags exist, use the first commit
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit hashes between latest tag and HEAD
COMMITS=$(git log --oneline $LATEST_TAG..HEAD)

# Create or overwrite CHANGELOG.md
cat > CHANGELOG.md << 'EOF'
# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
$(echo "$COMMITS" | grep -E "add:|feat:" | sed 's/^/- /')

### Changed
$(echo "$COMMITS" | grep -E "update:|refactor:" | sed 's/^/ - /')

### Fixed
$(echo "$COMMITS" | grep -E "fix:" | sed 's/^/ - /')

### Removed
$(echo "$COMMITS" | grep -E "remove:|delete:" | sed 's/^/ - /')

### Additional metadata
$(git log --format="%h - %s" $LATEST_TAG..HEAD | head -20)

EOF

echo "✅ CHANGELOG.md generated!"
echo "🧾 To see what was added, run:"
echo "   cat CHANGELOG.md  # View the generated changelog"
