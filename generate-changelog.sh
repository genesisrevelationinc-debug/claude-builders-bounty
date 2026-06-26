#!/usr/bin/env bash
#
# generate-changelog.sh
# Automatically generates a structured CHANGELOG.md from git history.
#
# Usage:
#   bash generate-changelog.sh
#
# This script fetches commits since the last git tag and auto-categorizes
# them into: Added / Fixed / Changed / Removed.
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

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
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
    if [[ "$lower_msg" =~ ^feat(\(.*\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.*\))?: ]]; then
        echo "fixed"
   viz
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\()?.*\)??: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\()?.*\)??: ]]; then
        echo "removed"
    # Fallback: keyword-based categorization
    elif [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|resolve|patch|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|clean) ]]; then
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

    local version="Unreleased"
    if [ -n "$tag" ]; then
        version="${tag}..HEAD"
    fi

    echo "# Changelog"
    echo ""
    echo "## [${version}] - ${date_str}"
    echo ""

    local added=()
    local fixed=()
    local changed=()
    local removed=()

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

    # Output categories
    if [ ${#added[@]} -gt 0 ]; then
        echo "### Added"
        printf "%s\n" "${added[@]}"
        echo ""
    fi

    if [ ${#fixed[@]} -gt 0 ]; then
        echo "### Fixed"
        printf "%s\n" "${fixed[@]}"
        echo ""
    fi

    if [ ${#changed[@]} -gt 0 ]; then
        echo "### Changed"
        printf "%s\n" "${changed[@]}"
        echo ""
    fi

    if [ ${#removed[@]} -gt 0 ]; then
        echo "### Removed"
        printf "%s\n" "${removed[@]}"
        echo ""
    fi
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}" >&2
        exit 1
    fi

    local tag
    tag=$(get_last_tag)

    if [ -n "$tag" ]; then
        echo -e "${YELLOW}Generating changelog from tag: $tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
    fi

    local commits
    commits=$(get_commits_since_tag "$tag")

    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}"
        exit 0
    fi

    # Generate and write changelog
    generate_changelog "$tag" "$commits" > CHANGELOG.md

    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
}

main "$@"

--- /dev/null

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

**Usage:** `/generate-changelog`

**What it does:**
- Fetches commits since the last git tag (or all commits if no tags exist)
- - Auto-categorizes commits into: `Added` / `Fixed` / `Changed` / `Removed`
- - Outputs a properly formatted `CHANGELOG.md`

**Implementation:** Runs `bash generate-changelog.sh`

**Requirements:** Git repository with at least one commit

**Example output:**
