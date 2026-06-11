#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh
#

set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────
OUTPUT_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# ── Helpers ────────────────────────────────────────────────────────
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since() {
    local since_ref="$1"
    if [[ -n "$since_ref" ]]; then
        git log "$since_ref"..HEAD --pretty=format:"%s" --no-merges 2>/dev/null || true
    else
        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
    fi
}

categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        feat*|add*|new*|introduce*|implement*)
            echo "added"
            ;;
        fix*|bugfix*|patch*|resolve*|hotfix*)
            echo "fixed"
            ;;
        change*|update*|modify*|refactor*|improve*|enhance*|upgrade*)
            echo "changed"
            ;;
        remove*|delete*|drop*|deprecate*|clean*)
            echo "removed"
            ;;
        *)
            # Default categorization based on common commit message prefixes
            if [[ "$lower" =~ ^(feat|feature|add|new) ]]; then
                echo "added"
            elif [[ "$lower" =~ ^(fix|bug|patch|resolve) ]]; then
                echo "fixed"
            elif [[ "$lower" =~ ^(chore|docs|style|test|build|ci|perf) ]]; then
                echo "changed"
            else
                echo "changed"
            fi
            ;;
    esac
}

# ── Main ───────────────────────────────────────────────────────────
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    local version_header
    if [[ -n "$last_tag" ]]; then
        version_header="## [Unreleased] — since $last_tag"
    else
        version_header="## [Unreleased] — all commits"
    fi

    local commits
    commits=$(get_commits_since "$last_tag")

    if [[ -z "$commits" ]]; then
        echo "No commits found since last tag." >&2
        exit 0
    fi

    # Categorize commits
    local added="" fixed="" changed="" removed=""

    while IFS= read -r commit; do
        [[ -z "$commit" ]] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added)   added+="- $commit"$'\n' ;;
            fixed)   fixed+="- $commit"$'\n' ;;
            changed) changed+="- $commit"$'\n' ;;
            removed) removed+="- $commit"$'\n' ;;
        esac
    done <<< "$commits"

    # Build CHANGELOG
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project are documented in this file."
        echo ""
        echo "$version_header"
        echo ""
        echo "### Added"
        echo ""
        if [[ -n "$added" ]]; then
            echo -n "$added"
        else
            echo "- Nothing to report"
        fi
        echo ""
        echo "### Fixed"
        echo ""
        if [[ -n "$fixed" ]]; then
            echo -n "$fixed"
        else
            echo "- Nothing to report"
        fi
        echo ""
        echo "### Changed"
        echo ""
        if [[ -n "$changed" ]]; then
            echo -n "$changed"
        else
            echo "- Nothing to report"
        fi
        echo ""
        echo "### Removed"
        echo ""
        if [[ -n "$removed" ]]; then
            echo -n "$removed"
        else
            echo "- Nothing to report"
        fi
        echo ""
    } > "$OUTPUT_FILE"

    echo "✅  CHANGELOG.md generated at $OUTPUT_FILE"
}

main "$@"

--- /dev/null
# Skill: Generate Changelog

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### What it does

1. Detects the most recent git tag
2. Collects all commits since that tag (or all commits if no tag exists)
3. Auto-categorizes each commit into:
   - **Added** — new features, additions
   - **Fixed** — bug fixes, patches
   - **Changed** — updates, refactors, improvements
   - **Removed** — deletions, deprecations
4. Writes a properly formatted `CHANGELOG.md`

### Usage

