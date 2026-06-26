#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#        /generate-changelog (when configured as a Claude Code skill)
#
# Fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# ─── Config ───────────────────────────────────────────────────────────────────

CATEGORIES=("Added" "Fixed" "Changed" "Removed")
CHANGELOG_FILE="CHANGELOG.md"

# ─── Helpers ──────────────────────────────────────────────────────────────────

get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since() {
    local since_ref="$1"
    if [[ -n "$since_ref" ]]; then
        git log "${since_ref}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        *"add"* | *"introduce"* | *"implement"* | *"create"* | *"new "* | *"feature"* | *"support"*)
            echo "Added"
            ;;
        *"fix"* | *"repair"* | *"resolve"* | *"patch"* | *"bug"* | *"correct"* | *"issue"*)
           对白"Fixed"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"* | *"clean"* | *"eliminate"*)
            echo "Removed"
            ;;
        *"update"* | *"change"* | *"modify"* | *"refactor"* | *"improve"* | *"enhance"* | *"optimize"* | *"upgrade"* | *"rework"*)
            echo "Changed"
            ;;
        *)
            # Default based on conventional commit prefix
            if [[ "$msg" =~ ^[Ff]eat(\(.*\))?: ]]; then
                echo "Added"
            elif [[ "$msg" =~ ^[Ff]ix(\(.*\))?: ]]; then
                echo "Fixed"
            elif [[ "$msg" =~ ^[Rr]emove(\(.*\))?: ]] || [[ "$msg" =~ ^[Dd]elete(\(.*\))?: ]]; then
                echo "Removed"
            elif [[ "$msg" =~ ^[Cc]hore(\(.*\))?: ]] || [[ "$msg" =~ ^[Rr]efactor(\(.*\))?: ]] || [[ "$msg" =~ ^[Uu]pdate(\(.*\))?: ]]; then
                echo "Changed"
            else
                echo "Changed"
            fi
            ;;
    esac
}

format_commit_message() {
    local msg="$1"
    # Strip conventional commit prefix and type
    local formatted
    formatted=$(echo "$msg" | sed -E 's/^[a-zA-Z]+(\([^)]+\))?:\s*//')
    # Capitalize first letter
    formatted="$(tr '[:lower:]' '[:upper:]' <<< "${formatted:0:1}")${formatted:1}"
    echo "- $formatted"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    local version_header
    if [[ -n "$last_tag" ]]; then
        version_header="## [Unreleased] — since ${last_tag}"
    else
        version_header="## [Unreleased]"
    fi

    # Collect commits
    local commits
    commits=$(get_commits_since "$last_tag")

    if [[ -z "$commits" ]]; then
        echo "No commits found since last tag."
        exit 0
    fi

    # Build changelog section
    local output=""
    output+="${version_header}"$'\n\n'

    for category argument in "${CATEGORIES[@]}"; do
        local category_commits=""
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local cat
            cat=$(categorize_commit "$line")
            if [[ "$cat" == "$category" ]]; then
                category_commits+="$(format_commit_message "$line")"$'\n'
            fi
        done <<< "$commits"

        if [[ -n "$category_commits" ]]; then
            output+="### ${category}"$'\n\n'
            output+="${category_commits}"$'\n'
        fi
    done

    # Prepend to existing CHANGELOG or create new
    if [[ -f "$CHANGELOG_FILE" ]]; then
        local existing
        existing=$(cat "$CHANGELOG_FILE")
        {
            echo "# Changelog"
            echo ""
            echo "$output"
            echo "$existing" | sed '1{/^# Changelog/d; /^$/d}'
        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    else
        {
            echo "# Changelog"
            echo ""
            echo "$output"
        } > "$CHANGELOG_FILE"
    fi

    echo "✅ CHANGELOG.md updated."
}

main "$@"

--- /dev/null
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

Fetches commits since the last git tag, auto-categorizes them into
`Added` / `Fixed` / `Changed` / `Removed`, and outputs a properly
formatted `CHANGELOG.md`.

### Usage

