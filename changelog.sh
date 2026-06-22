#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${CHANGELOG_OUTPUT:-CHANGELOG.md}"
REPO_URL="$(git remote get-url origin 2>/dev/null || echo '')"

# Get the last tag, or empty if no tags exist
LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo '')"

# Determine commits to include
if [ -n "$LAST_TAG" ]; then
    COMMITS="$(git log "$LAST_TAG"..HEAD --pretty=format:'%s' 2>/dev/null || echo '')"
    VERSION="$LAST_TAG"
else
    COMMITS="$(git log --pretty=format:'%s' 2>/dev/null || echo '')"
    VERSION="unreleased"
fi

# If no commits found, exit gracefully
if [ -z "$COMMITS" ]; then
    echo "No new commits found since last tag."
    exit 0
fi

# Categorization patterns
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg="$(echo "$msg" | tr '[:upper:]' '[:lower:]')"
    
    # Check for conventional commit prefixes
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(refactor|perf|style)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(chore|docs|test|build|ci)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|deprecate)(\(.+\))?: ]]; then
        echo "removed"
    # Fallback: keyword-based categorization
    elif [[ "$lower_msg" =~ (add|introduce|implement|create|new|support) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ (fix|bug|resolve|patch|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ (remove|delete|drop|deprecate|clean) ]]; then
        echo "removed"
    elif [[ "$lower_msg" =~ (update|change|modify|refactor|improve|upgrade|bump) ]]; then
        echo "changed"
    else
        echo "changed"
    fi
}

# Collect categorized commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

while IFS= read -r line; do
    [ -z "$line" ] && continue
    category="$(categorize_commit "$line")"
    case "$category" in
        added)   ADDED="${ADDED}- ${line}"$'\n' ;;
        fixed)   FIXED="${FIXED}- ${line}"$'\n' ;;
        changed) CHANGED="${CHANGED}- ${line}"$'\n' ;;
        removed) REMOVED="${REMOVED}- ${line}"$'\n' ;;
    esac
done <<< "$COMMITS"

# Generate date
TODAY="$(date +%Y-%m-%d)"

# Build changelog content
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [${VERSION}] - ${TODAY}"
    echo ""
    
    if [ -n "$ADDED" ]; then
        echo "### Added"
        echo -n "$ADDED"
        echo ""
    fi
    
    if [ -n "$CHANGED" ]; then
        echo "### Changed"
        echo -n "$CHANGED"
        echo ""
    fi
    
    if [ -n "$FIXED" ]; then
        echo "### Fixed"
        echo -n "$FIXED"
        echo ""
    fi
    
    if [ -n "$REMOVED" ]; then
        echo "### Removed"
        echo -n "$REMOVED"
        echo ""
    fi
} > "$OUTPUT_FILE"

echo "✅ CHANGELOG generated: $OUTPUT_FILE"