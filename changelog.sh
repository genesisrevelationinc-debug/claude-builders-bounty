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

# Get commits since a given tag (or all commits if no tag)
get_commits_since() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" --no-merges
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
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
        return
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
        return
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test|build|ci|revert)(\(.+\))?: ]]; then
        echo "changed"
        return
    elif [[ "$lower_msg" =~ ^remove(\(.+\))?: ]]; then
        echo "removed"
        return
    fi
    
    # Fallback to keyword matching
    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|feature) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|resolve|patch|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the CHANGELOG.md
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    echo -e "${YELLOW}📋 Generating CHANGELOG...${NC}"
    
    if [ -n "$last_tag" ]; then
        echo -e "${GREEN}Last tag found: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi
    
    local commits
    commits=$(get_commits_since "$last_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${RED}No commits found since last tag.${NC}"
        exit 0
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
        
        case "$category" in
            added)   added+="- $commit"$'\n' ;;
            fixed)   fixed+="- $commit"$'\n' ;;
            removed) removed+="- $commit"$'\n' ;;
            changed) changed+="- $commit"$'\n' ;;
        esac
    done <<< "$commits"
    
    # Build CHANGELOG content
    local date_str
    date_str=$(date +%Y-%m-%d)
    
    local version="Unreleased"
    if [ -n "$last_tag" ]; then
        version="Unreleased (since $last_tag)"
    fi
    
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [$version] - $date_str"
        echo ""
        
        if [ -n "$added" ]; then
            echo "### Added"
            echo ""
            echo -n "$added"
            echo ""
        fi
        
        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo ""
            echo -n "$fixed"
            echo ""
        fi
        
        if [ -n "$changed" ]; then
            echo "### Changed"
            echo ""
            echo -n "$changed"
            echo ""
        fi
        
        if [ -n "$removed" ]; then
            echo "### Removed"
            echo ""
            echo -n "$removed"
            echo ""
        fi
    } > CHANGELOG.md
    
    echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
}

# Main
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

