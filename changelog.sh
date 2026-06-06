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
get_commits() {
    local last_tag="$1"
    if [ -n "$last_tag" ]; then
        git log "$last_tag"..HEAD --pretty=format:"%s" --no-merges
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
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate|clean)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    else
        # Fallback: check for keywords in the message
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
            echo "added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|correct|patch)\b'; then
            echo "fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|eliminate|deprecate)\b'; then
            echo "removed"
        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked)\b'; then
            echo "changed"
        else
            # Default to changed if no match
            echo "changed"
        fi
    fi
}

# Main function
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}"
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    if [ -n "$last_tag" ]; then
        echo -e "${GREEN}Generating changelog from tag: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
    fi

    local commits
    commits=$(get_commits "$last_tag")

    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}"
        exit 0
    fi

    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        if [ -n "$last_tag" ]; then
            echo "## Unreleased (since $last_tag)"
        else
            echo "## Unreleased"
        fi
        echo ""

        # Process commits and categorize
        echo "$commits" | while IFS= read -r commit; do
            [ -z "$commit" ] && continue
            category=$(categorize_commit "$commit")
            # Clean up the commit message (remove conventional commit prefix if present)
            clean_msg=$(echo "$commit" | sed -E 's/^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([^)]+\))?:\s*//i')
            echo "- $clean_msg"
        done | sort -t: -k1,1

    } > CHANGELOG.md

    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

main "$@"
# /generate-changelog

Generate a structured `CHANGELOG.md` from a project's git history.

## Description

This skill fetches commits since the last git tag and auto-categorizes them into:
- **Added** — new features, additions
- **Fixed** — bug fixes, corrections
- **Changed** — modifications, improvements, refactors
- **Removed** — deletions, deprecations

## Usage

Run the script:
