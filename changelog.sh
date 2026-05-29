#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage:
#   bash changelog.sh
#
# This script fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since() {
    local since="$1"
    if [[ -z "$since" ]]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges "${since}..HEAD"
    fi
}

categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Added
    if echo "$lower" | grep -qE '^(feat|add|create|introduce|implement|new)|\b(add|adds|added|adding|create|creates|created|creating|implement|implements|implemented|implementing|introduce|introduces|introduced|introducing|feature|features|feat)\b'; then
        echo "Added"
        return
    fi

    # Fixed
    if echo "$lower" | grep -qE '^(fix|fixes|fixed|fixing|patch|patches|patched|patching|resolve|resolves|resolved|resolving|bug|bugfix|hotfix)|\b(fix|fixes|fixed|fixing|bug|bugfix|hotfix|patch|patches|patched|patching|resolve|resolves|resolved|resolving)\b'; then
        echo "Fixed"
        return
    fi

    # Removed
    if echo "$lower" | grep -qE '^(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|dropping|clean|cleanup|deprecate|deprecates|deprecated|deprecating)|\b(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|dropping|clean|cleanup|deprecate|deprecates|deprecated|deprecating)\b'; then
        echo "Removed"
        return
    fi

    # Changed (default)
    echo "Changed"
}

# ── Main ───────────────────────────────────────────────────────────────────

main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    local commits
    commits=$(get_commits_since "$last_tag")

    if [[ -z "$commits" ]]; then
        echo "No commits found since last tag."
        exit 0
    fi

    local version_date
    version_date=$(date +%Y-%m-%d)

    local version_header
    if [[ -n "$last_tag" ]]; then
        version_header="## [Unreleased] — $version_date"
    else
        version_header="## [Unreleased] — $version_date"
    fi

    # Build changelog body
    local added="" fixed="" changed="" removed=""

    while IFS= read -r commit; do
        [[ -z "$commit" ]] && continue
        local category
        category=$(categorize_commit "$commit")
        local line="- $commit"
        case "$category" in
            Added)   added+=$'\n'"$line" ;;
            Fixed)   fixed+=$'\n'"$line" ;;
            Removed) removed+=$'\n'"$line" ;;
            Changed) changed+=$'\n'"$line" ;;
        esac
    done <<< "$commits"

    # Trim leading newlines
    added=$(echo "$added" | sed '/^$/d')
    fixed=$(echo "$fixed" | sed '/^$/d')
    changed=$(echo "$changed" | sed '/^$/d')
    removed=$(echo "$removed" | sed '/^$/d')

    # Generate output
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "$version_header"
        echo ""

        if [[ -n "$added" ]]; then
            echo "### Added"
            echo "$added"
            echo ""
        fi

        if [[ -n "$changed" ]]; then
            echo "### Changed"
            echo "$changed"
            echo ""
        fi

        if [[ -n "$fixed" ]]; then
            echo "### Fixed"
            echo "$fixed"
            echo ""
        fi

        if [[ -n "$removed" ]]; then
            echo "### Removed"
            echo "$removed"
            echo ""
        fi
    } > CHANGELOG.md

    echo "CHANGELOG.md generated successfully."
}

main "$@"
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

