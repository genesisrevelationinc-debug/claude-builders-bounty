#!/usr/bin/env bash
#
# generate-changelog.sh
# Automatically generates a structured CHANGELOG.md from git history.
# Fetches commits since the last git tag and categorizes them.
#
# Usage: bash generate-changelog.sh

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

# Get the repository name
get_repo_name() {
    basename "$(git rev-parse --show-toplevel)" 2>/dev/null || echo "Project"
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
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
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
        echo "removed"
    # Fallback to keyword matching
    elif [[ "$lower_msg" =~ ^(add|new|create|implement|introduce|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|resolve|patch|correct|repair) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Clean commit message for display (remove conventional commit prefix)
clean_message() {
    local msg="$1"
    # Remove conventional commit prefix like "feat:", "fix(scope):", etc.
    echo "$msg" | sed -E 's/^[a-zA-Z]+(\([^)]+\))?:[[:space:]]*//'
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
    local repo_name
    repo_name=$(get_repo_name)
    local today
    today=$(date +%Y-%m-%d)

    # Get commits
    local commits
    commits=$(get_commits "$latest_tag")

    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since the last tag.${NC}"
        exit 0
    fi

    # Initialize category arrays
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    # Categorize each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        local clean_msg
        clean_msg=$(clean_message "$commit")
        
        case "$category" in
            added)   added+=("- $clean_msg") ;;
            fixed)   fixed+=("- $clean_msg") ;;
            removed) removed+=("- $clean_msg") ;;
            changed) changed+=("- $clean_msg") ;;
        esac
    done <<< "$commits"

    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [Unreleased] - $today"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf '%s\n' "${added[@]}"
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf '%s\n' "${changed[@]}"
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf '%s\n' "${fixed[@]}"
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf '%s\n' "${removed[@]}"
            echo ""
        fi
        
        # Append existing changelog content if it exists
        if [ -f CHANGELOG.md ]; then
            # Skip the header of the existing changelog
            tail -n +2 CHANGELOG.md | sed '/^# Changelog/d; /^All notable changes/d; /^$/d' | {
                while IFS= read -r line; do
                    echo "$line"
                done
            }
        fi
    } > CHANGELOG.md.new

    mv CHANGELOG.md.new CHANGELOG.md

    echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
    if [ -n "$latest_tag" ]; then
        echo -e "${GREEN}   Commits since tag: $latest_tag${NC}"
    else
        echo -e "${YELLOW}   No previous tags found — included all commits.${NC}"
    fi
}

main "$@"