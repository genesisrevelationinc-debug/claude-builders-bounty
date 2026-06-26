#!/usr/bin/env bash
set -euo pipefail

# generate-changelog.sh
# Automatically generates a structured CHANGELOG.md from git history
# Fetches commits since the last git tag and auto-categorizes them.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo ""
    else
        git log --pretty=format:"%s" 2>/dev/null || echo ""
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
        return
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
        return
    elif [[ "$lower_msg" =~ ^(refactor|perf|style|build|ci|chore|docs|test)(\(.+\))?: ]]; then
        echo "changed"
        return
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
        echo "removed"
        return
    fi

    # Fallback: keyword-based categorization
    if [[ "$lower_msg" =~ (add|introduce|implement|create|new|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ (fix|bug|patch|resolve|correct|repair) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ (remove|delete|drop|revert|clean|deprecat) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Main execution
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No new commits found since last tag."
        exit 0
    fi

    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local category
        category=$(categorize_commit "$line")
        case "$category" in
            added)   added+=("- $line") ;;
            fixed)   fixed+=("- $line") ;;
            changed) changed+=("- $line") ;;
            removed) removed+=("- $line") ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        [ -n "$latest_tag" ] && echo "## Unreleased (since $latest_tag)" || echo "## Unreleased"
        echo ""
        if [ ${#added[@]}   -gt 0 ]; then echo "### Added";   printf '%s\n' "${added[@]}";   echo ""; fi
        if [ ${#fixed[@]}   -gt 0 ]; then echo "### Fixed";   printf '%s\n' "${fixed[@]}";   echo ""; fi
        if [ ${#changed[@]} -gt 0 ]; then echo "### Changed"; printf '%s\n' "${changed[@]}"; echo ""; fi
        if [ ${#removed[@]} -gt 0 ]; then echo "### Removed"; printf '%s\n' "${removed[@]}"; echo ""; fi
    } > "$CHANGELOG_FILE"

    echo "CHANGELOG.md generated at $CHANGELOG_FILE"
}

main "$@"
# Skill: Generate Changelog

## Description
Generate a structured `CHANGELOG.md` from a project's git history.

## Setup
1. Save `generate-changelog.sh` to your repo root.
2. Make it executable: `chmod +x generate-changelog.sh`
3. Run it: `./generate-changelog.sh`

## Usage
