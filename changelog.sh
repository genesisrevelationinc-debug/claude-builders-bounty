#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_URL=""
CHANGELOG_FILE="CHANGELOG.md"

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given tag (or all commits if no tag)
get_commits_since() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
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
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|upgrade|deps)'; then
        echo "changed"
    # Check for keywords in message
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|feat)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|bugfix|resolve|resolves|resolved|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|reverts)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|modify|modified|refactor|refactored|improve|improved|upgrade|upgraded|deps)\b'; then
        echo "changed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local tag_for_header="$latest_tag"
    if [ -z "$tag_for_header" ]; then
        tag_for_header="previous release"
    fi
    
    # Get commits
    local commits
    commits=$(get_commits_since "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo "No commits found since $tag_for_header."
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
            added)  added="${added}- ${commit}"$'\n' ;;
            fixed)  fixed="${fixed}- ${commit}"$'\n' ;;
            removed) removed="${removed}- ${commit}"$'\n' ;;
            changed) changed="${changed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"
    
    # Build changelog
    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] — since $tag_for_header"
        echo ""
        
        [ -n "$added" ] && echo "### Added" && echo "" && echo -n "$added" && echo ""
        [ -n "$changed" ] && echo "### Changed" && echo "" && echo -n "$changed" && echo ""
        [ -n "$fixed" ] && echo "### Fixed" && echo "" && echo -n "$fixed" && echo ""
        [ -n "$removed" ] && echo "### Removed" && echo "" && echo -n "$removed" && echo ""
    } > "$CHANGELOG_FILE"
    
    echo "✅ Generated $CHANGELOG_FILE with commits since $tag_for_header"
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository."
        exit 1
    fi
    
    generate_changelog
}

main "$@"

# Generate Changelog Skill

Automatically generate a structured `CHANGELOG.md` from your project's git history.

## Usage

