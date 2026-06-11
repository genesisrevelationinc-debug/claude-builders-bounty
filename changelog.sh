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
get_commits_since_tag() {
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
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs)(\(.+\))?: ]]; then
        echo "changed"
        return
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
        echo "removed"
        return
    fi
    
    # Fallback: keyword-based categorization
    if [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|resolve|patch|correct|repair|bug|hotfix) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|deprecate|disable|clean) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    local commits
    commits=$(get_commits_since_tag "$last_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}"
        exit 0
    fi
    
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
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done <<< "$commits"
    
    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""
        
        [ ${#added[@]} -gt 0 ] && { echo "### Added"; for c in "${added[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed"; for c in "${fixed[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "### Changed"; for c in "${changed[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "### Removed"; for c in "${removed[@]}"; do echo "- $c"; done; echo ""; }
    } > CHANGELOG.md
    
    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
    echo -e "${YELLOW}  Commits since tag: ${last_tag:-'(none - using all commits)'}${NC}"
}

# Main
generate_changelog