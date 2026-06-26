#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

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

# Get the date of the latest tag commit or repo creation
get_date() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log -1 --format=%ad --date=short "$tag" 2>/dev/null || date +%Y-%m-%d
    else
        date +%Y-%m-%d
    fi
}

# Get the next version (bump patch of latest tag, or start at 0.1.0)
get_next_version() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        # Remove 'v' prefix if present
        local version="${tag#v}"
        # Split version into parts
        local major minor patch
        IFS='.' read -r major minor patch <<< "$version"
        # Increment patch
        patch=$((patch + 1))
        echo "${major}.${minor}.${patch}"
    else
        echo "0.1.0"
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    if echo "$lower" | grep -qE '^(feat|add|new|introduce|implement|create)'; then
        echo "added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|resolve|patch|correct)'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|revert|undo)'; then
        echo "removed"
    elif echo "$lower" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade)'; then
        echo "changed"
    else
        # Default categorization based on keywords in message
        if echo "$lower" | grep -qE '\b(add|added|adding|introduce|implement)\b'; then
            echo "added"
        elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug)\b'; then
            echo "fixed"
        elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|drop)\b'; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local version date added fixed changed removed
    version=$(get_next_version)
    date=$(get_date)

    # Initialize category arrays
    added=""
    fixed=""
    changed=""
    removed=""

    # Read and categorize commits
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added)   added="${added}- ${commit}"$'\n' ;;
            fixed)   fixed="${fixed}- ${commit}"$'\n' ;;
            changed) changed="${changed}- ${commit}"$'\n' ;;
            removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done < <(get_commits)

    # Build CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## [${version}] - ${date}"
        echo ""
        
        if [ -n "$added" ]; then
            echo "### Added"
            echo ""
            echo -n "$added"
            echo ""
        fi
        
        if [ -n "$changed" ]; then
            echo "### Changed"
            echo ""
            echo -n "$changed"
            echo ""
        fi
        
        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo ""
            echo -n "$fixed"
            echo ""
        fi
        
        if [ -n "$removed" ]; then
            echo "### Removed"
            echo ""
            echo -n "$removed"
            echo ""
        fi
    } > "$CHANGELOG_FILE"

    echo "CHANGELOG.md generated at: $CHANGELOG_FILE"
    echo "Version: $version"
    echo ""
    cat "$CHANGELOG_FILE"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

A Claude Code skill to generate a structured `CHANGELOG.md` from git history.

## Usage

