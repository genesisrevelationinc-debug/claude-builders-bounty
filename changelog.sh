#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: ./changelog.sh
#        /generate-changelog (when used as a Claude Code skill)
#
# Fetches commits since the last git tag, auto-categorizes them,
# and appends a new version section to CHANGELOG.md.
#

set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────
CATEGORIES=("Added" "Fixed" "Changed" "Removed")
OUTPUT_FILE="CHANGELOG.md"

# ── Helpers ─────────────────────────────────────────────────────────
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since_tag() {
    local tag="$1"
    if [[ -n "$tag" ]]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

get_commit_date() {
    local tag="$1"
    if [[ -n "$tag" ]]; then
        git log -1 --format=%cd --date=short "${tag}"
    else
        git log -1 --format=%cd --date=short
    fi
}

categorize_commit() {
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
            # Default based on conventional commit prefix
            if [[ "$msg" =~ ^[[:space:]]*feat(\(.+\))?: ]]; then
                echo "Added"
            elif [[ "$msg" =~ ^[[:space:]]*fix(\(.+\))?: ]]; then
                echo "Fixed"
            elif [[ "$msg" =~ ^[[:space:]]*refactor(\(.+\))?: ]]; then
                echo "Changed"
            elif [[ "$msg" =~ ^[[:space:]]*docs(\(.+\))?: ]]; then
                echo "Changed"
            elif [[ "$msg" =~ ^[[:space:]]*style(\(.+\))?: ]]; then
                echo "Changed"
            elif [[ "$msg" =~ ^[[:space:]]*perf(\(.+\))?: ]]; then
                echo "Changed"
            elif [[ "$msg" =~ ^[[:space:]]*chore(\(.+\))?: ]]; then
                echo "Changed"
            else
                echo "Changed"
            fi
            ;;
    esac
}

# ── Main ────────────────────────────────────────────────────────────
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

    if [[ -z "$commits" ]]; then
        echo "No new commits since tag: ${latest_tag:-'(none)'}" >&2
        exit 0
    fi

    local version_date
    version_date=$(date +%Y-%m-%d)

    local new_version
    if [[ -n "$latest_tag" ]]; then
        # Simple version bump: assume tags are like v1.0.0
        new_version="${latest_tag}-next"
    else
        new_version="v0.0.1"
    fi

    # Build changelog section
    local section=""
    section+="## [${new_version}] - ${version_date}"$'\n\n'

    for cat in "${CATEGORIES[@]}"; do
        local cat_commits
        cat_commits=$(echo "$commits" | while IFS= read -r line; do
            [[ -n "$line" ]] || continue
            local cat_name
            cat_name=$(categorize_commit "$line")
            [[ "$cat_name" == "$cat" ]] && echo "- $line"
        done)

        if [[ -n "$cat_commits" ]]; then
            section+="### ${cat}"$'\n\n'
            section+="${cat_commits}"$'\n\n'
        fi
    done

    # Prepend to existing CHANGELOG or create new one
    if [[ -f "$OUTPUT_FILE" ]]; then
        local existing
        existing=$(cat "$OUTPUT_FILE")
        {
            echo "# Changelog"
            echo ""
            echo "$section"
            echo "$existing" | sed '1,/^# Changelog/d'
        } > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    else
        {
            echo "# Changelog"
            echo ""
            echo "$section"
        } > "$OUTPUT_FILE"
    fi

    echo "✅ CHANGELOG updated: $OUTPUT_FILE"
}

main "$@"