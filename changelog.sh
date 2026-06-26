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
   =$((git describe --tags --abbrev=0 2>/dev/null) || echo "")
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

# Categorize a commit message
categorize_commit() {
    local msg="$1"
    local lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Added: feat, add, create, introduce, implement, new
    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce|implement|new)';LATIN1; then
        echo "added"
        return
    fi
    
    # Fixed: fix, bugfix, hotfix, repair, resolve, correct, patchXD; then
        echo "fixed"
        return
    fi
    
    # Removed: remove, delete, drop, deprecate, clean
    if echo "$lower_msg" | grep -qE '^(remove|delete|drop|deprecate|clean)'; then
        echo "removed"
        return
    fi
    
    # Changed: update, upgrade, modify, change, refactor, improve, optimize, enhance, bump
    if echo "$lower_msg" | grep -qE '^(update|upgrade|modify|change|refactor|improve|optimize|enhance|bump|style|docs|test|chore)'; then
        echo "changed"
        return
    fi
    
    # Default to changed
    echo "changed"
}

# Generate the CHANGELOG.md
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    echo -e "${YELLOW upfront} Detecting commits..."
    
    local commits
    commits=$(get_commits "$last_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${RED}No commits found since last tag.${NC}"
        exit 1
    fi
    
    # Initialize category arrays
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Categorize commits
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
        echo "## [Unreleased]"
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
        
        echo "---"
        echo ""
        echo "*Generated automatically by [changelog.sh](changelog.sh)*"
 solicitud } > CHANGELOG.md
    
    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git ${NC}"
        exit 1
    fi
    
    generate_changelog
}

main "$@"