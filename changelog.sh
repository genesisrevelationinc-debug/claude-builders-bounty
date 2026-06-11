#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [[ -n "$tag" ]]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^(feat|add|introduce|implement|create|new) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve|close) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean) ]]; then
        echo "removed"
    elif [[ "$lower_msg" =~ ^(change|update|modify|refactor|improve|enhance|upgrade|rework) ]]; then
        echo "changed"
    else
        # Fallback: keyword matching anywhere in the message
        if [[ "$lower_msg" =~ (added|adds|adding|new feature|new ) ]]; then
            echo "added"
        elif [[ "$lower_msg" =~ (fixed|fixes|fixing|bug fix|resolved|resolves|patch) ]]; then
            echo "fixed"
        elif [[ "$lower_msg" =~ (removed|removes|removing|deleted|deletes|dropped|dropping) ]]; then
            echo "removed"
        elif [[ "$lower_msg" =~ (changed|changes|changing|updated|updates|updating|refactored|refactoring|improved|improving|modified|modifying|enhanced|enhancing) ]]; then
            echo "changed"
        else
            # Default to changed if no match
            echo "changed"
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local tag
    tag=$(get_latest_tag)

    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [[ -z "$commit" ]] && continue

        local category
        category=$(categorize_commit "$commit")

        case "$category" in
            added)   added+=("$commit") ;;
            fixed)   fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done < <(get_commits)

    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        if [[ -n "$tag" ]]; then
            echo "## Changes since $tag"
        else
            echo "## Changes"
        fi
        echo ""

        if [[ ${#added[@]} -gt 0 ]]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        if [[ ${#fixed[@]} -gt 0 ]]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        if [[ ${#changed[@]} -gt 0 ]]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        if [[ ${#removed[@]} -gt 0 ]]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated at $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog