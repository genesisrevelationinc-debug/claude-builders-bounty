#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#        ./changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them,
# and outputs/updates CHANGELOG.md.
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

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local last_tag="$1"
    if [ -n "$last_tag" ]; then
        git log "$last_tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
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
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|deps)'; then
        echo "changed"
    # Keyword-based fallback
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|patch|resolve|resolves|resolved)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted)\b'; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Main
main() {
    # Check if we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}" >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    echo -e "${YELLOW}Generating changelog...${NC}"
    if [ -n "$last_tag" ]; then
        echo -e "Last tag: ${GREEN}$last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi

    local commits
    commits=$(get_commits "$last_tag")

    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}"
        exit 0
    fi

    # Categorize commits
    local added="" fixed="" changed="" removed=""
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added)   added="$added- $commit"$'\n' ;;
            fixed)   fixed="$fixed- $commit"$'\n' ;;
            removed) removed="$removed- $commit"$'\n' ;;
            changed) changed="$changed- $commit"$'\n' ;;
        esac
    done <<< "$commits"

    # Build CHANGELOG.md
    local today
    today=$(date +%Y-%m-%d)
    local version=""
    if [ -n "$last_tag" ]; then
        version=" ($last_tag → HEAD)"
    fi

    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project are documented in this file."
        echo ""
        echo "## [Unreleased]$version — $today"
        echo ""
        if [ -n "$added" ]; then
            echo "### Added"
            echo ""
            echo -n "$added"
            echo ""
        fi
        if [ -n "$changed" ]; then
            echo "### Changed"
            echo ""
            echo -n "$changed"
            echo ""
        fi
        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo ""
            echo -n "$fixed"
            echo ""
        fi
        if [ -n "$removed" ]; then
            echo "### Removed"
            echo ""
            echo -n "$removed"
            echo ""
        fi
    } > CHANGELOG.md

    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

main "$@"

# Skill: Generate Changelog

Generate a structured `CHANGELOG.md` from a project's git history.

## /generate-changelog

Run the changelog generator script to create or update `CHANGELOG.md`.

### Usage

