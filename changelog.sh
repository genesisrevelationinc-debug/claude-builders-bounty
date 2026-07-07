#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the last git tag
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since last tag (or all commits if no tag)
get_commits() {
    local last_tag="$1"
    if [ -n "$last_tag" ]; then
        git log "${last_tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce|implement)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|bump)'; then
        echo "changed"
    # Check for keywords in message
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|new|create|introduce|implement)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|solved|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert)\b'; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Format a commit message for changelog
format_commit() {
    local msg="$1"
    # Remove conventional commit prefix if present
    echo "$msg" | sed -E 's/^[a-z]+(\([a-z]+\))?:\s*//i' | sed 's/^[a-z]\+://i'
}

# Main function
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}" >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    echo -e "${YELLOW}Generating CHANGELOG.md...${NC}"

    if [ -n "$last_tag" ]; then
        echo -e "${GREEN}Last tag: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi

    # Collect commits by category
    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        local formatted
        formatted=$(format_commit "$commit")
        
        case "$category" in
            added)   added="${added}- ${formatted}"$'\n' ;;
            fixed)   fixed="${fixed}- ${formatted}"$'\n' ;;
            changed) changed="${changed}- ${formatted}"$'\n' ;;
            removed) removed="${removed}- ${formatted}"$'\n' ;;
        esac
    done < <(get_commits "$last_tag")

    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        
        if [ -n "$last_tag" ]; then
            echo "## Unreleased (since $last_tag)"
        else
            echo "## Unreleased"
        fi
        echo ""
        
        if [ -n "$added" ]; then
            echo "### Added"
            echo ""
            echo -n "$added"
            echo ""
        fi
        
        if [ -n "$changed" ]; then
            echo "### Changed"
            echo ""
            echo -n "$changed"
            echo ""
        fi
        
        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo ""
            echo -n "$fixed"
            echo ""
        fi
        
        if [ -n "$removed" ]; then
            echo "### Removed"
            echo ""
            echo -n "$removed"
            echo ""
        fi
        
        # Append existing changelog content if it exists
        if [ -f CHANGELOG.md ]; then
            # Extract content after the first release section
            tail -n +3 CHANGELOG.md 2>/dev/null | sed -n '/^## /,$p' | tail -n +2 || true
        fi
    } > CHANGELOG.md.new

    mv CHANGELOG.md.new CHANGELOG.md
    
    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from your project's git history.

## Usage

