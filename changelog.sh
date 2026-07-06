#!/usr/bin/env bash

# changelog.sh — Generate a structured CHANGELOG.md from git history
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

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -z "$tag" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
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
    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade)'; then
        echo "changed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "removed"
    # Check for keywords in the message body
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(change|changed|changing|update|updated|updating|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
        echo "changed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted|deprecate|deprecated)\b'; then
        echo "removed"
    else
        echo "changed"  # Default category
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    echo -e "${GREEN}Generating CHANGELOG...${NC}"
    
    if [ -z "$latest_tag" ]; then
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    else
        echo -e "${GREEN}Latest tag: $latest_tag${NC}"
    fi
    
    local commits
    commits=$(get_commits_since_tag "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${YELLOW}No commits found since last tag.${NC}"
        exit 0
    fi
    
    # Categorize commits
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
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [Unreleased] - $DATE"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf -- "- %s\n" "${added[@]}"
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf -- "- %s\n" "${changed[@]}"
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf -- "- %s\n" "${fixed[@]}"
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf -- "- %s\n" "${removed[@]}"
            echo ""
        fi
    } > "$OUTPUT_FILE"
    
    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
    echo -e "${GREEN}  Location: $(pwd)/$OUTPUT_FILE${NC}"
}

# Main execution
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not a git repository.${NC}"
        exit 1
    fi
    
    generate_changelog
}

main "$@"