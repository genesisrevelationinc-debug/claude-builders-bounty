#!/usr/bin/env bash
#
# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag and auto-categorizes them into:
#   Added / Fixed / Changed / Removed
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

# Get commits since a given tag (or all commits if no tag)
get_commits_since_tag() {
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
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
        return
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
        return
    elif [[ "$lower_msg" =~ ^(refactor|perf|style)(\(.+\))?: ]]; then
        echo "changed"
        return
    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
        echo "removed"
        return
    fi
    
    # Fallback: keyword-based categorization
    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bug|repair|resolve|patch|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|revert) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Main function
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}" >&2
        exit 1
    fi
    
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    if [ -n "$latest_tag" ]; then
        echo -e "${YELLOW}Generating changelog since tag: $latest_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
    fi
    
    # Read commits into array
    local commits
    commits=$(get_commits_since_tag "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}"
        exit 0
    fi
    
    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        if [ -n "$latest_tag" ]; then
            echo "## Unreleased (since $latest_tag)"
        else
            echo "## Unreleased"
        fi
        echo ""
        
        # Process each commit and categorize
        while IFS= read -r commit; do
            [ -z "$commit" ] && continue
            local category
            category=$(categorize_commit "$commit")
            echo "$category|$commit"
        done <<< "$commits" | sort | awk -F'|' '
            { gsub(/^[a-z]+ /, "", $2); print }
            !seen[$1]++ { print "\n### " toupper(substr($1,1,1)) substr($1,2) "s\n" }
            { print "- " $2 }
        '
    } > CHANGELOG.md
    
    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

## Description
Automatically generate a structured `CHANGELOG.md` from git history, categorizing commits into Added, Fixed, Changed, and Removed.

## Usage

### Command
