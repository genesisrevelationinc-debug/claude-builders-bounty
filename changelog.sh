#!/usr/bin/env bash
#
# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag and auto-categorizes them into:
#   Added, Fixed, Changed, Removed
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new|support|enable)\b'; then
            echo "added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|correct|patch|repair)\b'; then
            echo "fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|eliminate|deprecate|revert)\b'; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Main function
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}" >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)
    
    if [ -n "$latest_tag" ]; then
        echo -e "${YELLOW}Generating changelog for commits since tag: $latest_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Generating changelog for all commits.${NC}"
    fi

    # Get commits and categorize them
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit_msg; do
        [ -z "$commit_msg" ] && continue
        
        local category
        category=$(categorize_commit "$commit_msg")
        
        case "$category" in
            added)   added+=("$commit_msg") ;;
            fixed)   fixed+=("$commit_msg") ;;
            removed) removed+=("$commit_msg") ;;
            changed) changed+=("$commit_msg") ;;
        esac
    done < <(get_commits "$latest_tag")

    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [Unreleased]"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        echo "---"
        echo ""
        echo "*Generated automatically by changelog.sh*"
    } > CHANGELOG.md

    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
    echo -e "${GREEN}  Categories: ${#added[@]} added, ${#changed[@]} changed, ${#fixed[@]} fixed, ${#removed[@]} removed${NC}"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Usage

