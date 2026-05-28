#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes or keywords
    if echo "$lower" | grep -qE '^(feat|add|create|introduce|implement)'; then
        echo "added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|dep|bump)'; then
        echo "changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
            echo "added"
        elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|bug|resolve|solved|correct|patch)\b'; then
            echo "fixed"
        elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|reverted)\b'; then
            echo "removed"
        elif echo "$lower" | grep -qE '\b(update|updated|updating|change|changed|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
            echo "changed"
        else
            echo "changed"  # default fallback
        fi
    fi
}

# Main generation logic
generate_changelog() {
    local tag
    tag=$(get_latest_tag)

    local commits
    commits=$(get_commits "$tag")

    if [ -z "$commits" ]; then
        echo "No new commits found since tag: ${tag:-'(none)'}"
        exit 0
    fi

    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local category
        category=$(categorize_commit "$line")
        case "$category" in
            added)  added="${added}- ${line}"$'\n' ;;
            fixed)  fixed="${fixed}- ${line}"$'\n' ;;
            changed) changed="${changed}- ${line}"$'\n' ;;
            removed) removed="${removed}- ${line}"$'\n' ;;
        esac
    done <<< "$commits"

    # Build the changelog entry
    local version_label
    version_label="${tag:-previous release}"

    {
        echo "## [Unreleased] — ${DATE}"
        echo ""
        echo "### Added"
        echo -n "${added:-'- No new features added.'}"
        echo ""
        echo "### Changed"
        echo -n "${changed:-'- No changes made.'}"
        echo ""
        echo "### Fixed"
        echo -n "${fixed:-'- No fixes applied.'}"
        echo ""
        echo "### Removed"
        echo -n "${removed:-'- No removals.'}"
        echo ""
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG generated at $CHANGELOG_FILE"
}

generate_changelog