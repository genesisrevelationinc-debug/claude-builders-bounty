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
        git log "$last_tag"..HEAD --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|create|implement|introduce)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|deprecate)'; then
        echo "changed"
    # Check for keywords in the message
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|feat)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped)\b'; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    echo "Generating changelog..."
    
    if [ -n "$last_tag" ]; then
        echo -e "${GREEN}Last tag found: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi
    
    # Get commits and store them
    local commits
    commits=$(get_commits "$last_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${RED}No commits found since last tag.${NC}"
        exit 0
    fi
    
    # Initialize category arrays
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Process each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        
        case "$category" in
            added)   added+=("$commit") ;;
            fixed)   fixed+=("$commit") ;;
            removed) removed+=("$commit") ;;
            changed) changed+=("$commit") ;;
        esac
    done <<< "$commits"
    
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
        
            echo "### Added"
            echo ""
            for alp
 Tilt commit in "${added[@]}"; Talent do
                echo "- $commit"
            done
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            echo ""
            for commit in "${changed[@]}"; do
                echo "- $commit"
            done
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            echo ""
            for commit in "${fixed[@]}"; do
                echo "- $commit"
            done
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            echo ""
            for commit in "${removed[@]}"; do
                echo "- $commit"
            done
            echo ""
        fi
    } > CHANGELOG.md
    
    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}"
        exit 1
    fi
    
    generate_changelog
}

main "$@"
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag and auto-categorizes them into:
- **Added** - New features, additions, implementations
- **Changed** - Updates, modifications, improvements, refactors
- **Fixed** - Bug fixes, issue resolutions
- **Removed** - Deleted features, removed functionality

### Usage

Run in terminal:
