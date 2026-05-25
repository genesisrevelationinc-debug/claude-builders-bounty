#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
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
    if [[ "$lower_msg" =~ ^(feat|add|introduce|implement|create|new): ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve|correct): ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|deprecate|revert): ]]; then
        echo "removed"
    elif [[ "$lower_msg" =~ ^(change|update|modify|refactor|improve|enhance|upgrade|chore|docs|style|test|build|ci|perf): ]]; then
        echo "changed"
    # Fallback keyword matching
    elif [[ "$lower_msg" =~ (add|adds|added|adding|feature|feat|introduce|implement|create|new) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ (fix|fixes|fixed|fixing|bug|bugfix|resolve|resolves|resolved|correct|corrects|patch|patches) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ (remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|deprecate|deprecates|deprecated|revert|reverts|reverted) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    
    local commits
    commits=$(get_commits_since_tag "$tag")
    
    if [ -z "$commits" ]; then
        echo "No commits found since the last tag."
        exit 0
    fi
    
    local added=""
    local fixed=""
    local changed=""
    local removed=""
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        
        case "$category" in
            added)   added="${added}- ${commit}"$'\n' ;;
            fixed)   fixed="${fixed}- ${commit}"$'\n' ;;
            changed) changed="${changed}- ${commit}"$'\n' ;;
            removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"
    
    # Write changelog
    {
        echo "# Changelog"
        echo ""
        echo "## Unreleased"
        [ -n "$tag" ] && echo "Changes since $tag:"
        echo ""
        
        if [ -n "$added" ]; then
            echo "### Added"
            echo -n "$added"
            echo ""
        fi
        if [ -n "$changed" ]; then
            echo "### Changed"
            echo -n "$changed"
            echo ""
        fi
        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo -n "$fixed"
            echo ""
        fi
        if [ -n "$removed" ]; then
            echo "### Removed"
            echo -n "$removed"
            echo ""
        fi
    } > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "✅ Generated $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository."
    exit 1
fi

generate_changelog
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

