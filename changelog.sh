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
REPO_URL=""          # e.g. https://github.com/user/repo  (auto-detected if empty)

# ── Helpers ────────────────────────────────────────────────────────────────

get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_repo_url() {
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    # Convert SSH → HTTPS
    if [[ "$remote_url" == git@github.com:* ]]; then
        remote_url="${remote_url/git@github.com:/https://github.com/}"
    fi
    remote_url="${remote_url%.git}"
    echo "$remote_url"
}

get_commits_since_tag() {
    local tag="$1"
    if [[ -z "$tag" ]]; then
        git log --pretty=format:"%H|%s" --no-merges
    else
        git log "${tag}..HEAD" --pretty=format:"%H|%s" --no-merges
    fi
}

categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if [[ "$lower" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower" =~ ^(refactor|perf|style)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
        echo "removed"
    else
        # Fallback: keyword matching
        if [[ "$lower" =~ (add|new|introduce|create|implement|support) ]]; then
            echo "added"
        elif [[ "$lower" =~ (fix|bug|patch|resolve|close) ]]; then
            echo "fixed"
        elif [[ "$lower" =~ (remove|delete|drop|revert|deprecate) ]]; then
            echo "removed"
        elif [[ "$lower" =~ (update|change|modify|refactor|improve|enhance|upgrade|migrate) ]]; then
            echo "changed"
        else
            echo "changed"  # default bucket
        fi
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

LAST_TAG=$(get_last_tag)
if [[ -z "$REPO_URL" ]]; then
    REPO_URL=$(get_repo_url)
fi

# Determine version / date header
TODAY=$(date +%Y-%m-%d)
if [[ -n "$LAST_TAG" ]]; then
    HEADER="## [Unreleased] — $TODAY"
else
    HEADER="## [Unreleased] — $TODAY"
    LAST_TAG="(beginning of history)"
fi

# Collect commits
declare -A ADDED FIXED CHANGED REMOVED

while IFS='|' read -r hash msg; do
    [[ -z "$msg" ]] && continue
    category=$(categorize_commit "$msg")
    case "$category" in
        added)   ADDED["$hash"]="$msg" ;;
        fixed)   FIXED["$hash"]="$msg" ;;
        removed) REMOVED["$hash"]="$msg" ;;
        changed) CHANGED["$hash"]="$msg" ;;
    esac
done < <(get_commits_since_tag "$LAST_TAG")

# Build new changelog section
{
    echo "$HEADER"
    echo ""
    echo "### Added"
    ((${#ADDED[@]}))    && for h in "${!ADDED[@]}"; do echo "- ${ADDED[$h]}"; done || echo "- Nothing to report"
    echo ""
    echo "### Fixed"
    ((${#FIXED[@]}))    && for h in "${!FIXED[@]}"; do echo "- ${FIXED[$h]}"; done || echo "- Nothing to report"
    echo ""
    echo "### Changed"
    ((${#CHANGED[@]}))  && for h in "${!CHANGED[@]}"; do echo "- ${CHANGED[$h]}"; done || echo "- Nothing to report"
    echo ""
    echo "### Removed"
    ((${#REMOVED[@]}))  && for h in "${!REMOVED[@]}"; do echo "- ${REMOVED[$h]}"; done || echo "- Nothing to report"
    echo ""
} > .changelog_new.md

# Prepend to existing CHANGELOG or create new
if [[ -f "$CHANGELOG_FILE" ]]; then
    {
        cat .changelog_new.md
        cat "$CHANGELOG_FILE"
    } > .changelog_tmp.md
    mv .changelog_tmp.md "$CHANGELOG_FILE"
else
    mv .changelog_new.md "$CHANGELOG_FILE"
fi

rm -f .changelog_new.md

echo "✅  CHANGELOG updated: $CHANGELOG_FILE"
echo "   Commits since: $LAST_TAG"