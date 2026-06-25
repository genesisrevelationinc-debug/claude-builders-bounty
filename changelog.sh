#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
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
        *"add"* | *"feat"* | *"feature"* | *"implement"* | *"introduce"* | *"new "**)
            echo "Added"
            ;;
        *"fix"* | *"bugfix"* | *"patch"* | *"resolve"* | *"hotfix"* | *"correct"* | *"repair"*)
            echo "Fixed"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"* | *"clean"* | *"purge"*)
            echo "Removed"
            ;;
        *"change"* | *"update"* | *"refactor"* | *"rework"* | *"improve"* | *"modify"* | *"enhance"* | *"upgrade"*)
            echo "Changed"
            ;;
        *)
            echo "Changed"
            ;;
    esac
}

# Generate the changelog
generate_changelog() {
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

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            Added) added="${added}- ${commit}"$'\n' ;;
            Fixed) fixed="${fixed}- ${commit}"$'\n' ;;
            Changed) changed="${changed}- ${commit}"$'\n' ;;
            Removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""

        if [ -n "$added" ]; then
            echo "### Added"; echo ""; echo -n "$added"; echo ""
        fi
        if [ -n "$changed" ]; then
            echo "### Changed"; echo ""; echo -n "$changed"; echo ""
        fi
        if [ -n "$fixed" ]; then
            echo "### Fixed"; echo ""; echo -n "$fixed"; echo ""
        fi
        if [ -n "$removed" ]; then
            echo "### Removed"; echo ""; echo -n "$removed"; echo ""
        fi
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated at $CHANGELOG_FILE"
}

generate_changelog
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

**What it does:**
- Fetches commits since the last git tag
- Auto-categorizes commits into: `Added`, `Fixed`, `Changed`, `Removed`
- Outputs a properly formatted `CHANGELOG.md`

**Usage:**
