#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
REPO_URL=""

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message into a section
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^(feat|add|introduce|implement|create|new) ]]; then
        echo "added"
        return
    fi
    
    if [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve|correct|repair) ]]; then
        echo "fixed"
        return
    fi
    
    if [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|clean|deprecate|revert) ]]; then
        echo "removed"
        return
    fi
    
    if [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize|style|docs|test|chore|build|ci|perf) ]]; then
        echo "changed"
        return
    fi
    
    # Fallback: check for keywords anywhere in the message
    if [[ "$lower_msg" =~ (fix|bug|issue|crash|error|broken|repair) ]]; then
        echo "fixed"
        return
    fi
    
    if [[ "$lower_msg" =~ (add|support|enable|introduce|implement) ]]; then
        echo "added"
        return
    fi
    
    if [[ "$lower_msg" =~ (remove|delete|drop|eliminate|deprecate) ]]; then
        echo "removed"
        return
    fi
    
    # Default to changed
    echo "changed"
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local since_text
    if [ -n "$latest_tag" ]; then
        since_text="since $latest_tag"
    else
        since_text="(all commits)"
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
            added)   added+=("- $commit") ;;
            fixed)   fixed+=("- $commit") ;;
            changed) changed+=("- $commit") ;;
            removed) removed+=("- $commit") ;;
        esac
    done < <(get_commits_since_tag "$latest_tag")
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project $since_text."
        echo ""
        
        [ ${#added[@]} -gt 0 ] && { echo "## Added"; printf "%s\n" "${added[@]}"; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "## Fixed"; printf "%s\n" "${fixed[@]}"; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "## Changed"; printf "%s\n" "${changed[@]}"; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "## Removed"; printf "%s\n" "${removed[@]}"; echo ""; }
        
    } > "$CHANGELOG_FILE"
    
    echo "✅ Generated $CHANGELOG_FILE with commits $since_text"
}

# Main
generate_changelog
# /generate-changelog

Generate a structured `CHANGELOG.md` from git history.

## Usage

