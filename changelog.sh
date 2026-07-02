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

# ── Config ─────────────────────────────────────────────────────────
CATEGORIES=("Added" "Changed" "Fixed" "Removed")
CHANGELOG_FILE="CHANGELOG.md"

# ── Helpers ────────────────────────────────────────────────────────

# Get the latest git tag (empty if none)
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

# Get commits since a given ref (or all commits if no ref)
get_commits_since() {
    local ref="$1"
    if [[ -n "$ref" ]]; then
        git log "${ref}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if [[ "$lower" =~ ^feat(\(.+\))?: ]]; then
        echo "Added"
        return
    elif [[ "$lower" =~ ^fix(\(.+\))?: ]]; then
        echo "Fixed"
        return
    elif [[ "$lower" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
        echo "Changed"
        return
    elif [[ "$lower" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
        echo "Removed"
        return
    fi

    # Fallback: keyword-based heuristics
    if [[ "$lower" =~ (remove|delete|drop|clean|deprecate) ]]; then
        echo "Removed"
    elif [[ "$lower" =~ (fix|bug|patch|resolve|hotfix|repair|correct) ]]; then
        echo "Fixed"
    elif [[ "$lower" =~ (add|introduce|implement|create|new|support|enable) ]]; then
        echo "Added"
    else
        echo "Changed"
    fi
}

# Strip conventional commit prefix for cleaner changelog entries
clean_message() {
    local msg="$1"
    # Remove conventional commit prefixes like feat:, fix(scope):, etc.
    echo "$msg" | sed -E 's/^[a-zA-Z]+(\([^)]+\))?:[[:space:]]*//'
}

# ── Main ──────────────────────────────────────────────────────────

main() {
    # Ensure we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local version_label
    if [[ -n "$latest_tag" ]]; then
        version_label="$latest_tag"
    else
        version_label="Unreleased"
    fi

    # Read commits
    local commits
    commits=$(get_commits_since "$latest_tag")

    if [[ -z "$commits" ]]; then
        echo "No new commits since $version_label."
        exit 0
    fi

    # Build changelog section
    local date_str
    date_str=$(date +%Y-%m-%d)

    {
        echo ""
        echo "## [$version_label] - $date_str"
        echo ""
        for cat in "${CATEGORIES[@]}"; do
            echo "### $cat"
            # Filter and print commits for this category
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                local cat_name
                cat_name=$(categorize_commit "$line")
                if [[ "$cat_name" == "$cat" ]]; then
                    local clean
                    clean=$(clean_message "$line")
                    echo "- $clean"
                fi
            done <<< "$commits"
            echo ""
        done
    } >> "$CHANGELOG_FILE"

    echo "Appended changelog section to $CHANGELOG_FILE"
}

main "$@"

--- /dev/null
+# Changelog
+
+All notable changes to this project will be documented in this file.

--- /dev/null
# Skill: Generate Changelog

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag, auto-categorizes them into
`Added`, `Fixed`, `Changed`, and `Removed`, and appends a properly formatted
section to `CHANGELOG.md`.

### Usage

Run the included bash script:

