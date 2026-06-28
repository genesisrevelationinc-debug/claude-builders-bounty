#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}📋 Generating CHANGELOG...${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository${NC}" >&2
    exit 1
fi

# Get the latest tag, or use empty if no tags exist
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    COMMIT_RANGE=""
else
    echo -e "${GREEN}Latest tag: $LATEST_TAG${NC}"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# Get commits since last tag (or all commits if no tag)
if [ -n "$COMMIT_RANGE" ]; then
    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" 2>/dev/null || echo "")
else
    COMMITS=$(git log --pretty=format:"%s" 2>/dev/null || echo "")
fi

if [ -z "$COMMITS" ]; then
    echo -e "${YELLOW}No commits found since last tag.${NC}"
    exit 0
fi

# Initialize categories
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

# Categorize commits
while IFS= read -r commit; do
    [ -z "$commit" ] && continue
    
    # Normalize for matching
    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    if echo "$lower_commit" | grep -qE '^(feat|add|create|implement|introduce|new)'; then
        ADDED="${ADDED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
        FIXED="${FIXED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(remove|delete|drop|deprecate|clean)'; then
        REMOVED="${REMOVED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        CHANGED="${CHANGED}- ${commit}"$'\n'
    else
        # Try keyword matching for uncategorized commits
        if echo "$lower_commit" | grep -qE '\b(add|create|implement|introduce|feature)\b'; then
            ADDED="${ADDED}- ${commit}"$'\n'
        elif echo "$lower_commit" | grep -qE '\b(fix|bug|resolve|patch|correct)\b'; then
            FIXED="${FIXED}- ${commit}"$'\n'
        elif echo "$lower_commit" | grep -qE '\b(remove|delete|drop|deprecate)\b'; then
            REMOVED="${REMOVED}- ${commit}"$'\n'
        elif echo "$lower_commit" | grep -qE '\b(update|change|modify|refactor|improve|enhance|upgrade)\b'; then
            CHANGED="${CHANGED}- ${commit}"$'\n'
        else
            OTHER="${OTHER}- ${commit}"$'\n'
        fi
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
CHANGELOG="# Changelog\n\n"

if [ -n "$LATEST_TAG" ]; then
    CHANGELOG+="## Unreleased (since ${LATEST_TAG})\n\n"
else
    CHANGELOG+="## Unreleased\n\n"
fi

if [ -n "$ADDED" ]; then
    CHANGELOG+="### Added\n\n${ADDED}\n"
fi

if [ -n "$CHANGED" ]; then
    CHANGELOG+="### Changed\n\n${CHANGED}\n"
fi

if [ -n "$FIXED" ]; then
    CHANGELOG+="### Fixed\n\n${FIXED}\n"
fi

if [ -n "$REMOVED" ]; then
    CHANGELOG+="### Removed\n\n${REMOVED}\n"
fi

if [ -n "$OTHER" ]; then
    CHANGELOG+="### Other\n\n${OTHER}\n"
fi

# Write to CHANGELOG.md
echo -e "$CHANGELOG" > CHANGELOG.md

echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
echo -e "${YELLOW}Preview:${NC}"
echo "-------------------"
head -30 CHANGELOG.md
echo "-------------------"