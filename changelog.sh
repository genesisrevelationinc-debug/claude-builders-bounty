#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag..HEAD" --pretty=format:"%s" 2>/dev/null || true
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
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
        return
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
        return
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style)(\(.+\))?: ]]; then
        echo "changed"
        return
    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
        echo "removed"
        return
    fi
    
    # Fallback to keyword matching
    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|support) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bug|resolve|patch|correct|repair) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|purge) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the CHANGELOG.md
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
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""
        
        [ -n "$added" ]   && { echo "### Added";   echo ""; echo -n "$added";   echo ""; }
        [ -n "$fixed" ]   && { echo "### Fixed";   echo ""; echo -n "$fixed";   echo ""; }
        [ -n "$changed" ] && { echo "### Changed";  echo ""; echo -n "$changed";  echo ""; }
        [ -n "$removed" ] && { echo "### Removed";  echo ""; echo -n "$removed";  echo ""; }
    } > CHANGELOG.md
    
    echo "CHANGELOG.md generated successfully!"
}

# Main
generate_changelog
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Setup

1. Save `changelog.sh` to your project root
2. Make it executable: `chmod +x changelog.sh`
3. Run: `bash changelog.sh`

## Usage

