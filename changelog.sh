#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given ref (or all commits if no ref)
get_commits_since() {
    local ref="$1"
    if [ -n "$ref" ]; then
        git log "${ref}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a commit message into a section
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        *"add"* | *"feat"* | *"feature"* | *"introduce"* | *"implement"* | *"new "*)
            echo "Added"
            ;;
        *"fix"* | *"bugfix"* | *"patch"* | *"resolve"* | *"hotfix"* | *"correct"*)
            echo "Fixed"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"*)
            echo "Removed"
            ;;
        *"change"* | *"update"* | *"refactor"* | *"rework"* | *"improve"* | *"modify"* | *"enhance"*)
            echo "Changed"
            ;;
        *)
            echo "Changed"
            ;;
    esac
}

# Escape special characters for sed
escape_for_sed() {
    echo "$1" | sed 's/[\/&]/\\&/g'
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No new commits since last tag."
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
            Added)   added="${added}- ${line}"$'\n' ;;
            Fixed)   fixed="${fixed}- ${line}"$'\n' ;;
            Changed) changed="${changed}- ${line}"$'\n' ;;
            Removed) removed="${removed}- ${line}"$'\n' ;;
        esac
    done <<< "$commits"

    {
        echo "## [Unreleased] - ${DATE}"
        echo ""
        if [ -n "$added" ];   then echo "### Added";   echo "$added";   fi
        if [ -n "$changed" ]; then echo "### Changed"; echo "$changed"; fi
        if [ -n "$fixed" ];   then echo "### Fixed";   echo "$fixed";   fi
        if [ -n "$removed" ]; then echo "### Removed"; echo "$removed"; fi
    } > /tmp/new_changelog_section.md

    if [ -f "$CHANGELOG_FILE" ]; then
        cat /tmp/new_changelog_section.md > /tmp/updated_changelog.md
        echo "" >> /tmp/updated_changelog.md
        cat "$CHANGELOG_FILE" >> /tmp/updated_changelog.md
        mv /tmp/updated_changelog.md "$CHANGELOG_FILE"
    else
        mv /tmp/new_changelog_section.md "$CHANGELOG_FILE"
    fi

    echo "CHANGELOG.md updated successfully."
}

main "$@"

--- /dev/null
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

**When to use:** Before releasing a new version, or when you need to document recent changes.

**Prerequisites:** Git repository with at least one commit.

**Steps:**

1. Run the changelog generator:
   