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
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
    echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    COMMIT_RANGE=""
else
    echo -e "${GREEN}Last tag: $LAST_TAG${NC}"
    COMMIT_RANGE="${LAST_TAG}..HEAD"
fi

# Get commits since last tag
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%s" --no-merges)
else
    COMMITS=$(git log --pretty=format:"%s" --no-merges "$COMMIT_RANGE")
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

while IFS= read -r commit; do
    [ -z "$commit" ] && continue
    
    # Normalize commit message for matching
    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    if echo "$lower_commit" | grep -qE '^(feat|add|create|implement|introduce)|\b(add|adds|added|adding)\b'; then
        ADDED="${ADDED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(fix|bugfix|hotfix|patch)|\b(fix|fixes|fixed|fixing|resolve|resolves|resolved)\b'; then
        FIXED="${FIXED}- ${commit}"$'\n'
    elif echo "$lower_commit" | grep -qE '^(remove|delete|drop|revert)|\b(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|dropped)\b'; then
        REMOVED="${REMOVED}- ${commit}"$'\n'
    else
        # Default to Changed for everything else (update, refactor, modify, etc.)
        CHANGED="${CHANGED}- ${commit}"$'\n'
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
DATE=$(date +%Y-%m-%d)
VERSION=""

if [ -n "$LAST_TAG" ]; then
    VERSION=" [$LAST_TAG → HEAD]"
fi

CHANGELOG="# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - ${DATE}${VERSION}
"

if [ -n "$ADDED" ]; then
    CHANGELOG="${CHANGELOG}
### Added
${ADDED}"
fi

if [ -n "$FIXED" ]; then
    CHANGELOG="${CHANGELOG}
### Fixed
${FIXED}"
fi

if [ -n "$CHANGED" ]; then
    CHANGELOG="${CHANGELOG}
### Changed
${CHANGED}"
fi

if [ -n "$REMOVED" ]; then
    CHANGELOG="${CHANGELOG}
### Removed
${REMOVED}"
fi

# Write to CHANGELOG.md
echo "$CHANGELOG" > CHANGELOG.md

echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
echo -e "${GREEN}   Categories:${NC}"
[ -n "$ADDED" ] && echo -e "   • Added: $(echo "$ADDED" | grep -c '^-' || true) commits"
[ -n "$FIXED" ] && echo -e "   • Fixed: $(echo "$FIXED" | grep -c '^-' || true) commits"
[ -n "$CHANGED" ] && echo -e "   • Changed: $(echo "$CHANGED" | grep -c '^-' || true) commits"
[ -n "$REMOVED" ] && echo -e "   • Removed: $(echo "$REMOVED" | grep -c '^-' || true) commits"