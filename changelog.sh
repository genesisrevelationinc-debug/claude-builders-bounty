#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --reverse 2>/dev/null || true
    else
        git log --pretty=format:"%s" --reverse 2>/dev/null || true
    fi
}

# Categorize a commit message into a section
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes
    if echo "$lower" | grep -qE '^(feat|add|create|introduce)'; then
        echo "Added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "Fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|revert)'; then
        echo "Removed"
    elif echo "$lower" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade)'; then
        echo "Changed"
    else
        # Keyword-based fallback
        if echo "$lower" | grep -qE '\b(add|added|adding|introduce|introduces|new)\b'; then
            echo "Added"
        elif echo "$lower" | grep -qE '\b(fix|fixed|fixes|fixing|resolve|resolves|resolved|bug|patch)\b'; then
            echo "Fixed"
        elif echo "$lower" | grep -qE '\b(remove|removed|removes|removing|delete|deleted|deletes|dropping|drop|revert|reverts|reverted)\b'; then
            echo "Removed"
        elif echo "$lower" | grep -qE '\b(update|updated|updates|updating|change|changed|changes|changing|modify|modified|modifies|modifying|refactor|refactored|refactoring|improve|improved|improves|improving|enhance|enhanced|enhances|enhancing|upgrade|upgraded|upgrades|upgrading)\b'; then
            echo "Changed"
        else
            echo "Changed"  # Default category
        fi
    fi
}

# Clean commit message for changelog (remove conventional commit prefix)
clean_message() {
    local msg="$1"
    # Remove conventional commit prefix like "feat:", "fix:", etc.
    echo "$msg" | sed -E 's/^[a-z]+(\([^)]*\))?:[[:space:]]*//i'
}

# Generate the changelog
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
    declare -A categories
    categories["Added"]=""
    categories["Fixed"]=""
    categories["Changed"]=""
    categories["Removed"]=""
    
    # Process each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize "$commit")
        local clean_msg
        clean_msg=$(clean_message "$commit")
        
        categories["$category"]+="- $clean_msg"$'\n'
    done <<< "$commits"
    
    # Write changelog
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        
        local version_date
        version_date=$(date +%Y-%m-%d)
        echo "## [Unreleased] - $version_date"
        echo ""
        
        for cat in "Added" "Changed" "Fixed" "Removed"; do
            if [ -n "${categories[$cat]}" ]; then
                echo "### $cat"
                echo ""
                echo -n "${categories[$cat]}"
                echo ""
            fi
        done
    } > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "Generated $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Usage

