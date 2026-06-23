#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Get the latest tag, or use empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -z "$tag" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message into a section
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "Added"
        return
    fi
    
    if echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "Fixed"
        return
    fi
    
    if echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "Removed"
        return
    fi
    
    if echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize)'; then
        echo "Changed"
        return
    fi
    
    # Fallback: keyword-based detection
    if echo "$lower_msg" | grep -qE '\b(add|adds|added|adding|feature|feat|introduce|implement|create)\b'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixes|fixed|fixing|bug|bugfix|resolve|resolves|solved|patch)\b'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|deprecate|revert)\b'; then
        echo "Removed"
    else
        echo "Changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local version_date
    version_date=$(date +%Y-%m-%d)
    
    # Determine version string
    local version_str
    if [ -n "$latest_tag" ]; then
        version_str="[Unreleased] — since ${latest_tag}"
    else
        version_str="[Unreleased]"
    fi
    
    # Collect commits
    local commits
    commits=$(get_commits_since_tag "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo "No new commits found since ${latest_tag:-the beginning}."
        exit 0
    fi
    
    # Categorize commits
    local added=""
    local fixed=""
    local changed=""
    local removed=""
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        
        case "$category" in
            Added)   added="${added}- ${commit}"$'\n' ;;
            Fixed)   fixed="${fixed}- ${commit}"$'\n' ;;
            Changed) changed="${changed}- ${commit}"$'\n' ;;
            Removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"
    
    # Build changelog entry
    {
        echo "## ${version_str} — ${version_date}"
        echo ""
        
        [ -n "$added" ]   && { echo "### Added"; echo ""; echo -n "$added"; echo ""; }
        [ -n "$changed" ] && { echo "### Changed"; echo ""; echo -n "$changed"; echo ""; }
        [ -n "$fixed" ]   && { echo "### Fixed"; echo ""; echo -n "$fixed"; echo ""; }
        [ -n "$removed" ] && { echo "### Removed"; echo ""; echo -n "$removed"; echo ""; }
    } > "$TEMP_FILE"
    
    # Prepend to existing CHANGELOG or create new one
    if [ -f "$CHANGELOG_FILE" ]; then
        {
            echo "# Changelog"
            echo ""
            cat "$TEMP_FILE"
            # Remove old header if present and append rest
            tail -n +3 "$CHANGELOG_FILE" | sed 's/^# Changelog$//' | sed '/^$/N;/^\n$/d'
        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    else
        {
            echo "# Changelog"
            echo ""
            cat "$TEMP_FILE"
        } > "$CHANGELOG_FILE"
    fi
    
    echo "✅ CHANGELOG.md generated successfully!"
    if [ -n "$latest_tag" ]; then
        echo "   Includes commits since tag: $latest_tag"
    else
        echo "   Includes all commits (no previous tags found)"
    fi
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository."
    exit 1
fi

generate_changelog
--- /dev/null
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from git history.

## Usage

