#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the latest git tag, or use empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" --
    else
        git log --pretty=format:"%s" --
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
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
            echo "added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
            echo "fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|eliminate)\b'; then
            echo "removed"
        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked)\b'; then
            echo "changed"
        else
            # Default to changed if no match
            echo "changed"
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    local date_str
    date_str=$(date +%Y-%m-%d)

    # Initialize category arrays
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    # Process each commit
    while IFS= read -r commit_msg; do
        [ -z "$commit_msg" ] && continue

        local category
        category=$(categorize_commit "$commit_msg")

        case "$category" in
            added)   added+=("$commit_msg") ;;
            fixed)   fixed+=("$commit_msg") ;;
            changed) changed+=("$commit_msg") ;;
            removed) removed+=("$commit_msg") ;;
        esac
    done < <(get_commits)

    # Write changelog header
    {
        echo "# Changelog"
        echo ""
        if [ -n "$tag" ]; then
            echo "## [Unreleased] — since $tag ($date_str)"
        else
            echo "## [Unreleased] — $date_str"
        fi
        echo ""
    } > "$TEMP_FILE"

    # Write each section if it has entries
    [ ${#added[@]} -gt 0 ] && { echo "### Added" >> "$TEMP_FILE"; for item in "${added[@]}"; do echo "- $item" >> "$TEMP_FILE"; done; echo "" >> "$TEMP_FILE"; }
    [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed" >> "$TEMP_FILE"; for item in "${fixed[@]}"; do echo "- $item" >> "$TEMP_FILE"; done; echo "" >> "$TEMP_FILE"; }
    [ ${#changed[@]} -gt 0 ] && { echo "### Changed" >> "$TEMP_FILE"; for item in "${changed[@]}"; do echo "- $item" >> "$TEMP_FILE"; done; echo "" >> "$TEMP_FILE"; }
    [ ${#removed[@]} -gt 0 ] && { echo "### Removed" >> "$TEMP_FILE"; for item in "${removed[@]}"; do echo "- $item" >> "$TEMP_FILE"; done; echo "" >> "$TEMP_FILE"; }

    # Move temp file to final location
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "✅ Generated $CHANGELOG_FILE"
}

# Main execution
generate_changelog