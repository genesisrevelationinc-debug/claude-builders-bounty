#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"

# Get the latest git tag, or empty if none exists
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
    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate|clean)'; then
        echo "removed"
    # Check for keywords in the message body
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|solved|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(change|changed|update|updated|modify|modified|refactor|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
        echo "changed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|delete|deleted|drop|dropped|revert|reverted|deprecate|deprecated)\b'; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local tag
    tag=$(get_latest_tag)

    local commits
    commits=$(get_commits)

    if [ -z "$commits" ]; then
        echo "No commits found since the last tag."
        if [ -n "$tag" ]; then
            echo "Latest tag: $tag"
        fi
        exit 0
    fi

    local version_date
    version_date=$(date +%Y-%m-%d)

    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added)   added="$added- $commit"$'\n' ;;
            fixed)   fixed="$fixed- $commit"$'\n' ;;
            changed) changed="$changed- $commit"$'\n' ;;
            removed) removed="$removed- $commit"$'\n' ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - $version_date"
        echo ""
        [ -n "$added" ]   && echo "### Added"$'\n'"$added"
        [ -n "$changed" ] && echo "### Changed"$'\n'"$changed"
        [ -n "$fixed" ]   && echo "### Fixed"$'\n'"$fixed"
        [ -n "$removed" ] && echo "### Removed"$'\n'"$removed"
    } > "$CHANGELOG_FILE"

    echo "CHANGELOG.md generated successfully at $CHANGELOG_FILE"
}

generate_changelog
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

**What it does:**
- Fetches all commits since the last git tag
- Auto-categorizes commits into: Added / Fixed / Changed / Removed
- Writes a properly formatted `CHANGELOG.md`

**Usage:**
