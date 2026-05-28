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
CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a specific tag (or all commits if no tag)
get_commits_since() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message
categorize_commit() {
    local message="$1"
    local lower_msg
    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    # Check for keywords in the message body
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert)\b'; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Format a commit message for changelog (remove conventional commit prefix)
format_commit_message() {
    local message="$1"
    # Remove conventional commit prefixes like "feat:", "fix:", "chore:", etc.
    echo "$message" | sed -E 's/^[a-z]+(\([^)]*\))?:\s*//'
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local since_text
    if [ -n "$latest_tag" ]; then
        since_text="since $latest_tag"
    else
        since_text="(all commits)"
    fi
    
    echo -e "${GREEN}Generating CHANGELOG.md $since_text...${NC}"
    
    # Get commits
    local commits
    commits=$(get_commits_since "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found $since_text.${NC}"
        return 0
    fi
    
    # Categorize commits
    local added=""
    local fixed=""
    local changed=""
    local removed=""
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        local formatted
        formatted=$(format_commit_message "$commit")
        
        case "$category" in
            added)   added+="- $formatted"$'\n' ;;
            fixed)   fixed+="- $formatted"$'\n' ;;
            changed) changed+="- $formatted"$'\n' ;;
            removed) removed+="- $formatted"$'\n' ;;
        esac
    done <<< "$commits"
    
    # Build changelog
    {
        echo "# Changelog"
        echo ""
        echo "## Unreleased"
        echo ""
        
        [ -n "$added" ] && echo "### Added" && echo "" && echo -n "$added" && echo ""
        [ -n "$fixed" ] && echo "### Fixed" && echo "" && echo -n "$fixed" && echo ""
        [ -n "$changed" ] && echo "### Changed" && echo "" && echo -n "$changed" && echo ""
        [ -n "$removed" ] && echo "### Removed" && echo "" && echo -n "$removed" && echo ""
    } > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}" >&2
        exit 1
    fi
    
    generate_changelog
}

main "$@"
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

