#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_URL="${REPO_URL:-}"
OUTPUT_FILE="${OUTPUT_FILE:-CHANGELOG.md}"

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
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
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement)'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "Removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|deps)'; then
        echo "Changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
            echo "Added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|resolves|bug|patch)\b'; then
            echo "Fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|reverted)\b'; then
            echo "Removed"
        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
            echo "Changed"
        else
            echo "Changed"  # Default fallback
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

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
            Added)  added="${added}- ${commit}"$'\n' ;;
            Fixed)  fixed="${fixed}- ${commit}"$'\n' ;;
            Changed) changed="${changed}- ${commit}"$'\n' ;;
            Removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"

    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""
        [ -n "$added" ] && echo "### Added"$'\n'"$added"
        [ -n "$fixed" ] && echo "### Fixed"$'\n'"$fixed"
        [ -n "$changed" ] && echo "### Changed"$'\n'"$changed"
        [ -n "$removed" ] && echo "### Removed"$'\n'"$removed"
    } > "$OUTPUT_FILE"

    echo "✅ Generated $OUTPUT_FILE"
}

generate_changelog