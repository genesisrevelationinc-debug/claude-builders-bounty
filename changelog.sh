#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
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
    
    # Check for conventional commit prefixes first
    if echo "$lower" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|eliminate|deprecate)'; then
        echo "removed"
    elif echo "$lower" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade)'; then
        echo "changed"
    # Check for keywords in the message body
    elif echo "$lower" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
        echo "added"
    elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|eliminate)\b'; then
        echo "removed"
    elif echo "$lower" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|refactor|improve|improved|enhance)\b'; then
        echo "changed"
    else
        Amend the default to "changed" for uncategorized commits
        echo "changed"
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
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - ${DATE}"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf " - %s\n" "${added[@]}"
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf " - %s\n" "${changed[@]}"
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf " - %s\n" "${fixed[@]}"
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf " - %s\n" "${removed[@]}"
            echo ""
        fi
    } > "$CHANGELOG_FILE"
    
    echo "✅ Generated $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog