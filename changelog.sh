#!/usr/bin/env bash
set -euo pipefail

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given tag (or all commits if no tag)
get_commits_since() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Get the date of the latest tag (or repo creation date)
get_since_date() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log -1 --format=%ai "$tag" 2>/dev/null || echo ""
    else
        echo ""
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
    elif [[ "$lower_msg" =~ ^(remove|delete|revert)(\(.+\))?: ]]; then
        echo "removed"
    else
        # Fallback to keyword matching
        case "$lower_msg" in
            *"add"* | *"implement"* | *"introduce"* | *"create"* | *"new "*)
                echo "added"
                ;;
            *"fix"* | *"resolve"* | *"patch"* | *"bug"* | *"correct"*)
                echo "fixed"
                ;;
            *"remove"* | *"delete"* | *"revert"* | *"drop"*)
                echo "removed"
                ;;
            *"update"* | *"change"* | *"modify"* | *"improve"* | *"enhance"* | *"optimize"*)
                echo "changed"
                ;;
            *)
                echo "changed"
                ;;
        esac
    fi
}

# Main function
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi

    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added) added+=("$commit") ;;
            fixed) fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - $(date +%Y-%m-%d)"
        echo ""

        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
    } > "$CHANGELOG_FILE"

    echo "CHANGELOG.md generated successfully at $CHANGELOG_FILE"
}

main "$@"
# Generate Changelog Skill

A Claude Code skill to generate a structured `CHANGELOG.md` from git history.

## Usage

Run the following command in Claude Code:

