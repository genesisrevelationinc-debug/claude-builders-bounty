#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

# Get commits since the last tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || true
    else
        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test|build|ci|revert)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|deprecate)(\(.+\))?: ]]; then
        echo "removed"
    else
        # Fallback: keyword-based categorization
        if [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|support|enable) ]]; then
            echo "added"
        elif [[ "$lower_msg" =~ ^(fix|bugfix|resolve|patch|hotfix|correct|repair) ]]; then
            echo "fixed"
        elif [[ "$lower_msg" =~ ^(remove|delete|drop|deprecate|eliminate|clean) ]]; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Clean commit message for display
clean_message() {
    local msg="$1"
    # Remove conventional commit prefix
    msg=$(echo "$msg" | sed -E 's/^(feat|fix|chore|refactor|perf|style|docs|test|build|ci|revert)(\([^)]+\))?:\s*//i')
    # Capitalize first letter
    msg="$(tr '[:lower:]' '[:upper:]' <<< "${msg:0:1}")${msg:1}"
    echo "$msg"
}

# Generate the changelog
generate_changelog() {
    local tag
    tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$tag")

    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi

    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        local clean_msg
        clean_msg=$(clean_message "$commit")

        case "$category" in
            added)   added+=("$clean_msg") ;;
            fixed)   fixed+=("$clean_msg") ;;
            removed) removed+=("$clean_msg") ;;
            changed) changed+=("$clean_msg") ;;
        esac
    done <<< "$commits"

    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""

        local categories=("Added" "Fixed" "Changed" "Removed")
        local -n arr
        for cat in "${categories[@]}"; do
            arr="${cat,,}s[@]"
            if [ ${#arr} -gt 0 ]; then
                echo "### $cat"
                printf -- '- %s\n' "${!cat}"
                echo ""
            fi
        done
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated at: $CHANGELOG_FILE"
}

generate_changelog
# Generate Changelog Skill

A Claude Code skill to generate a structured `CHANGELOG.md` from git history.

## Usage

Run the following command in Claude Code:

