#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# This script generates a changelog by:
# 1. Getting all tags sorted by version
# 2. For each tag, getting the commit messages since the previous tag
# 3. Categorizing commits based on conventional commit prefixes
# 4. Writing the changelog in markdown format

set -e

# Configuration
CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE="/tmp/changelog_temp.md"

# Function to get the latest tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Function to get the previous tag
get_previous_tag() {
    local current_tag="$1"
    if [ -n "$current_tag" ]; then
        git describe --tags --abbrev=0 "$current_tag^" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Function to categorize commit messages
categorize_commit() {
    local commit_message="$1"
    case "$commit_message" in
        fix*|fixed*|fixes*|fixed*)
            echo "Fixed";;
        feat*|feature*|add*|added*|adds*)
            echo "Added";;
        change*|changed*|changes*|refactor*|refactored*)
            echo "Changed";;
        remove*|removed*|removes*)
            echo "Removed";;
        *)
            echo "Other";;
    esac
}

# Main script
main() {
    # Get the latest and previous tags
    local latest_tag
    local previous_tag
    latest_tag=$(get_latest_tag)
    previous_tag=$(get_previous_tag "$latest_tag")
    
    # If no previous tag found, use the initial commit
    if [ -z "$previous_tag" ] && [ -n "$latest_tag" ]; then
        previous_tag=$(git rev-list --max-parents=0 HEAD)
    fi
    
    # Get commits between tags
    local commits
    if [ -n "$latest_tag" ] && [ -n "$previous_tag" ]; then
        commits=$(git log "$previous_tag..$latest0_tag" --oneline 2>/dev/null)
    else
        commits=$(git log --oneline 2>/dev/null)
    fi
    
    # Create a temporary file to write the changelog
    echo "# Changelog" > "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
    echo "## [$(get_latest_tag)] - $(date +%Y-%m-%d)" >> "$TEMP_FILE"
    
    # Process commits and categorize them
    while IFS= read -r commit; do
        if [ -n "$commit" ]; then
            local category
            category=$(categorize_commit "$commit")
            echo "### $category" >> "$TEMP_FILE"
            echo "- $commit" >> "$TEMP_FILE"
        fi
    done <<< "$commits"
    
    # If CHANGELOG.md doesn't exist, create it
    if [ ! -f "$CHANGELOG_FILE" ]; then
        cp "$TEMP_FILE" "$CHANGELOG_FILE"
        echo "Created $CHANGELOG_FILE"
    else
        echo "Updated $CHANGELOG_FILE"
    fi
    
    # Clean up
    rm -f "$TEMP_FILE"
}

# Run the main function
main