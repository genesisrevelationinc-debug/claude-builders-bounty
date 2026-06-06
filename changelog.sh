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
        git log "${last_tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
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
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|repair|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate|clean)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize)'; then
        echo "changed"
    # Check for keywords in the message
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bugfix|hotfix|patch|repair|resolve|resolved|resolving)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|eliminate|deprecate)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked|optimize|optimized)\b'; then
        echo "changed"
    else
        echo "changed"  # Default category
    fi
}

# Generate the changelog
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    echo -e "${GREEN}Generating CHANGELOG.md...${NC}"
    
    if [ -n "$last_tag" ]; then
        echo -e "${YELLOW}Last tag found: $last_tag${NC}"
    else
        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
    fi
    
    local commits
    commits=$(get_commits "$last_tag")
    
    if [ -z "$commits" ]; then
        echo -e "${RED}No commits found since last tag.${NC}"
ur        exit 0
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
        
        case "$category" in
            added) added+=("- $commit") ;;
            fixed) fixed+=("- $commit") ;;
            removed) removed+=("- $commit") ;;
            changed) changed+=("- $commit") ;;
        esac
    done <<< "$commits"
    
    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [Unreleased] - $(date +%Y-%m-%d)"
        echo ""
        
        # Output categories
        [ ${#added[@]} -gt 0 ] && { echo "### Added"; printf '%s\n' "${added[@]}"; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "### Changed"; printf '%s\n' "${changed[@]}"; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed"; printf '%s\n' "${fixed[@]}"; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "### Removed"; printf '%s\n' "${removed[@]}"; echo ""; }
        
    } > CHANGELOG.md
    
    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
}

# Main execution
generate_changelog
# Generate Changelog Skill

## Description
Automatically generate a structured `CHANGELOG.md` from a project's git history.

## Usage
Run `/generate-changelog` in Claude Code to execute this skill.

## Command
