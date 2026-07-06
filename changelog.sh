#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_URL=""
CHANGELOG_FILE="CHANGELOG.md"

# Get the last git tag; if none, use the first commit
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD 2>/dev/null || echo ""
}

# Get commits since the last tag
get_commits_since_tag() {
    local since="$1"
    if [ -z "$since" ]; then
        git log --pretty=format:"%H|%s" --no-merges
    else
        git log --pretty=format:"%H|%s" --no-merges "${since}..HEAD"
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
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
        echo "removed"
    # Fallback to keyword matching
    elif [[ "$lower_msg" =~ (add|new|introduce|implement|create|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ (fix|bug|resolve|patch|correct|repair) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ (remove|delete|drop|revert|clean) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Format a single commit line
format_commit() {
    local hash="$1"
    local msg="$2"
    local short_hash
    short_hash=$(echo "$hash" | cut -c1-7)
    echo "- ${msg} ([${short_hash}](${REPO_URL}/commit/${hash}))"
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    local version
    if [ -n "$last_tag" ] && git rev-parse "$last_tag" > /dev/null 2>&1; then
        version="$last_tag"
    else
        version="Unreleased"
    fi

    local date_str
    date_str=$(date +%Y-%m-%d)

    # Collect commits
    local commits
    commits=$(get_commits_since_tag "$last_tag")

    if [ -z "$commits" ]; then
        echo "No commits found since ${version}."
        exit 0
    fi

    # Build changelog sections
    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS='|' read -r hash msg; do
        [ -z "$hash" ] && continue
        local category
        category=$(categorize_commit "$msg")
        local formatted
        formatted=$(format_commit "$hash" "$msg")

        case "$category" in
            added)  added="${added}${formatted}"$'\n' ;;
            fixed)  fixed="${fixed}${formatted}"$'\n' ;;
            changed) changed="${changed}${formatted}"$'\n' ;;
            removed) removed="${removed}${formatted}"$'\n' ;;
        esac
    done <<< "$commits"

    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [${version}] - ${date_str}"
        echo ""

        if [ -n "$added" ]; then
            echo "### Added"
            echo ""
            echo -n "$added"
            echo ""
        fi

        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo ""
            echo -n "$fixed"
            echo ""
        fi

        if [ -n "$changed" ]; then
            echo "### Changed"
            echo ""
            echo -n "$changed"
            echo ""
        fi

        if [ -n "$removed" ]; then
            echo "### Removed"
            echo ""
            echo -n "$removed"
            echo ""
        fi
    } > "$CHANGELOG_FILE"

    echo "Generated ${CHANGELOG_FILE} for version ${version} (${date_str})"
}

main "$@"

--- /dev/null
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

