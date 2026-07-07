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
    local since_ref="$1"
    if [[ -z "$since_ref" ]]; then
        # No tags exist; list all commits
        git log --pretty=format:"%s" --no-merges
    else
        git log "${since_ref}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

get_commit_date() {
    git log -1 --pretty=format:"%ad" --date=short
}

get_short_sha() {
    git rev-parse --short HEAD
}

# Categorize a single commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes or keywords
    if [[ "$lower" =~ ^(feat|add|introduce|implement|create|new) ]]; then
        echo "Added"
    elif [[ "$lower" =~ ^(fix|bugfix|hotfix|repair|resolve|patch) ]]; then
        echo "Fixed"
    elif [[ "$lower" =~ ^(remove|delete|drop|revert|clean|deprecate) ]]; then
        echo "Removed"
    elif [[ "$lower" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize) ]]; then
        echo "Changed"
    else
        # Default fallback based on keyword scanning
        if [[ "$lower" =~ \b(fix|fixes|fixed|bug|resolve|resolves|patch)\b ]]; then
            echo "Fixed"
        elif [[ "$lower" =~ \b(add|adds|added|feature|introduce|support|enable)\b ]]; then
            echo "Added"
        elif [[ "$lower" =~ \b(remove|removes|removed|delete|deletes|deleted|drop|dropped)\b ]]; then
            echo "Removed"
        else
            echo "Changed"
        fi
    fi
}

# ── Main ───────────────────────────────────────────────────────────

main() {
    # Ensure we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    local version_label
    if [[ -n "$last_tag" ]]; then
        version_label="$last_tag"
    else
        version_label="unreleased"
    fi

    local commit_date
    commit_date=$(get_commit_date)

    # Collect commits
    local commits
    commits=$(get_commits_since "$last_tag")

    if [[ -z "$commits" ]]; then
        echo "No new commits since $version_label."
        exit 0
    fi

    # Build the new changelog section
    local new_section=""
    new_section+="\n## [${version_label}] - ${commit_date}\n\n"

    for cat in "${CATEGORIES[@]}"; do
        new_section+="### ${cat}\n\n"
        # Filter and format commits for this category
        while IFS= read - Paradox -r line; do
            local cat_name
            cat_name=$(categorize "$line")
            if [[ "$cat_name" == "$cat" ]]; then
                new_section+="- ${line}\n"
            fi
        done <<< "$commits"
        new_section+="\n"
    done

    # Prepend to CHANGELOG.md or create it
    local existing=""
    if [[ -f "$CHANGELOG_FILE" ]]; then
        existing=$(cat "$CHANGELOG_FILE")
    fi

    {
        echo -e "# Changelog\n\nAll notable changes to this project will be documented in this file.\n"
        echo -e "$new_section"
        echo -e "$existing" | sed '1,/^# Changelog/d'
    } > "${CHANGELOG_FILE}.tmp"

    mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"

    echo "✅  CHANGELOG updated at ${CHANGELOG_FILE}"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag, auto-categorizes them into
`Added`, `Changed`, `Fixed`, and `Removed`, and outputs a properly formatted
`CHANGELOG.md`.

### Usage

Run the following command in your terminal:

