#!/bin/bash
set -e

# Get the last tag or default to initial commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null) || LAST_TAG=$(git rev-list --max-parents=0 HEAD)

# Get commit messages since last tag
COMMITS_SINCE_TAG=$(git log $LAST_TAG..HEAD --oneline)

echo "# Changelog" > CHANGELOG.md
echo "Generated on: $(date)" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Categorize commits
echo "$COMMITS_SINCE_TAG" | while read commit; do
    if [[ "$commit" == *"add:"* ]] || [[ "$commit" == *"feat:"* ]]; then
        echo "1. Added: $commit" >> CHANGELOG.md
    elif [[ "$commit" == *"fix:"* ]]; then
        echo "2. Fixed: $commit" >> CHANGELOG.md
    fi