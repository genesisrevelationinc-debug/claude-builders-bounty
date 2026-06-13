#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────
CHANGELOG_FILE="CHANGELOG.md"
CATEGORIES=("Added" "Fixed" "Changed" "Removed")

# ── Helpers ─────────────────────────────────────────────────────────
error() { echo "❌ $1" >&2; exit 1; }
info()  { echo "ℹ️  $1"; }

# ── Find the latest tag ──────────────────────────────────────────────
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

# ── Get commits since a given ref ──────────────────────────────────
get_commits_since() {
    local ref="$1"
    if [[ -z "$ref" ]]; then
        # No tags exist: use all commits
        git log --pretty=format:"%s" --no-merges
    else
        git log "${ref}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

# ── Categorize a single commit message ─────────────────────────────
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Removed
    if [[ "$lower" =~ ^(remove|delete|drop|revert|deprecat) ]]; then
        echo "Removed"
        return
    fi

    # Fixed
    if [[ "$lower" =~ ^(fix|bug|repair|correct|resolve|patch) ]]; then
        echo "Fixed"
        return
    fi

    # Changed
    if [[ "$lower" =~ ^(update|upgrade|refactor| changelog|improve|modify|change|bump|deps) ]]; then
        echo "Changed"
        return
    fi

    # Added (default)
    echo "Added"
}

# ── Format a commit line for CHANGELOG ──────────────────────────────
format_commit() {
    local msg="$1"
    # Strip common prefixes like "feat:", "fix:", "chore:" etc.
    local clean
    clean=$(echo "$msg" | sed -E 's/^[a-zA-Z]+(\([^)]*\))?:[[:space:]]*//')
    # Capitalize first letter
    clean="$(tr '[:lower:]' '[:upper:]' <<< "${clean:0:1}")${clean:1}"
    echo "- $clean"
}

# ── Main ────────────────────────────────────────────────────────────
main() {
    # Must be in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not a git repository. Please run from inside a git repo."
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local version_label
    if [[ -n "$latest_tag" ]]; then
        version_label="$latest_tag → HEAD"
        info "Found latest tag: $latest_tag"
    else
        version_label="Initial Release"
        info "No tags found. Using all commits."
    fi

    # Read commits
    local commits
    commits=$(get_commits_since "$latest_tag")

    if [[ -z "$commits" ]]; then
        info "No new commits since $latest_tag."
        exit 0
    fi

    # Build new changelog section
    local date_str
    date_str=$(date +%Y-%m-%d)

    {
        echo "## [$version_label] - $date_str"
        echo ""
        for cat in "${CATEGORIES[@]}"; do
            echo "### $cat"
            echo ""
            echo "$commits" | while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                local cat_name
                cat_name=$(categorize_commit "$line")
                if [[ "$cat_name" == "$cat" ]]; then
                    format_commit "$line"
                fi
            done
            echo ""
        done
    } >> "$CHANGELOG_FILE"

    info "CHANGELOG updated at $CHANGELOG_FILE"
}

main "$@"

--- /dev/null
# Skill: Generate Changelog

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag, auto-categorizes them into
`Added`, `Fixed`, `Changed`, and `Removed`, and appends a properly formatted
section to `CHANGELOG.md`.

### Usage

Run inside any git repository:

