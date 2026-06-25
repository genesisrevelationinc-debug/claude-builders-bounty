#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the latest git tag
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

# Get the date range for the changelog header
get_date_info() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        echo "Changes since ${tag} ($(git log -1 --format=%ai "$tag" | cut -d' ' -f1) to $(date +%Y-%m-%d))"
    else
        echo "All changes (generated on $(date +%Y-%m-%d))"
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|dep)'; then
        echo "changed"
    # Check for keywords in the message body
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|revert)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|modify|modified|refactor|improve|improved|enhance|upgrade)\b'; then
        echo "changed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local commits
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    # Read commits into array
    mapfile -t commits < <(get_commits)

    if [ ${#commits[@]} -eq 0 ] || [ -z "${commits[0]}" ]; then
        echo "No commits found since last tag."
        exit 0
    fi

    # Categorize each commit
    for commit in "${commits[@]}"; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added)  added+=("$commit") ;;
            fixed)  fixed+=("$commit") ;;
            removed) removed+=("$commit") ;;
            changed) changed+=("$commit") ;;
        esac
    done

    # Write changelog
    {
        echo "# Changelog"
        echo ""
        echo "## $(get_date_info)"
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
        print_section "Changed" "${changed[@]}"
        print_section "Fixed" "${fixed[@]}"
        print_section "Removed" "${removed[@]}"
    } > "$TEMP_FILE"

    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "✅ CHANGELOG.md generated successfully!"
}

# Main execution
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag and auto-categorizes them into:
- **Added** — new features, files, or capabilities
- **Fixed** — bug fixes and issue resolutions
- **Changed** — updates, improvements, refactors, and modifications
- **Removed** — deleted features, files, or deprecated functionality

### Usage

Run the script from any git repository:

