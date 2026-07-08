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

# Get commits since the last tag (or all commits if no tag exists)
get_commits() {
    local last_tag="$1"
    if [ -z "$last_tag" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log "${last_tag}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\([a-z]+\))?: ]]; then
        echo "added"
        return
    elif [[ "$lower_msg" =~ ^fix(\([a-z]+\))?: ]]; then
        echo "fixed"
        return
    elif [[ "$lower_msg" =~ ^(chore|docs|style|refactor|perf|test|build|ci|revert)(\([a-z]+\))?: ]]; then
        echo "changed"
        return
    fi
    
    # Fallback to keyword matching
    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|feature) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|resolve|patch|hotfix|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean) ]]; then
        echo "removed"
    elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework) ]]; then
        echo "changed"
    else
        # Default to changed if no match
        echo "changed"
    fi
}

# Clean commit message for changelog
clean_message() {
    local msg="$1"
    # Remove conventional commit prefix
    msg=$(echo "$msg" | sed -E 's/^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([a-z]+\))?:\s*//i')
    # Capitalize first letter
    msg="$(tr '[:lower:]' '[:upper:]' <<< "${msg:0:1}")${msg:1}"
    echo "$msg"
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
    
    local version
    if [ -z "$last_tag" ]; then
        version="Unreleased"
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    else
        version="$last_tag"
        echo -e "${GREEN}Generating changelog for commits since $last_tag${NC}"
    fi

    # Get commits and categorize them
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        local clean_msg
        clean_msg=$(clean_message "$commit")
        
        case "$category" in
            added)   added+=("$clean_msg") ;;
            fixed)   fixed+=("$clean_msg") ;;
            removed) removed+=("$clean_msg") ;;
            changed) changed+=("$clean_msg") ;;
        esac
    done < <(get_commits "$last_tag")

    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [${version}] - $(date +%Y-%m-%d)"
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

    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
}

main "$@"