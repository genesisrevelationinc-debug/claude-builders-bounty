#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        *"fix"* | *"bugfix"* | *"hotfix"* | *"patch"*)
            echo "Fixed"
            ;;
        *"add"* | *"feat"* | *"feature"* | *"introduce"* | *"implement"*)
            echo "Added"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"*)
            echo "Removed"
            ;;
        *"update"* | *"change"* | *"refactor"* | *"improve"* | *"optimize"* | *"rework"*)
            echo "Changed"
            ;;
        *)
            # Default based on conventional commit prefixes
            if echo "$msg" | grep -qiE "^feat(\(.+\))?:"; then
                echo "Added"
            elif echo "$msg" | grep -qiE "^fix(\(.+\))?:"; then
                echo "Fixed"
            elif echo "$msg" | grep -qiE "^refactor(\(.+\))?:"; then
                echo "Changed"
            elif echo "$msg" | grep -qiE "^remove(\(.+\))?:"; then
                echo "Removed"
            else
                echo "Changed"
            fi
            ;;
    esac
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local tag
    tag=$(get_latest_tag)

    local commits
    commits=$(get_commits "$tag")

    if [ -z "$commits" ]; then
        echo "No commits found since the last tag."
        exit 0
    fi

    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        cat=$(categorize "$line")
        case "$cat" in
            Added)   added="${added}- ${line}"$'\n' ;;
            Fixed)   fixed="${fixed}- ${line}"$'\n' ;;
            Changed) changed="${changed}- ${line}"$'\n' ;;
            Removed) removed="${removed}- ${line}"$'\n' ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""
        [ -n "$added" ]   && echo "### Added"$'\n'"$added"
        [ -n "$fixed" ]   && echo "### Fixed"$'\n'"$fixed"
        [ -n "$changed" ] && echo "### Changed"$'\n'"$changed"
        [ -n "$removed" ] && echo "### Removed"$'\n'"$removed"
    } > "$CHANGELOG_FILE"

    echo "Generated $CHANGELOG_FILE"
}

main "$@"
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

