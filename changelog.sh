#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Get the last tag or initial commit if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || git rev-list --max-parents=0 HEAD)

# Get commit messages since last tag
COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s" --no-merges 2>/dev/null || git log --pretty=format:"%s" --no-merges)

# Create or clear CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

# Function to categorize commits
categorize_commits() {
    local commits="$1"
    local added=""
    local changed=""
    local fixed=""
    local removed=""
    
    while IFS= read -r commit; do
        # Convert to lowercase for case-insensitive matching
        local lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
        
        if [[ $lower_commit == *"add"* ]] || [[ $lower_commit == *"new"* ]] || [[ $lower_commit == *"feature"* ]]; then
            added+="- $commit"$'\n'
        elif [[ $lower_commit == *"change"* ]] || [[ $lower_commit == *"update"* ]] || [[ $lower_commit == *"modify"* ]]; then
            changed+="- $commit"$'\n'
        elif [[ $lower_commit == *"fix"* ]] || [[ $lower_comment == *"bug"* ]] || [[ $lower_commit == *"correct"* ]]; then
            fixed+="- $commit"$'\n'
        elif [[ $lower_commit == *"remove"* ]] || [[ $lower_commit == *"delete"* ]] || [[ $lower_commit == *"deprecated"* ]]; then
            removed+="- $commit"$'\n'
        else
            # Default to "Changed" if no keywords match
            changed+="- $commit"$'\n'
        fi
    done <<< "$commits"
    
    echo "## [Unreleased]" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
    [[ -n "$added" ]] && echo "### Added" >> CHANGELOG.md && echo "$added" >> CHANGELOG.md
    [[ -n "$fixed" ]] && echo "### Fixed" >> CHANGELOG.md && echo "$fixed" >> CHANGELOG.md
    [[ -n "$changed" ]] && echo "### Changed" >> CHANGELOG.md && echo "$changed" >> CHANGELOG.md
    [[ -n "$removed" ]] && echo "### Removed" >> CHANGELOG.md && echo "$removed" >> CHANGELOG.md
}

categorize_commits "$COMMITS"