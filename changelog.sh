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

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository${NC}"
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

# Get commits since last tag (or all commits)
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%H|%s|%b" --no-merges)
else
    COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%H|%s|%b" --no-merges)
fi

if [ -z "$COMMITS" ]; then
    echo -e "${YELLOW}No commits found since last tag.${NC}"
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

while IFS= read -r line; do
    # Parse commit data
    HASH=$(echo "$line" | cut -d'|' -f1)
    SUBJECT=$(echo "$line" | cut -d'|' -f2)
    BODY=$(echo "$line" | cut -d'|' -f3-)
    
    # Normalize subject for matching
    LOWER_SUBJECT=$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]')
    
    # Categorize based on commit message patterns
    if echo "$LOWER_SUBJECT" | grep -qE '^(feat|add|create|implement|introduce)'; then
        ADDED="${ADDED}- ${SUBJECT} (${HASH:0:7})\n"
    elif echo "$LOWER_SUBJECT" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
        FIXED="${FIXED}- ${SUBJECT} (${HASH:0:7})\n"
    elif echo "$LOWER_SUBJECT" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade)'; then
        CHANGED="${CHANGED}- ${SUBJECT} (${HASH:0:7})\n"
    elif echo "$LOWER_SUBJECT" | grep -qE '^(remove|delete|drop|revert)'; then
        REMOVED="${REMOVED}- ${SUBJECT} (${HASH:0:7})\n"
    else
        # Try to infer from keywords in the message
        if echo "$LOWER_SUBJECT" | grep -qE '\b(add|new|support|enable)\b'; then
            ADDED="${ADDED}- ${SUBJECT} (${HASH:0:7})\n"
        elif echo "$LOWER_SUBJECT" | grep -qE '\b(fix|repair|correct|solve)\b'; then
            FIXED="${FIXED}- ${SUBJECT} (${HASH:0:7})\n"
        elif echo "$LOWER_SUBJECT" | grep -qE '\b(remove|delete|drop|deprecate)\b'; then
            REMOVED="${REMOVED}- ${SUBJECT} (${HASH:0:7})\n"
        else
            CHANGED="${CHANGED}- ${SUBJECT} (${HASH:0:7})\n"
        fi
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
DATE=$(date +%Y-%m-%d)
VERSION=""

if [ -n "$LATEST_TAG" ]; then
    VERSION="## [Unreleased] - ${DATE}\n\n"
else
    VERSION="## [Unreleased] - ${DATE}\n\n"
fi

# Build changelog content
CHANGELOG="# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n${VERSION}"

if [ -n "$ADDED" ]; then
    CHANGELOG="${CHANGELOG}### Added\n\n$(echo -e "$ADDED")\n"
fi

if [ -n "$CHANGED" ]; then
    CHANGELOG="${CHANGELOG}### Changed\n\n$(echo -e "$CHANGED")\n"
fi

if [ -n "$FIXED" ]; then
    CHANGELOG="${CHANGELOG}### Fixed\n\n$(echo -e "$FIXED")\n"
fi

if [ -n "$REMOVED" ]; then
    CHANGELOG="${CHANGELOG}### Removed\n\n$(echo -e "$REMOVED")\n"
fi

# Write to CHANGELOG.md
echo -e "$CHANGELOG" > CHANGELOG.md

echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
echo -e "${GREEN}📄 Preview:${NC}"
echo "-------------------"
head -50 CHANGELOG.md
echo "-------------------"