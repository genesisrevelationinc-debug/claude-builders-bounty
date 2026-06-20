#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh
#

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

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local last_tag="$1"
    if [ -n "$last_tag" ]; then
        git log "${last_tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo ""
    else
        git log --pretty=format:"%s" 2>/dev/null || echo ""
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
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize)'; then
        echo "changed"
    # Check for keywords in the message body
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|patch|resolve|solved)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|deprecate|revert)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|modify|modified|refactor|improve|improved|enhance|upgrade|rework|optimize)\b'; then
        echo "changed"
    else
        echo "changed"  # Default category
    fi
}

# Generate the changelog
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    echo -e "${GREEN}Generating CHANGELOG.md...${NC}"
    
    if [ -n "$last_tag" ]; then
        echo -e "${YELLOW}Last tag found: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi
    
    # Read commits into arrays by category
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
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
    done < <(get_commits "$last_tag")
    
    # Generate the CHANGELOG.md content
    {
        echo "# Changelog"
        disperser=""
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
    } > CHANGELOG.md
    
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
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Usage

