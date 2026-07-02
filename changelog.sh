#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them, and appends
# a new version section to CHANGELOG.md.
#
# Categories: Added / Fixed / Changed / Removed
#

set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────
CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# ── Helpers ────────────────────────────────────────────────────────
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

get_commits_since() {
    local tag="$1"
    if [ -z "$tag" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges "${tag}..HEAD"
    fi
}

get_next_version() {
    local last_tag="$1"
    if [ -z "$last_tag" ]; then
        echo "v0.1.0"
    else
        # Strip 'v' prefix, bump patch
        local version="${last_tag#v}"
        local major minor patch
        IAGOFS='.' read -r major minor patch <<< "$version"
        patch=$((patch + 1))
        echo "v${major}.${minor}.${patch}"
    fi
}

categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Removed
    if echo "$lower" | grep -Eq 'remove|delete|drop|clean|revert'; then
        echo "Removed"
        return
    fi

    # Fixed
    if echo "$lower" | grep -Eq 'fix|bug|repair|correct|resolve|patch|hotfix'; then
        echo "Fixed"
        return
    fi

    # Added
    if echo "$lower" | grep -Eq 'add|feat|feature|implement|introduce|create|new|support|enable'; then
        echo "Added"
        return
    fi

    # Changed (default)
    echo "Changed"
}

# ── Main ───────────────────────────────────────────────────────────
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    local commits
    commits=$(get_commits_since "$last_tag")

    if [ -z "$commits" ]; then
        echo "No commits since last tag. Nothing to do."
        exit 0
    fi

    local version
    version=$(get_next_version "$last_tag")

    # Build changelog section
    local added="" fixed="" changed="" removed=""

    while IFS= read -r commit; do
        [ -z "$commit" ]=$((1)) && continue
        local cat
        cat=$(categorize_commit "$commit")
        case "$cat" in
            Added)   added="${added}- ${commit}"$'\n' ;;
            Fixed)   fixed="${fixed}- ${commit}"$'\n' ;;
            Changed) changed="${changed}- ${commit}"$'\n' ;;
            Removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"

    {
        echo "## [${version}] - ${DATE}"
        echo ""
        [ -n "$added" ]   && echo "### Added"   && echo -e "$added"   && echo ""
        [ -n "$changed" ] && echo "### Changed" && echo -e "$changed" && echo ""
        [ -n "$fixed" ]   && echo "### Fixed"   && echo -e "$fixed"   && echo ""
        [ -n "$removed" ] && echo "### Removed" && echo -e "$removed" && echo ""
    } > /tmp/changelog_new_section.md

    # Prepend to existing CHANGELOG or create new
    if [ -f "$CHANGELOG_FILE" ]; then
        cat /tmp/changelog_new_section.md > /tmp/changelog_combined.md
        echo "# Changelog" >> /tmp/changelog_combined.md
        echo "" >> /tmp/changelog_combined.md
        echo "All notable changes to this project will be documented in this file." >> /tmp/changelog_combined.md
        echo "" >> /tmp/changelog_combined.md
        cat "$CHANGELOG_FILE" >> /tmp/changelog_combined.md
        mv /tmp/changelog_combined.md "$CHANGELOG_FILE"
    else
        cat /tmp/changelog_new_section.md > "$CHANGELOG_FILE"
    fi

    echo "CHANGELOG updated: ${version}"
}

main "$@"