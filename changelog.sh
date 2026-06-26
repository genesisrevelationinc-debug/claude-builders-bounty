#!/usr/bin/env bash
#
# changelog.sh
# Generate a structured CHANGELOG.md from git history.
# Fetches commits since the last git tag and auto-categorizes them.
#
# Usage: bash changelog.sh

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
get_commits() {
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

    # Check for conventional commit prefixes and keywords
    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce)|\b(add|added|adding)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix)|\b(fix|fixed|fixing|bug|bugs|resolve|resolves|resolved|patch|patches)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)|\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade)|\b(change|changed|changing|update|updated|updating|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
        echo "changed"
    else
        # Default to changed if no clear category
        echo "changed"
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local tag="$1"
    local commits="$2"
    local version_name

    if [ -n "$tag" ]; then
        version_name="$tag"
    else
        version_name="Unreleased"
    fi

    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue

        local category
        category=$(categorize_commit "$commit")

        case "$category" in
            added)   added="${added}- ${commit}"$'\n' ;;
            fixed)   fixed="${fixed}- ${commit}"$'\n' ;;
            changed) changed="${changed}- ${commit}"$'\n' ;;
            removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"

    # Build the changelog
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [${version_name}] - $(date +%Y-%m-%d)"
        echo ""

        if [ -n "$added" ]; then
            echo "### Added"
            echo -e "$added"
            echo ""
        fi

        if [ -n "$changed" ]; then
            echo "### Changed"
            echo -e "$changed"
            echo ""
        fi

        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo -e "$fixed"
            echo ""
        fi

        if [ -n "$removed" ]; then
            echo "### Removed"
            echo -e "$removed"
            echo ""
        fi
    }
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}" >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits "$latest_tag")

    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since the last tag.${NC}"
        exit 0
    fi

    echo -e "${GREEN}Generating CHANGELOG.md...${NC}"

    if [ -n "$latest_tag" ]; then
        echo -e "${GREEN}Found latest tag: $latest_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi

    generate_changelog "$latest_tag" "$commits" > CHANGELOG.md

    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

main "$@"