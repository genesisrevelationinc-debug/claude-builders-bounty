#!/usr/bin/env bash
set -euo pipefail

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"

# Get the last git tag
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits() {
    local last_tag
    last_tag=$(get_last_tag)
    
    if [ -n "$last_tag" ]; then
        git log "$last_tag..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a commit message into Added, Fixed, Changed, or Removed
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce|implement)'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "Removed"
    elif echo "$lower_msg" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|deps|bump)'; then
        echo "Changed"
    else
        # Fallback: keyword-based categorization
        if echo "$lower_msg" | grep -qE '\b(add|adds|added|adding|new|create|introduce|implement|feature)\b'; then
            echo "Added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixes|fixed|fixing|bug|resolve|resolves|resolved|patch|correct)\b'; then
            echo "Fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|revert|reverts|reverted)\b'; then
            echo "Removed"
        else
            echo "Changed"
        fi
    fi
}

# Clean commit message (remove conventional commit prefix if present)
clean_message() {
    local msg="$1"
    # Remove conventional commit prefixes like "feat:", "fix:", "chore:", etc.
    echo "$msg" | sed -E 's/^[a-zA-Z]+(\([a-zA-Z0-9_-]+\))?:\s*//'
}

# Generate the CHANGELOG.md
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        local clean_msg
        clean_msg=$(clean_message "$commit")
        
        case "$category" in
            Added) added+=("$clean_msg") ;;
            Fixed) fixed+=("$clean_msg") ;;
            Changed) changed+=("$clean_msg") ;;
            Removed) removed+=("$clean_msg") ;;
        esac
    done < <(get_commits)
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        
        local version_date
        version_date=$(date +%Y-%m-%d)
        local version_label
        version_label="${last_tag:-Unreleased}"
        
        echo "## [${version_label}] - ${version_date}"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        # Preserve existing changelog content if it exists
        if [ -f "$CHANGELOG_FILE" ] && [ -s "$CHANGELOG_FILE" ]; then
            # Skip the header and first version section of the existing file
            tail -n +2 "$CHANGELOG_FILE" 2>/dev/null | sed '1,/^## /d' | sed '/^$/d' || true
        fi
    } > "$CHANGELOG.md.tmp"
    
    mv "$CHANGELOG.md.tmp" "$CHANGELOG_FILE"
    echo "✅ CHANGELOG.md generated successfully!"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not a git repository."
    exit 1
fi

generate_changelog
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from your project's git history.

## Usage

