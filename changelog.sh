#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"

# Get the latest git tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "$tag..HEAD" --pretty=format:"%s" --no-merges
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
    if echo "$lower" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|eliminate|deprecate)'; then
        echo "removed"
    elif echo "$lower" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|rework)'; then
        echo "changed"
    # Then check for keywords in the message
    elif echo "$lower" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "added"
    elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|bug|bugfix|resolve|resolves|resolved|patch|patches)\b'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|eliminate|deprecate|deprecated)\b'; then
        echo "removed"
    elif echo "$lower" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked)\b'; then
        echo "changed"
    else
        echo "changed"  # Default category
    fi
}

# Generate the changelog
generate_changelog() {
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    # Read commits into array
    local commits
    commits=$(get_commits)

    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi

    # Categorize each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added)  added+=("$commit") ;;
            fixed)  fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done <<< "$commits"

    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [Unreleased] — $(date +%Y-%m-%d)"
        echo ""

        print_section() {
            local title="$1"
            shift
            local arr=("$@")
            if [ ${#arr[@]} -gt 0 ]; then
                echo "### $title"
                echo ""
                for item in "${arr[@]}"; do
                    echo "- $item"
                done
                echo ""
            fi
        }

        print_section "Added" "${added[@]}"
        print_section "Changed" "${changed[@]}"
        print_section "Fixed" "${fixed[@]}"
        print_section "Removed" "${removed[@]}"
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated at $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Usage

Run the following command in Claude Code:

