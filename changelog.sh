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
DATE=$(date +%Y-%m-%d)

# ── Helpers ──────────────────────────────────────────────────────────────────
error() {
    echo "Error: $*" >&2
    exit 1
}

git_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

git_commits_since() {
    local ref="$1"
    if [[ -n "$ref" ]]; then
        git log "${ref}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        *"fix"* | *"bug"* | *"patch"* | *"repair"* | *"resolve"* | *"close "* | *"closes "*)
            echo "Fixed"
            ;;
        *"add"* | *"feat"* | *"feature"* | *"introduce"* | *"implement"* | *"new "*)
            echo "Added"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"* | *"clean"*)
            echo "Removed"
            ;;
        *"change"* | *"update"* | *"refactor"* | *"rework"* | *"improve"* | *"optimize"* | *"upgrade"*)
            echo "Changed"
            ;;
 *)
            echo "Changed"
            ;;
    esac
}

# ── Main ─────────────────────────────────────────────────────────────────────

# Ensure we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run from inside a git repo."
fi

# Find last tag
LAST_TAG=$(git_last_tag)

if [[ -z "$LAST_TAG" ]]; then
    echo "ℹ️  No previous tag found. Using all commits."
    VERSION="Unreleased"
else
    echo "ℹ️  Last tag: $LAST_TAG"
    VERSION="$LAST_TAG → HEAD"
fi

# Gather commits
COMMITS=$(git_commits_since "$LAST_TAG")

if [[ -z "$COMMITS" ]]; then
    echo "No new commits since $LAST_TAG."
    exit 0
fi

# Build categorized lists
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    cat=$(categorize "$line")
    case "$cat" in
        Added)   ADDED="$ADDED- $line"$'\n' ;;
        Fixed)   FIXED="$FIXED- $line"$'\n' ;;
        Changed) CHANGED="$CHANGED- $line"$'\n' ;;
        Removed) REMOVED="$REMOVED- $line"$'\n' ;;
    esac
done <<< "$COMMITS"

# ── Write / Update CHANGELOG.md ──────────────────────────────────────────────

{
    echo "## [$VERSION] - $DATE"
    echo ""
    [[ -n "$ADDED" ]]   && { echo "### Added";   echo "$ADDED"; }
    [[ -n "$CHANGED" ]] && { echo "### Changed"; echo "$CHANGED"; }
    [[ -n "$FIXED" ]]   && { echo "### Fixed";   echo "$FIXED"; }
    [[ -n "$REMOVED" ]] && { echo "### Removed"; echo "$REMOVED"; }
} > .changelog_new_section.md

if [[ -f "$CHANGELOG_FILE" ]]; then
    # Prepend new section after a header if it exists, else just prepend
    cat .changelog_new_section.md > .changelog_tmp.md
    cat "$CHANGELOG_FILE" >> .changelog_tmp.md
    mv .changelog_tmp.md "$CHANGELOG_FILE"
else
    cat .changelog_new_section.md > "$CHANGELOG_FILE"
fi

rm -f .changelog_new_section.md

echo "✅  CHANGELOG updated in $CHANGELOG_FILE"