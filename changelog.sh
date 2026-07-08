#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes and keywords
    if echo "$lower" | grep -qE '^(feat|add|create|introduce|implement)'; then
        echo "added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "removed"
    elif echo "$lower" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|migrate)'; then
        echo "changed"
    else
        # Fallback: keyword-based detection
        if echo "$lower" | grep -qE '\b(add|added|adding|new|introduce|implement|create)\b'; then
            echo "added"
        elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|bug|patch|resolve|solved|correct)\b'; then
            echo "fixed"
        elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|deprecate)\b'; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        
        case "$category" in
            added) added+=("$commit") ;;
            fixed) fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done < <(get_commits)
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        
        local version_date
        version_date=$(date +%Y-%m-%d)
        local version_label
        version_label="${tag:-Unreleased}"
        
        echo "## [${version_label}] - ${version_date}"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf '%s\n' "${added[@]}" | sed 's/^/- /'
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf '%s\n' "${fixed[@]}" | sed 's/^/- /'
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf '%s\n' "${changed[@]}" | sed 's/^/- /'
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf '%s\n' "${removed[@]}" | sed 's/^/- /'
            echo ""
        fi
    } > "$OUTPUT_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
echo "CHANGELOG.md generated at: $OUTPUT_FILE"