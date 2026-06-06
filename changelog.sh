#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Exit on any error
set -e

# Get the last tag, or initial commit if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)

# Get commits since last tag, excluding merge commits
COMMITS=$(git log $LAST_TAG..HEAD --no-merges --oneline)

# If there are no new commits, exit
if [ -z "$COMMITS" ];  then
    echo "No commits since last tag ($LAST_TAG)"
    exit 0
fi

# Create a temporary file to store changelog entries
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Function to categorize commit based on conventional commit prefixes
categorize_commit() {
    local commit_message="$1"
    if [[ $commit_message == feat:* ]] || [[ $commit_message == feat(* ]]; then
        echo "Added"
    elif [[ $commit_message == fix:* ]] || [[ $commit_message == fix(* ]]; then
        echo "Fixed"
    elif [[ $commit_message == refactor:* ]] || [[ $commit_message == refactor(* ]] || [[ $commit_message == chore(* ]] || [[ $commit_message == perf:* ]]; then
        echo "Changed"
    elif [[ $commit_message ==-remove:* ]] || [[ $commit_message == remove(* ]] || [[ $commit_message == delete:* ]] || [[ $commit_message == delete(* ]]; then
        echo "Removed"
    else
        echo "Changed"  # Default category
    fi
}

# Process each commit and categorize
echo "$COMMITS" | while read -r commit; do
    if [ -n "$commit" ]; then
        # Extract commit message (everything after the commit hash)
        commit_msg=$(echo "$commit" | sed 's/^[a-z0-9]*\ *//')
        category=$(categorize_commit "$commit_msg")
        echo "### $category" >> "$TEMP_FILE"
        echo "* $commit_msg" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
    fi
done

# Generate the changelog file
echo "## Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

# Group entries by category
while IFS= read -r line; do
    if [[ $line == "### Added" ]] || [[ $line == "### Fixed" ]] || [[ $line == "### Changed" ]] || [[ $line == "### Removed" ]]; then
        echo "$line" >> CHANGELOG.md
    elif [[ $line == "* "* ]]; then
        echo "$line" >> CHANGELOG.md
    elif [[ -n "$line" ]]; then
        echo "" >> CHANGELOG.md
        echo "$line" >> CHANGELOG.md
    fi
done < "$TEMP_FILE"

echo "CHANGELOG.md has been generated."