#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag, or use empty if none exists
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

# Get the current version from latest tag, or default to 0.0.0
get_version() {
    local tag="$1"
    if [ -n "$tag" ]; then
        # Increment patch version
        local major minor patch
        IFS='.' read -r major minor patch <<< "$tag"
        patch=$((patch + 1))
        echo "${major}.${minor}.${patch}"
    else
        echo "0.1.0"
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    case "$lower_msg" in
        *"fix"* | *"bugfix"* | *"hotfix"* | *"patch"*)
            echo "fixed"
            ;;
        *"add"* | *"feat"* | *"feature"* | *"implement"* | *"introduce"*)
            echo "added"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"*)
            echo "removed"
            ;;
        *"update"* | *"change"* | *"refactor"* | *"improve"* | *"optimize"* | *"rework"*)
            echo "changed"
            ;;
        *)
            echo "changed"
            ;;
    esac
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local version
    version=$(get_version "$latest_tag")

    local commits
    commits=$(get_commits "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No new commits since last tag." >&2
        exit 0
    fi

    # Categorize commits
    local added="" fixed="" changed="" removed=""
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local category
        category=$(categorize_commit "$line")
        case "$category" in
            added)   added="${added}- ${line}"$'\n' ;;
            fixed)   fixed="${fixed}- ${line}"$'\n' ;;
            changed) changed="${changed}- ${line}"$'\n' ;;
            removed) removed="${removed}- ${line}"$'\n' ;;
        esac
    done <<< "$commits"

    # Build changelog entry
    {
        echo "## [${version}] - ${DATE}"
        echo ""
        [ -n "$added" ]   && echo "### Added"$'\n'"$added"
        [ -n "$changed" ] && echo "### Changed"$'\n'"$changed"
        [ -n "$fixed" ]   && echo "### Fixed"$'\n'"$fixed"
        [ -n "$removed" ] && echo "### Removed"$'\n'"$removed"
    } > "$CHANGELOG_FILE"

    echo "Generated $CHANGELOG_FILE for version $version"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

## Description
Automatically generate a structured `CHANGELOG.md` from a project's git history, categorizing commits into Added, Fixed, Changed, and Removed.

## Usage
Run the `/generate-changelog` command or execute `bash changelog.sh` in your terminal.

## Setup
1. Save `changelog.sh` to your project root
2. Make it executable: `chmod +x changelog.sh`
3. Run: `bash changelog.sh`

## Commands

### /generate-changelog
Generates a `CHANGELOG.md` file by:
- Fetching commits since the last git tag
- Auto-categorizing commits based on keywords in commit messages
- Outputting a properly formatted changelog

## Categorization Rules
| Category | Keywords |
|----------|----------|
| Added | add, feat, feature, implement, introduce |
| Fixed | fix, bugfix, hotfix, patch |
| Changed | update, change, refactor, improve, optimize, rework |
| Removed | remove, delete, drop, deprecate |

## Output Format
