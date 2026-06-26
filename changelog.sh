#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    if echo "$lower" | grep -qE '^(feat|add|added|new|introduce|implement|create|support)'; then
        echo "added"
    elif echo "$lower" | grep -qE '^(fix|fixed|bugfix|hotfix|resolve|patch|correct)'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '^(remove|removed|delete|deleted|drop|dropped|revert)'; then
        echo "removed"
    elif echo "$lower" | grep -qE '^(change|changed|update|updated|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework)'; then
        echo "changed"
    else
        # Default categorization based on keywords in the message
        if echo "$lower" | grep -qE '\b(add|adds|adding|added)\b'; then
            echo "added"
        elif echo "$lower" | grep -qE '\b(fix|fixes|fixed|fixing)\b'; then
            echo "fixed"
        elif echo "$lower" | grep -qE '\b(remove|removes|removed|removing|delete|deletes|deleted|deleting)\b'; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue

        local category
        category=$(categorize "$commit")

        case "$category" in
            added)   added+=("$commit") ;;
            fixed)   fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done < <(get_commits)

    local version
    version=$(get_latest_tag)
    [ -z "$version" ] && version="Unreleased"

    local date_str
    date_str=$(date +%Y-%m-%d)

    {
        echo "# Changelog"
        echo ""
        echo "## [$version] - $date_str"
        echo ""

        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf -- "- %s\n" "${added[@]}"
            echo ""
        fi

        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf -- "- %s\n" "${fixed[@]}"
            echo ""
        fi

        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf -- "- %s\n" "${changed[@]}"
            echo ""
        fi

        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf -- "- %s\n" "${removed[@]}"
            echo ""
        fi
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated successfully!"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
# Generate Changelog Skill

A Claude Code skill to automatically generate a structured `CHANGELOG.md` from a project's git history.

## Commands

### `/generate-changelog`

Generates a `CHANGELOG.md` file by:
1. Fetching commits since the last git tag
2. Auto-categorizing them into: **Added**, **Fixed**, **Changed**, **Removed**
3. Writing a properly formatted `CHANGELOG.md`

## Setup

1. Save `changelog.sh` to your project root
2. Make it executable: `chmod +x changelog.sh`
3. Run: `bash changelog.sh`

## Categorization Rules

| Category | Keywords |
|----------|----------|
| Added | feat, add, added, new, introduce, implement, create, support |
| Fixed | fix, fixed, bugfix, hotfix, resolve, patch, correct |
| Changed | change, changed, update, updated, modify, modified, refactor, refactored, improve, improved, enhance, enhanced, upgrade, upgraded, rework |
| Removed | remove, removed, delete, deleted, drop, dropped, revert |

## Output Format

