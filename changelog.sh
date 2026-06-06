#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"

# Get the latest git tag; if none, use the first commit
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD 2>/dev/null || echo ""
}

# Get commits since the last tag
get_commits_since_tag() {
    local since="$1"
    if [ -z "$since" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log "${since}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes and keywords
    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce)|\b(add|added|adding|introduce|introduces|introducing|feature|features)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|patch|bugfix)|\b(fix|fixed|fixing|patch|patched|repair|repaired|resolve|resolves|resolved|bugfix|bugfixes)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop)|\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|dropping|deprecate|deprecates|deprecated)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance)|\b(change/update|update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|refactoring|improve|improved|improving|enhance|enhanced|enhancing|upgrade|upgraded|rework|reworked)\b'; then
        echo "changed"
    else
        # Default to changed for anything else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    local tag_ref="$last_tag"
    [ -z "$last_tag" ] && tag_ref="beginning"

    locals
    local commits
    commits=$(get_commits_since_tag "$last_tag")

    if [ -z "$commits" ]; then
        echo "No commits found since $tag_ref."
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
            added)   added="${added}- ${commit}"$'\n' ;;
            fixed)   fixed="${fixed}- ${commit}"$'\n' ;;
            changed) changed="${changed}- ${commit}"$'\n' ;;
            removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done <<< "$commits"

    local version_date
    version_date=$(date +%Y-%m-%d)
    local new_version="## [Unreleased] - ${version_date}"$'\n\n'

    local output=""
    [ -n "$added" ]   && output="${output}### Added"$'\n\n'"${added}"$'\n'
    [ -n "$changed" ] && output="${output}### Changed"$'\n\n'"${changed}"$'\n'
    [ -n "$fixed" ]   && output="${output}### Fixed"$'\n\n'"${fixed}"$'\n'
    [ -n "$removed" ] && output="${output}### Removed"$'\n\n'"${removed}"$'\n'

    # Prepend to existing CHANGELOG or create new one
    if [ -f "$CHANGELOG_FILE" ]; then
        local existing
        existing=$(cat "$CHANGELOG_FILE")
        echo -e "# Changelog\n\n${new_version}${output}\n${existing#*$'# Changelog\n\n'}" > "$CHANGELOG_FILE"
    else
        {
            echo "# Changelog"
            echo ""
            echo "${new_version}${output}"
        } > "$CHANGELOG_FILE"
    fi

    echo "✅ CHANGELOG.md generated successfully!"
    echo "   Commits since: $tag_ref"
}

# Main
generate_changelog