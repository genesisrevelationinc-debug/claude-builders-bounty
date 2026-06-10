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

# Get commits since the last tag (or all commits if no tag exists)
get_commits() {
    local last_tag="$1"
    if [ -n "$last_tag" ]; then
        git log "${last_tag}..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || echo ""
    else
        git log --pretty=format:"%s" --no-merges 2>/dev/null || echo ""
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
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|repair|resolve|patch)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate|clean)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    # Check for keywords in the message
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|introducing|implement|implementing|create|creating|new)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|resolving|repair|repairing|patch|patched|bug)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|dropping|deprecate|deprecating|clean|cleaning)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|refactoring|improve|improved|improving|enhance|enhanced|enhancing|upgrade|upgraded|upgrading|rework|reworked|reworking)\b'; then
        echo "changed"
    else
        # Default to changed if no clear category
        echo "changed"
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local last_tag="$1"
    local commits="$2"
    local version_date
    version_date=$(date +%Y-%m-%d)
    
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Process each commit
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
    
    # Output the changelog
    echo "# Changelog"
    echo ""
    echo "## [Unreleased] - ${version_date}"
    echo ""
    
    if [ ${#added[@]} -gt 0 ]; then
        echo "### Added"
        printf '%s\n' "${added[@]}"
        echo ""
    fi
    
    if [ ${#fixed[@]} -gt 0 ]; then
        echo "### Fixed"
        printf '%s\n' "${fixed[@]}"
        echo ""
    fi
    
    if [ ${#changed[@]} -gt 0 ]; then
        echo "### Changed"
        printf '%s\n' "${changed[@]}"
        echo ""
    fi
    
    if [ ${#removed[@]} -gt 0 ]; then
        echo "### Removed"
        printf '%s\n' "${removed[@]}"
        echo ""
    fi
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository${NC}" >&2
        exit 1
    fi
    
    local last_tag
    last_tag=$(get_last_tag)
    
    if [ -n "$last_tag" ]; then
        echo -e "${GREEN}Generating changelog from tag: $last_tag${NC}" >&2
    else
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}" >&2
    fi
    
    local commits
    commits=$(get_commits "$last_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}" >&2
        exit 0
    fi
    
    # Generate and write changelog
    generate_changelog "$last_tag" "$commits" > CHANGELOG.md
    
    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}" >&2
}

main "$@"