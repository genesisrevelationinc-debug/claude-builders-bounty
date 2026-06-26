#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")

# Get the latest tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%H|%s|%b" --no-merges
    else
        git log --pretty=format:"%H|%s|%b" --no-merges
    fi
}

# Categorize a commit message into one of: Added, Fixed, Changed, Removed
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "Removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize)'; then
        echo "Changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new|support|enable)\b'; then
            echo "Added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch|correct|repair)\b'; then
            echo "Fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted|deprecate|deprecated)\b'; then
            echo "Removed"
        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked|optimize|optimized)\b'; then
            echo "Changed"
        else
            echo "Changed"  # Default category
        fi
    fi
}

# Extract issue/PR references from commit message
extract_references() {
    local msg="$1"
    echo "$msg" | grep -oE '#[0-9]+' | sort -u | tr '\n' ' ' | sed 's/ $//'
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No new commits found since last tag."
        exit 0
    fi

    # Prepare categorized commit lists
    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS='|' read -r hash subject body; do
        [ -z "$hash" ] && continue

        local full_msg="$subject"
        [ -n "$body" ] && full_msg="$full_msg $body"

        local category
        category=$(categorize_commit "$full_msg")

        local refs
        refs=$(extract_references "$full_msg")

        local line="- $subject"
        [ -n "$refs" ] && line="$line ($refs)"

        case "$category" in
            Added)   added="$added$line\n" ;;
            Fixed)   fixed="$fixed$line\n" ;;
            Changed) changed="$changed$line\n" ;;
            Removed) removed="$removed$line\n" ;;
        esac
    done <<< "$commits"

    # Build the changelog content
    local version_date
    version_date=$(date +%Y-%m-%d)

    local version_label
    if [ -n "$latest_tag" ]; then
        version_label="[Unreleased] — since $latest_tag"
    else
        version_label="[Unreleased]"
    fi

    {
        echo "## $version_label — $version_date"
        echo ""
        [ -n "$added" ]   && echo "### Added"   && echo -e "$added"   && echo ""
        [ -n "$changed" ] && echo "### Changed" && echo -e "$changed" && echo ""
        [ -n "$fixed" ]   && echo "### Fixed"   && echo -e "$fixed"   && echo ""
        [ -n "$removed" ] && echo "### Removed" && echo -e "$removed" && echo ""
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated successfully!"
    echo ""
    echo "Preview:"
    echo "---"
    cat "$CHANGELOG_FILE"
    echo "---"
}

# Main execution
generate_changelog