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
        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|new|introduce|implement)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade)'; then
        echo "changed"
    # Check for keywords in message
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|reverted)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
        echo "changed"
    else
        echo "changed"  # Default category
    fi
}

# Main function
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}" >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    if [ -n "$last_tag" ]; then
        echo -e "${YELLOW}Generating changelog since tag: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
    fi

    # Collect commits by category
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
            removed) removed+=("$commit") ;;
            changed) changed+=("$commit") ;;
        esac
    done < <(get_commits_since_tag "$last_tag")

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
        
        # Added
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        # Fixed
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        # Changed
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        # Removed
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        # Previous releases reference
        if [ -n "$last_tag" ]; then
            echo "---"
            echo ""
            echo "For previous releases, see git tags."
            echo ""
        fi
    } > CHANGELOG.md

    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
    
    # Show preview
    echo ""
    echo "Preview:"
    echo "--------"
    head -30 CHANGELOG.md
}

main "$@"