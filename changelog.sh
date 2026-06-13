#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the latest tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        *"add"* | *"feat"* | *"new "* | *"introduce"* | *"implement"* | *"create"*)
            echo "added"
            ;;
        *"fix"* | *"bugfix"* | *"patch"* | *"resolve"* | *"hotfix"* | *"correct"*)
            echo "fixed"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"* | *"clean"*)
            echo "removed"
            ;;
        *"update"* | *"change"* | *"refactor"* | *"improve"* | *"modify"* | *"rework"* | *"enhance"* | *"upgrade"* | *"revert"*)
            echo "changed"
            ;;
        *)
            # Default categorization based on conventional commit prefixes
            if echo "$lower" | grep -qE "^(feat|feature|add)"; then
                echo "added"
            elif echo "$lower" | grep -qE "^(fix|bugfix|hotfix|patch)"; then
                echo "fixed"
            elif echo "$lower" | grep -qE "^(remove|delete|drop|deprecate)"; then
                echo "removed"
            elif echo "$lower" | grep -qE "^(chore|docs|style|test|build|ci|perf|refactor)"; then
                echo "changed"
            else
                echo "changed"
            fi
            ;;
    esac
}

# Main generation
generate_changelog() {
    local tag
    tag=$(get_latest_tag)

    local commits
    commits=$(get_commits)

    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi

    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local cat
        cat=$(categorize "$line")
        case "$cat" in
            added)   added="${added}- ${line}"$'\n' ;;
            fixed)   fixed="${fixed}- ${line}"$'\n' ;;
            changed) changed="${changed}- ${line}"$'\n' ;;
            removed) removed="${removed}- ${line}"$'\n' ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - ${DATE}"
        echo ""

        [ -n "$added" ]   && echo "### Added" && echo "$added" && echo ""
        [ -n "$changed" ] && echo "### Changed" && echo "$changed" && echo ""
        [ -n "$fixed" ]   && echo "### Fixed" && echo "$fixed" && echo ""
        [ -n "$removed" ] && echo "### Removed" && echo "$removed" && echo ""
    } > "$CHANGELOG_FILE"

    echo "Generated $CHANGELOG_FILE"
}

generate_changelog