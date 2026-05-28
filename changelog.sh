#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
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
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate|clean)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    # Fallback: keyword-based categorization
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|bugfix|resolve|resolved|correct|corrected|patch|patched)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|eliminate|deprecate|deprecated)\b'; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the CHANGELOG.md
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    
    if [ -n "$tag" ]; then
        echo -e "${GREEN}Generating changelog since tag: ${tag}${NC}"
    else
        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
    fi
    
    local commits
    commits=$(get_commits "$tag")
    
    if [ -z "$commits" ]; then
        echo -e "${RED}No commits found since the last tag.${NC}"
        exit 0
    fi
    
    # Initialize category arrays
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
    
    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""
        
        [ ${#added[@]} -gt 0 ] && { echo "### Added"; printf "%s\n" "${added[@]}"; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed"; printf "%s\n" "${fixed[@]}"; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "### Changed"; printf "%s\n" "${changed[@]}"; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "### Removed"; printf "%s\n" "${removed[@]}"; echo ""; }
    } > CHANGELOG.md
    
    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
}

# Main execution
generate_changelog
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Usage

