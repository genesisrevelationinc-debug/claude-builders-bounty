#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

# Get the latest git tag, or use empty if none exists
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits_since_tag() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --reverse 2>/dev/null || true
    else
        git log --pretty=format:"%s" --reverse 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|repair|resolve)'; then
        echo "fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|revert|undo|clean)'; then
        echo "removed"
    elif echo "$lower" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize)'; then
        echo "changed"
    else
        # Fallback: keyword matching in the message body
        if echo "$lower" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
            echo "added"
        elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|bug|bugfix|repair|resolve|resolves|solved)\b'; then
            echo "fixed"
        elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted)\b'; then
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
    
    # Read commits into array
    local commits
    commits=$(get_commits_since_tag)
    
    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi
    
    # Categorize each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added) added+=("$commit") ;;
            fixed) fixed+=("$commit") ;;
            removed) removed+=("$commit") ;;
            changed) changed+=("$commit") ;;
        esac
    done <<< "$commits"
    
    # Output CHANGELOG
    echo "# Changelog"
    echo ""
    if [ -n "$tag" ]; then
        echo "## Unreleased (since $tag)"
    else
        echo "## Unreleased"
    fi
    echo ""
    
    if [ ${#added[@]} -gt 0 ]; then
        echo "### Added"; echo ""; for c in "${added[@]}"; do echo "- $c"; done; echo ""
    fi
    if [ ${#fixed[@]} -gt 0 ]; then
        echo "### Fixed"; echo ""; for c in "${fixed[@]}"; do echo "- $c"; done; echo ""
    fi
    if [ ${#changed[@]} -gt 0 ]; then
        echo "### Changed"; echo ""; for c in "${changed[@]}"; do echo "- $c"; done; echo ""
    fi
    if [ ${#removed[@]} -gt 0 ]; then
        echo "### Removed"; echo ""; for c in "${removed[@]}"; do echo "- $c"; done; echo ""
    fi
}

# Main execution
generate_changelog > CHANGELOG.md
echo "✅ CHANGELOG.md generated successfully!"
# Generate Changelog Skill

A Claude Code skill to generate a structured `CHANGELOG.md` from git history.

## Command

