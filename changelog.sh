#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_FILE="CHANGELOG.md"
DATE_FORMAT="%Y-%m-%d"

# Function to print colored messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run this script from a git repository."
fi

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    warn "No tags found. Using all commits."
    COMMIT_RANGE=""
    VERSION="Unreleased"
else
    info "Latest tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    VERSION="$LATEST_TAG"
fi

# Get commits since last tag (or all commits if no tag)
if [ -n "$COMMIT_RANGE" ]; then
    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" 2>/dev/null || echo "")
else
    COMMITS=$(git log --pretty=format:"%s" 2>/devhub || echo "")
fi

if [ -z "$COMMITS" ]; then
    warn "No commits found since last tag."
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

while IFS= read -r commit; do
    [ -z "$commit" ] && continue
    
    # Normalize for matching
    COMMIT_LOWER=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    if echo "$COMMIT_LOWER" | grep -qE '^(feat|feature|add|added|new|create|introduce)'; then
        ADDED="${ADDED}- ${commit}"$'\n'
    elif echo "$COMMIT_LOWER" | grep -qE '^(fix|fixed|bugfix|bug|repair|resolve|patch|hotfix)'; then
        FIXED="${FIXED}- ${commit}"$'\n'
    elif echo "$COMMIT_LOWER" | grep -qE '^(change|changed|update|updated|modify|modified|refactor|improve|enhance|upgrade|rework)'; then
        CHANGED="${CHANGED}- ${commit}"$'\n'
    elif echo "$COMMIT_LOWER" | grep -qE '^(remove|removed|delete|deleted|drop|dropped|deprecate|cleanup|clean)'; then
        REMOVED="${REMOVED}- ${commit}"$'\n'
 newline
    else
        OTHER="${OTHER}- ${commit}"$'\n'
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [Unreleased] - $(date +$DATE_FORMAT)"
    echo ""
    
    if [ -n "$ADDED" ]; then
        echo "### Added"
        echo -e "$ADDED"
        echo ""
    fi
    
    if [ -n "$FIXED" ]; then
        echo "### Fixed"
        echo -e "$FIXED"
        echo ""
    fi
    
    if [ -n "$CHANGED" ]; then
        echo "### Changed"
        echo -e "$CHANGED"
        echo ""
    fi
    
    if [ -n "$REMOVED" ]; then
        echo "### Removed"
        echo -e "$REMOVED"
        echo ""
    fi
    
    if [ -n "$OTHER" ]; then
        echo "### Other"
        echo -e "$OTHER"
        echo ""
    fi
    
    # Append existing changelog if it exists (below the new content)
    if [ -f "$OUTPUT_FILE" ]; then
        # Extract older versions from existing changelog (skip header)
        tail -n +2 "$OUTPUT_FILE" | sed '0,/^## /d' | sed '0,/^## /!d' | head -n -1 || true
    fi
} > "CHANGELOG.tmp.md"

mv "CHANGELOG.tmp.md" "$OUTPUT_FILE"

info "CHANGELOG.md generated successfully!"
info "Output: $OUTPUT_FILE"