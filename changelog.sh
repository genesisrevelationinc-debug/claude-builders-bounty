#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"

# Get the latest git tag; if none, use the first commit
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD 2>/dev/null || echo ""
}

# Get commits since the latest tag
get_commits_since_tag() {
    local tag="$1"
    if [ -z "$tag" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes and keywords
    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce|implement)'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "Removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|bump)'; then
        echo "Changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|new|introduce|implement|create|feature)\b'; then
            echo "Added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|resolved|correct|patch)\b'; then
            echo "Fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|deprecated)\b'; then
            echo "Removed"
        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|bump|bumped)\b'; then
            echo "Changed"
        else
            echo "Changed"  # Default category
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No new commits found since ${latest_tag:-the beginning}."
        exit 0
    fi

    local version_date
    version_date=$(date +%Y-%m-%d)

    # Initialize category arrays
    local added=() fixed=() changed=() removed=()

    # Process each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            Added) added+=("$commit") ;;
            Fixed) fixed+=("$commit") ;;
            Changed) changed+=("$commit") ;;
            Removed) removed+=("$commit") ;;
        esac
    done <<< "$commits"

    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - ${version_date}"
        echo ""

        # Output each category
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        # Append existing changelog content if it exists (excluding header)
        if [ -f "$CHANGELOG_FILE" ]; then
            tail -n +3 "$CHANGELOG_FILE" 2>/dev/null || true
        fi
    } > "${CHANGELOG_FILE}.tmp"

    mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    echo "CHANGELOG.md generated successfully!"
}

# Main
generate_changelog
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

