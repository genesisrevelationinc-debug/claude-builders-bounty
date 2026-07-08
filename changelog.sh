#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Get the latest git tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the latest tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a commit message into a section
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade)'; then
        echo "changed"
    # Check for keywords in message body
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|patch)\b'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|revert)\b'; then
        echo "removed"
    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|modify|modified|refactor|improve|improved|enhance)\b'; then
        echo "changed"
    else
        # Default to changed for uncategorized commits
        echo "changed"
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    
    local commits
    commits=$(get_commits "$tag")
    
    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi
    
    # Initialize category arrays
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Process each commit
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
    done <<< "$commits"
    
    # Output CHANGELOG
    echo "# Changelog"
    echo ""
    echo "## $(date +%Y-%m-%d)"
    echo ""
    
    if [ ${#added[@]} -gt 0 ]; then
        echo "### Added"
        printf -- "- %s\n" "${added[@]}"
        echo ""
    fi
    
    if [ ${#fixed[@]} -gt 0 ]; then
        echo "### Fixed"
        printf -- "- %s\n" "${fixed[@]}"
        echo ""
    fi
    
    if [ ${#changed[@]} -gt 0 ]; then
        echo "### Changed"
        printf -- "- %s\n" "${changed[@]}"
        echo ""
    fi
    
    if [ ${#removed[@]} -gt 0 ]; then
        echo "### Removed"
        printf -- "- %s\n" "${removed[@]}"
        echo ""
    fi
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi
    
    generate_changelog > CHANGELOG.md
    echo "CHANGELOG.md generated successfully!"
}

main "$@"