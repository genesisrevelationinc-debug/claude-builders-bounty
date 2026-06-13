#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them, and appends
# a new section to CHANGELOG.md (creates it if missing).
#

set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────────────
CHANGELOG_FILE="CHANGELOG.md"
CATEGORIES=("Added" "Fixed" "Changed" "Removed")

# ── Helpers ──────────────────────────────────────────────────────────────────

get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since() {
    local since="$1"
    if [[ -n "$since" ]]; then
        git log "${since}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        feat:*|feature:*|add:*|added:*|new:*|introduce:*|implement:*)
            echo "Added"
            ;;
        fix:*|fixed:*|bugfix:*|patch:*|hotfix:*|resolve:*|closes:*|close:*)
            echo "Fixed"
            ;;
        remove:*|removed:*|delete:*|deleted:*|drop:*|dropped:*|deprecate:*)
            echo "Removed"
            ;;
        change:*|changed:*|update:*|updated:*|refactor:*|refactored:*|modify:*|modified:*|improve:*|improved:*|rework:*|cleanup:*|clean:*|style:*|chore:*|docs:*|doc:*|test:*|tests:*|perf:*|performance:*|security:*|bump:*|deps:*|dependency:*|dependencies:*|ci:*|build:*|release:*|revert:*|merge:*)
            echo "Changed"
            ;;
        *)
            # Default heuristic: look for keywords anywhere
            if [[ "$lower" =~ \b(add|added|adding|introduce|implement|create|support)\b ]]; then
                echo "Added"
            elif [[ "$lower" =~ \b(fix|fixed|fixes|fixing|resolve|resolves|resolved|bug|patch|close|closes|closed)\b ]]; then
                echo "Fixed"
            elif [[ "$lower" =~ \b(remove|removed|removes|removing|delete|deleted|deletes|drop|dropped|deprecate|deprecates)\b ]]; then
                echo "Removed"
            else
                echo "Changed"
            fi
            ;;
    esac
}

format_commit() {
    local msg="$1"
    # Strip conventional commit prefix if present
    local clean
    clean=$(echo "$msg" | sed -E 's/^[a-zA-Z]+(\([^)]*\))?:\s*//')
    echo "- ${clean}"
}

# ── Main ─────────────────────────────────────────────────────────────────────

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

LAST_TAG=$(get_last_tag)
COMMITS=$(get_commits_since "$LAST_TAG")

if [[ -z "$COMMITS" ]]; then
    echo "No commits found since last tag."
    exit 0
fi

# Initialize associative arrays for categories
declare -A category_items
for cat in "${CATEGORIES[@]}"; do
    category_items["$cat"]=""
done

# Categorize commits
while IFS= read -r commit; do
    [[ -z "$commit" ]] && continue
    cat=$(categorize_commit "$commit")
    formatted=$(format_commit "$commit")
    category_items["$cat"]+="${formatted}"$'\n'
done <<< "$COMMITS"

# Build changelog section
DATE=$(date +%Y-%m-%d)
VERSION_HEADER="## [Unreleased] - ${DATE}"

if [[ -n "$LAST_TAG" ]]; then
    VERSION_HEADER="## [Unreleased] - ${DATE} (since ${LAST_TAG})"
fi

{
    echo "$VERSION_HEADER"
    echo ""
    for cat in "${CATEGORIES[@]}"; do
        if [[ -n "${category_items[$cat]}" ]]; then
            echo "### ${cat}"
            echo -n "${category_items[$cat]}"
            echo ""
        fi
    done
} > /tmp/changelog_new_section.md

# Prepend new section to existing CHANGELOG or create fresh
if [[ -f "$CHANGELOG_FILE" ]]; then
    {
        cat /tmp/changelog_new_section.md
        cat "$CHANGELOG_FILE"
    } > /tmp/changelog_combined.md
    mv /tmp/changelog_combined.md "$CHANGELOG_FILE"
else
    {
        echo "# Changelog"
        echo ""
        cat /tmp/changelog_new_section.md
    } > "$CHANGELOG_FILE"
fi

echo "CHANGELOG.md updated successfully."