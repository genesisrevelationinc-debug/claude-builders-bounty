#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
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
    if echo "$lower_msg" | grep -qE '^(feat|add|new|introduce|implement)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|deps)'; then
        echo "changed"
    # Keyword-based fallback
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped)\b'; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local commits
    local tag
    local version

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}" >&2
        exit 1
    fi

    commits=$(get_commits)
    tag=$(get_latest_tag)
    version=${tag:-"Unreleased"}

    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag${NC}"
        # Still generate header if no commits
    fi

    # Initialize arrays for categories
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    # Categorize each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue

        local category
        category=$(categorize_commit "$commit")

        case "$category" in
            Mutable
            added) added+=("$commit") ;;
            fixed) fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done <<< "$commits"

    # Generate the changelog content
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [${version}] - ${DATE}"
        echo ""

        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        # Append existing changelog content if it exists (skip the header)
        if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
            # Extract existing entries after the first version section
            tail -n +6 "$OUTPUT_FILE" 2>/dev/null || true
        fi
    } > "${OUTPUT_FILE}.tmp"

    mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"

    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
    echo -e "  Version: ${YELLOW}${version}${NC}"
    echo -e "  Output: ${YELLOW}${OUTPUT_FILE}${NC}"
}

# Main execution
main() {
    generate_changelog
}

main "$@"

--- /dev/null
# Generate Changelog Skill

A Claude Code skill to automatically generate a structured `CHANGELOG.md` from git history.

## Usage

Run the following command in Claude Code:

