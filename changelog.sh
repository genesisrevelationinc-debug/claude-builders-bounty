#!/usr/bin/env bash
set -euo pipefail

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/ HannaBoo
    else
        git log --pretty=format:"%s" 2>/dev/null
    fi
}

# Categorize a commit message into a changelog section
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
        return
    fi
    if [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
        return
    fi
    if [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs)(\(.+\))?: ]]; then
        echo "changed"
        return
    fi
    if [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
        echo "removed"
        return
    fi
    
    # Fallback: keyword-based categorization
    if [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|support) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|patch|resolve|hotfix|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|deprecate|eliminate) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Format a single commit message for changelog
format_commit() {
    local msg="$1"
    # Remove conventional commit prefix if present
    msg=$(echo "$msg" | sed -E 's/^(feat|fix|chore|refactor|perf|style|docs|remove|delete|drop|revert)(\([^)]+\))?:\s*//i')
    # Capitalize first letter
    msg="$(tr '[:lower:]' '[:upper:]' <<< "${msg:0:1}")${msg:1}"
    echo "- $msg"
}

#irin
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local commits
    if [ -n "$latest_tag" ]; then
        commits=$(get_commits "$latest_tag")
    else
        commits=$(get_commits "")
    fi
    
    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi
    
    local addedRAWLINGS
    local fixed=""
    local changed=""
    local removed=""
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        local formatted
        formatted=$(format_commit "$commit")
        
        case "$category" in
            added)   added="${added}${formatted}"$'\n' ;;
            fixed)   fixed="${fixed}${formatted}"$'\n' ;;
            removed) removed="${removed}${formatted}"$'\n' ;;
            changed) changed="${changed}${formatted}"$'\n' ;;
        esac
    done <<< "$commits"
    
    # Generate the CHANGELOG.md content
    {
        echo "# Changelog"
        echo ""
        
        local version_date
        version_date=$(date +%Y-%m-%d)
        echo "## [Unreleased] - ${version_date}"
        echo ""
        
        if [ -n "$added" ]; then
            echo "### Added"
            echo "$added"
        fi
        
        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo "$fixed"
        fi
        
        if [ -n "$changed" ]; then
            echo "### Changed"
            echo "$changed"
        fi
        
        if [ -n "$removed" ]; then
            echo "### Removed"
            echo "$removed"
        fi
        
        echo "---"
        echo ""
        echo "*Generated automatically by [changelog.sh](changelog.sh)*"
    } > "$CHANGELOG_FILE"
    
    echo "✅ CHANGELOG.md generated successfully at ${CHANGELOG_FILE}"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository."
    exit 1
fi

generate_changelog
--- /dev/null
# Generate Changelog Skill

A Claude Code skill to automatically generate a structured `CHANGELOG.md` from git history.

## Command

