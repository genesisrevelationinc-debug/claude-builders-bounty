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
        git log "${tag}..HEAD" --pretty=format:"%H|%s|%b" --reverse
    else
        git log --pretty=format:"%H|%s|%b" --reverse
    fi
}

# Categorize a commit based on its message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "Removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|deps)'; then
        echo "Changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new|support|enable)\b'; then
            echo "Added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch|correct|repair)\b'; then
            echo "Fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted|deprecate)\b'; then
            echo "Removed"
        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|bump|bumped)\b'; then
            echo "Changed"
        else
            echo "Changed"  # Default category
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local version_label
    if [ -n "$latest_tag" ]; then
        version_label="## [Unreleased] — since ${latest_tag}"
    else
        version_label="## [Unreleased]"
    fi
    
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Read commits
    while IFS='|' read -r hash subject body; do
        [ -z "$subject" ] && continue
        
        local category
        category=$(categorize_commit "$subject")
        
        # Clean up the commit message (remove conventional commit prefix if present)
        local clean_subject
        clean_subject=$(echo "$subject" | sed -E 's/^[a-z]+(\([^)]*\))?:\s*//i')
        
        case "$category" in
            "Added") added+=("- $clean_subject") ;;
            "Fixed") fixed+=("- $clean_subject") ;;
            "Changed") changed+=("- $clean_subject") ;;
            "Removed") removed+=("- $clean_subject") ;;
        esac
    done < <(get_commits_since "$latest_tag")
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "$version_label"
        echo ""
        
        [ ${#added[@]} -gt 0 ] && { echo "### Added"; printf '%s\n' "${added[@]}"; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed"; printf '%s\n' "${fixed[@]}"; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "### Changed"; printf '%s\n' "${changed[@]}"; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "### Removed"; printf '%s\n' "${removed[@]}"; echo ""; }
        
        echo "---"
        echo ""
        echo "*Generated automatically by [changelog.sh](changelog.sh)*"
    } > "$CHANGELOG_FILE"
    
    echo "✅ CHANGELOG.md generated successfully!"
}

generate_changelog