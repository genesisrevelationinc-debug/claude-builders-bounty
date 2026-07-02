#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGE把关 from git history
#
# Usage:
#   bash changelog.sh
#
# This script fetches commits since the last git tag, auto-categorizes them,
# and appends a new version section to CHANGELOG.md.
#
# Categories:
#   Added   — feat, add, introduce
#   Fixed   — fix, bugfix, patch
#   Changed — update, modify, refactor, change, improve
#   Removed — remove, delete, drop, deprecate
#

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────
CHANGELOG_FILE="CHANGELOG.md"
UNRELEASED_HEADER="## [Unreleased]"

# ── Helpers ─────────────────────────────────────────────────────────
error() { echo "Error: $*" >&2; exit 1; }

last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

commits_since() {
    local since="$1"
    if [[ -n "$since" ]]; then
        git log "${since}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Removed
    if echo "$lower" | grep -qE '^(remove|delete|drop|deprecat)'; then
        echo "Removed"
        return
    fi
    # Fixed
    if echo "$lower" | grep -qE '^(fix|bugfix|patch)'; then
        echo "Fixed"
        return
    fi
    # Added
    if echo "$lower" | grep -qE '^(feat|add|introduc|implement)'; then
        echo "Added"
        return
    fi
    # Changed
    if echo "$lower" | grep -qE '^(update|modify|refactor|change|improv|enhanc|optim)'; then
        echo "Changed"
        return
    fi

    # Default based on common conventional commit prefixes
    if echo "$lower" | grep -qE '^feat(\([^)]*\))?:'; then
        echo "Added"
    elif echo "$lower" | grep -qE '^fix(\([^)]*\))?:'; then
        echo "Fixed"
    elif echo "$lower" | grep -qEE '^(refactor|perf|style)(\([^)]*\))?:'; then
        echo "Changed"
    elif echo "$lower" | grep -qE '^(revert|remove|delete)(\([^)]*\))?:'; then
        echo "Removed"
    else
        echo "Changed"  # default fallback
    fi
}

# ── Main ────────────────────────────────────────────────────────────
main() {
    # Ensure we're in a git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        error "Not a git repository. Please run from a git project root."
    fi

    local tag
    tag=$(last_tag)

    if [[ -z "$tag" ]]; then
        echo "No previous tag found. Using all commits."
    else
        echo "Last tag: $tag"
    fi

    local commits
    commits=$(commits_since "$tag")

    if [[ -z "$commits" ]]; then
        echo "No commits found since last tag."
        exit 0
    fi

    # Build categorized lists
    local added="" fixed="" changed="" removed=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local cat
        cat=$(categorize "$line")
        case "$cat" in
            Added)   added+="- $line"$'\n' ;;
            Fixed)   fixed+="- $line"$'\n' ;;
            Changed) changed+="- $line"$'\n' ;;
            Removed) removed+="- $line"$'\n' ;;
        esac
    done <<< "$commits"

    # Build new changelog section
    local new_section=""
    new_section+=$'## [Unreleased]\n\n'
    [[ -n "$added" ]]   && new_section+="### Added"$'\n\n'"$added"$'\n'
    [[ -n "$changed" ]] && new_section+="### Changed"$'\n\n'"$changed"$'\n'
    [[ -n "$fixed" ]]   && new_section+="### Fixed"$'\n\n'"$fixed"$'\n'
    [[ -n "$removed" ]] && new_section+="### Removed"$'\n\n'"$removed"$'\n'

    # Prepend to CHANGELOG.md or create it
    if [[ -f "$CHANGELOG_FILE" ]]; then
        local existing
        existing=$(cat "$CHANGELOG_FILE")
        echo -e "$new_section\n$existing" > "$CHANGELOG_FILE"
    else
        echo -e "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n$new_section" > "$CHANGELOG_FILE"
    fi

    echo "CHANGELOG.md updated successfully."
}

main "$@"
# Skill: Generate Changelog

## Description

Automatically generate a structured `CHANGELOG.md` from a project's git history.

## Usage

Run the following command in your project root:

