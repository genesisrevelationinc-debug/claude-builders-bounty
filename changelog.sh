#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage:
#   bash changelog.sh
#
# This script fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes or keywords
    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce)|\badd(ed|ing)?\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix)|\bfix(ed|ing)?\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)|\b(remov|delet|drop|revert)(ed|ing)?\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|upgrade)|\b(update|chang|modif|refactor|improv|upgrad)(ed|ing)?\b'; then
        echo "changed"
    else
        # Default to changed if no clear match
        echo "changed"
    fi
}

# Generate the changelog entry
generate_changelog() {
    local tag="$1"
    local date_str
    date_str=$(date +%Y-%m-%d)
    local version_label
    if [ -n "$tag" ]; then
        version_label="$tag..HEAD"
    else
        version_label="HEAD"
    fi

    local added=""
    local fixed=""
    local changed=""
    local removed=""

    while IFS= read -r commit_msg; do
        [ -z "$commit_msg" ] && continue
        local category
        category=$(categorize_commit "$commit_msg")
        case "$category" in
            added)   added="$added- $commit_msg"$'\n' ;;
            fixed)   fixed="$fixed- $commit_msg"$'\n' ;;
            changed) changed="$changed- $commit_msg"$'\n' ;;
            removed) removed="$removed- $commit_msg"$'\n' ;;
        esac
    done < <(get_commits_since_tag "$tag")

    # Build output
    local output=""
    output="## [Unreleased] - $date_str"$'\n\n'

    if [ -n "$added" ]; then
        output="${output}### Added"$'\n\n'"$added"$'\n'
    fi
    if [ -n "$changed" ]; then
        output="${output}### Changed"$'\n\n'"$changed"$'\n'
    fi
    if [ -n "$fixed" ]; then
        output="${output}### Fixed"$'\n\n'"$fixed"$'\n'
    fi
    if [ -n "$removed" ]; then
        output="${output}### Removed"$'\n\n'"$removed"$'\n'
    fi

    echo "$output"
}

# Main execution
main() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}Error: Not a git repository.${NC}"
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    if [ -z "$latest_tag" ]; then
        echo -e "${YELLOW}Warning: No git tags found. Using all commits.${NC}"
    else
        echo -e "${GREEN}Latest tag: $latest_tag${NC}"
    fi

    local changelog_entry
    changelog_entry=$(generate_changelog "$latest_tag")

    # Prepend to CHANGELOG.md or create new
    if [ -f "CHANGELOG.md" ]; then
        local temp_file
        temp_file=$(mktemp)
        {
            echo "# Changelog"
            echo ""
            echo "$changelog_entry"
            # Remove the old header if it exists, then append the rest
            tail -n +3 CHANGELOG.md | sed '1{/^# Changelog$/d}'
        } > "$temp_file"
        mv "$temp_file" CHANGELOG.md
    else
        {
            echo "# Changelog"
            echo ""
            echo "$changelog_entry"
        } > CHANGELOG.md
    fi

    echo -e "${GREEN}CHANGELOG.md updated successfully!${NC}"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

A Claude Code skill to generate a structured `CHANGELOG.md` from git history.

## Command

