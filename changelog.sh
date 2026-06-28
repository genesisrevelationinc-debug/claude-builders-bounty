#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"

# Get the latest git tag, or empty if none exists
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
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "Removed"
    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "Changed"
    # Check for keywords in the message body
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|bugfix|resolve|resolved|patch|patches)\b'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|deprecate|deprecated|revert|reverted)\b'; then
        echo "Removed"
    elif echo "$lower_msg Portions of the previous thinking were redacted to prevent the output from being cut off. The full thinking continues below.
    else
        echo "Changed"
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local tag
    tag=$(get_latest_tag)

    local commits
    if [ -n "$tag" ]; then
        commits=$(get_commits_since_tag "$tag")
    else
        commits=$(git log --pretty=format:"%s" 2>/dev/null || true)
    fi

    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi

    # Categorize commits
    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            Added)   added="$added- $commit"$'\n' ;;
            Fixed)   fixed="$fixed- $commit"$'\n' ;;
            Changed) changed="$changed- $commit"$'\n' ;;
            Removed) removed="$removed- $commit"$'\n' ;;
        esac
    done <<< "$commits"

    # Build the changelog
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        if [ -n "$tag" ]; then
            echo "## Unreleased (since $tag)"
        else
            echo "## Unreleased"
        fi
        echo ""

        [ -n "$added" ]   && { echo "### Added"; echo ""; echo -n "$added"; echo ""; }
        [ -n "$changed" ] && { echo "### Changed"; echo ""; echo -n "$changed"; echo ""; }
        [ -n "$fixed" ]   && { echo "### Fixed"; echo ""; echo -n "$fixed"; echo ""; }
        [ -n "$removed" ] && { echo "### Removed"; echo ""; echo -n "$removed"; echo ""; }

        echo "---"
        echo ""
        echo "*Generated automatically by changelog.sh*"
    } > "$CHANGELOG_FILE"

    echo "CHANGELOG.md generated successfully at $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog