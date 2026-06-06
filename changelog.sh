#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#        ./changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────
CATEGORIES=("Added" "Changed" "Fixed" "Removed")
CHANGELOG_FILE="CHANGELOG.md"

# ── Helpers ────────────────────────────────────────────────────────

get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since() {
    local since_tag="$1"
    if [[ -n "$since_tag" ]]; then
        git log "${since_tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

get_date() {
    date +%Y-%m-%d
}

get_next_version() {
    local last_tag="$1"
    if [[ -z "$last_tag" ]]; then
        echo "v0.1.0"
        return
    fi

    # Strip leading 'v' if present
    local version="${last_tag#v}"

    # Try to bump patch version (e.g., 1.2.3 -> 1.2.4)
    if [[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        local major="${BASH_REMATCH[1]}"
        local minor="${BASH_REMATCH[2]}"
        local patch="${BASH_REMATCH[3]}"
        echo "v${major}.${minor}.$((patch + 1))"
    else
        # Fallback: append .1
        echo "${last_tag}.1"
    fi
}

categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower_msg" in
        *"add"* | *"feat"* | *"feature"* | *"implement"* | *"introduce"* | *"new "*)
            echo "Added"
            ;;
        *"fix"* | *"bugfix"* | *"bug fix"* | *"patch"* | *"resolve"* | *"hotfix"* | *"correct"*)
            echo "Fixed"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"* | *"clean"*)
            echo "Removed"
            ;;
        *"update"* | *"change"* | *"refactor"* | *"improve"* | *"enhance"* | *"modify"* | *"rework"*)
            echo "Changed"
            ;;
        *)
            echo "Changed"
            ;;
    esac
}

# ── Main ───────────────────────────────────────────────────────────

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

    local version
    version=$(get_next_version "$last_tag")
    local release_date
    release_date=$(get_date)

    # Build changelog entry
    {
        echo "## [${version}] - ${release_date}"
        echo ""
        for cat in "${CATEGORIES[@]}"; do
            echo "### ${cat}"
            echo "$commits" | while IFS= read -r commit; do
                local category
                category=$(categorize_commit "$commit")
                if [[ "$category" == "$cat" ]]; then
                    echo "- ${commit}"
                fi
            done
            echo ""
        done
    } >> "$CHANGELOG_FILE"

    echo "CHANGELOG updated: ${CHANGELOG_FILE}"
}

main "$@"
# Generate Changelog Skill

## Description
Automatically generate a structured `CHANGELOG.md` from git history.

## Usage
Run the following command in your terminal:

