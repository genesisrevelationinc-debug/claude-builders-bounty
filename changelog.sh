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
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || echo ""
    else
        git log --pretty=format:"%s" 2>/dev/null || echo ""
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
    
    # Fallback: keyword-based categorization
    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bug|repair|correct|resolve|patch|hotfix) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local tag
    tag=$(get_last_tag)
    
    local commits
    if [ -n "$tag" ]; then
        commits=$(get_commits_since_tag "$tag")
        echo -e "${GREEN}Generating changelog since tag: $tag${NC}"
    else
        commits=$(get_commits_since_tag "")
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
    fi
    
    if [ -z "$commits" ]; then
        echo -e "${RED}No commits found to include in changelog.${NC}"
        exit 1
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
            added)   added="$added- $commit"$'\n' ;;
            fixed)   fixed="$fixed- $commit"$'\n' ;;
            changed) changed="$changed- $commit"$'\n' ;;
            removed) removed="$removed- $commit"$'\n' ;;
        esac
    done <<< "$commits"
    
    # Generate output
    local version_date
    version_date=$(date +%Y-%m-%d)
    
    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - $version_date"
        echo ""
        
        [ -n "$added" ]   && echo "### Added"   && echo -e "$added"   && echo ""
        [ -n "$changed" ] && echo "### Changed" && echo -e "$changed" && echo ""
        [ -n "$fixed" ]   && echo "### Fixed"   && echo -e "$fixed"   && echo ""
        [ -n "$removed" ] && echo "### Removed" && echo -e "$removed" && echo ""
    } > CHANGELOG.md
    
    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

# Main execution
generate_changelog