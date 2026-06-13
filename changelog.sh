#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Get the date range for the changelog entry
get_date_range() {
    local tag
    tag=$(get_latest_tag)
    local start_date
    if [ -n "$tag" ]; then
        start_date=$(git log -1 --format=%ad --date=short "$tag" 2>/dev/null || echo "")
    else
        start_date=$(git log --reverse --format=%ad --date=short | head -n 1)
    fi
    local end_date
    end_date=$(git log -1 --format=%ad --date=short HEAD 2>/dev/null || date +%Y-%m-%d)
    echo "$start_date to $end_date"
}

# Get the version for the changelog entry
get_version() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        echo "$tag"
    else
        echo "unreleased"
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
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|deprecate|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|chore|style|docs|test|build|ci|perf)'; then
        echo "changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
            echo "added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|resolves|resolved|patch)\b'; then
            echo "fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted)\b'; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local version
    version=$(get_version)
    local date_str
    date_str=$(date +%Y-%m-%d)
    
    # Initialize category arrays
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Process commits
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        
        case "$category" in
            added) added+=("$commit") ;;
            fixed) fixed+=("$commit") ;;
            removed) removed+=("$commit") ;;
            changed) changed+=("$commit") ;;
        esac
    done < <(get_commits)
    
    # Generate output
    {
        echo "# Changelog"
        echo ""
        echo "## [$version] - $date_str"
        echo ""
        
        [ ${#added[@]} -gt 0 ] && { echo "### Added"; for c in "${added[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "### Changed"; for c in "${changed[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed"; for c in "${fixed[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "### Removed"; for c in "${removed[@]}"; do echo "- $c"; done; echo ""; }
    } > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "✅ CHANGELOG.md generated successfully!"
}

everywhere

# Run
generate_changelog