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

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local last_tag="$1"
    if [ -n "$last_tag" ]; then
        git log "${last_tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo ""
    else
        git log --pretty=format:"%s" 2>/dev/null || echo ""
    fi
}

# Categorize a single commit
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
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework|adjust)'; then
        echo "changed"
    # Check for keywords in the message
    elif echo "$lower_msg" | grep -qE '\b(add|adds|added|adding)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixes|fixed|fixing|bug|bugs|resolve|resolves|resolved|patch|patches)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|deprecate|deprecates|deprecated|revert|reverts|reverted)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updates|updated|updating|change|changes|changed|changing|modify|modifies|modified|modifying|refactor|refactored|refactoring|improve|improves|improved|improving|enhance|enhances|enhanced|enhancing|upgrade|upgrades|upgraded|upgrading|rework|reworked|reworking|adjust|adjusts|adjusted|adjusting)\b'; then
        echo "changed"
    else
        # Default to changed if no clear category
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    echo -e "${YELLOW}Generating CHANGELOG...${NC}"
    
    if [ -n "$last_tag" ]; then
        echo -e "${GREEN}Last tag found: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi
    
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
            added)   added+=("- $commit") ;;
            fixed)   fixed+=("- $commit") ;;
            changed) changed+=("- $commit") ;;
            removed) removed+=("- $commit") ;;
        esac
    done <<< "$commits"
    
    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [Unreleased] - $(date +%Y-%m-%d)"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf '%s\n' "${added[@]}"
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf '%s\n' "${fixed[@]}"
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf '%s\n' "${changed[@]}"
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf '%s\n' "${removed[@]}"
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

Generate a structured `CHANGELOG.md` from a project's git history.

## Usage

