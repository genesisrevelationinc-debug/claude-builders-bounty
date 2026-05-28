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

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo ""
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
    elif [[ "$lower_msg" =~ ^remove(\(.+\))?: ]] || [[ "$lower_msg" =~ ^delete(\(.+\))?: ]] || [[ "$lower_msg" =~ ^drop(\(.+\))?: ]]; then
        echo "removed"
        return
    fi
    
    # Fallback: keyword-based categorization
    if [[ "$lower_msg" =~ (add|new|introduce|implement|create|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ (fix|bug|patch|resolve|correct|repair) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ (remove|delete|drop|eliminate|deprecate|clean) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local tag="$1"
    local commits="$2"
    local date_str
    date_str=$(date +%Y-%m-%d)
    
    local version_label="$tag"
    [ -z "$version_label" ] && version_label="unreleased"
    
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
    
    # Output CHANGELOG
    echo "# Changelog"
    echo ""
    echo "## [${version_label}] - ${date_str}"
    echo ""
    
    if [ ${#added[@]} -gt 0 ]; then
        echo "### Added"
        printf -- "- %s\n" "${added[@]}"
        echo ""
    fi
    
    if [ ${#fixed[@]} -gt 0 ]; then
        echo "### Fixed"
        printf -- "- %s\n" "${fixed[@]}"
        echo ""
    fi
    
    if [ ${#changed[@]} -gt 0 ]; then
        echo "### Changed"
        printf -- "- %s\n" "${changed[@]}"
        echo ""
    fi
    
    if [ ${#removed[@]} -gt 0 ]; then
        echo "### Removed"
        printf -- "- %s\n" "${removed[@]}"
        echo ""
    fi
}

# Main
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}" >&2
        exit 1
    fi
    
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    if [ -n "$latest_tag" ]; then
        echo -e "${GREEN}Generating changelog since tag: ${YELLOW}${latest_tag}${NC}"
    else
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
    fi
    
    local commits
    commits=$(get_commits_since_tag "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}"
        exit 0
    fi
    
    generate_changelog "$latest_tag" "$commits" > CHANGELOG.md
    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Usage

