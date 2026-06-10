#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
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
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(docs|doc)(\(.+\))?: ]]; then
        echo "added"
    # Fallback to keyword matching
    elif [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|feature) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|resolve|patch|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate) ]]; then
        echo "removed"
    elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework) ]]; then
        echo "changed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local tag
    tag=$(get_latest_tag)

    local commits
    commits=$(get_commits "$tag")

    if [ -z "$commits" ]; then
        echo "No commits found since ${tag:-the beginning}."
        exit 0
    fi

    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue

        local category
        category=$(categorize_commit "$commit")

        case "$category" in
            added)   added+="- $commit"$'\n' ;;
            fixed)   fixed+="- $commit"$'\n' ;;
            changed) changed+="- $commit"$'\n' ;;
            removed) removed+="- $commit"$'\n' ;;
        esac
    done <<< "$commits"

    # Build output
    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - $DATE"
        echo ""

        [ -n "$added" ]   && { echo "### Added";   echo -e "$added";   echo ""; }
        [ -n "$changed" ] && { echo "### Changed"; echo -e "$changed"; echo ""; }
        [ -n "$fixed" ]   && { echo "### Fixed";   echo -e "$fixed";   echo ""; }
        [ -n "$removed" ] && { echo "### Removed"; echo -e "$removed"; echo ""; }

    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG generated at $CHANGELOG_FILE"
}

generate_changelog