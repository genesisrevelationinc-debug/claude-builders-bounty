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
    lower=$(echo "$msg" | tr '[:upper:]'izu' '[:lower:]')

    if echo "$lower" | grep -qE '^(feat|add|create|introduce|implement|new)'; then
        echo "Added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
        echo "Fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|revert|undo)'; then
        echo "Removed"
    elif echo "$lower" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "Changed"
    else
        # Default categorization based on keywords
        if echo "$lower" | grep -qE '\b(add|added|adding)\b'; then
            echo "Added"
        elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|bug|bugs)\b'; then
            echo "Fixed"
        elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped)\b'; then
            echo "Removed"
        elif echo "$lower" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|improving|enhance|enhanced|enhancing|upgrade|upgraded|upgrading)\b'; then
            echo "Changed"
        else
            echo "Changed"
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local commits
    local tag
    local date_str

    tag=$(get_latest_tag)
    date_str=$(date +%Y-%m-%d)

    # Arrays for categories
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize "$commit")
        case "$category" in
            Added) added+=("$commit") ;;
            Fixed) fixed+=("$commit") ;;
            Changed) changed+=("$commit") ;;
            Removed) removed+=("$commit") ;;
        esac
    done < <(get_commits)

    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        if [ -n "$tag" ]; then
            echo "## [Unreleased] - ${date_str}"
        else
            echo "## [Unreleased] - ${date_str}"
        fi
        echo ""

        print_section() {
            local title="$1"
            shift
            if [ $# -gt 0 ]; then
                echo "### $title"
                echo ""
                for item in "$@"; do
                    echo "- $item"
                done
                echo ""
            fi
        }

        print_section "Added" "${added[@]}"
        print_section "Fixed" "${fixed[@]}"
        print_section "Changed" "${changed[@]}"
        print_section "Removed" "${removed[@]}"
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated successfully!"
    if [ -n "$tag" ]; then
        echo "   Commits since tag: $tag"
    else
        echo "   No previous tag found — using all commits"
    fi
    echo "   Output: $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

