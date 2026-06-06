#!/bin/bash

# changelog.sh - A script to generate a structured CHANGELOG.md from git history

# Get the latest git tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tags are found, use the initial commit
if [ -z "$latest_tag" ]; then
    latest_tag=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit history since the latest tag
if [ -z "$latest_tag" ]; then
    commit_history=$(git log --pretty=format:"%s" --reverse)
else
    commit_history=$(git log --pretty=format:"%s" $latest_tag..HEAD --reverse)
fi

# Create a temporary file for commit messages
temp_file=$(mktemp)
echo "$commit_history" > "$temp_file"

# Initialize sections
added_items=""
fixed_items=""
changed_items=""
removed_items=""

# Process each commit message
while IFS= read -r line; do
    # Categorize based on commit message prefix
    if [[ $line == "Merge pull request"* ]] || [[ $line == "Merge branch"* ]]; then
        # Skip merge commits
        continue
    elif [[ $line == "Add"* ]] || [[ $line == "add"* ]] || [[ $line == *"add"* ]]; then
        added_items+="- $line"$'\n'
    elif [[ $line == "Fix"* ]] || [[ $line == "fix"* ]] || [[ $line == *"fix"* ]]; then
        fixed_items+="- $line"$'\n'
    elif [[ $line == "Change"* ]] || [[ $line == "change"* ]] || [[ $line == *"change"* ]] || [[ $line == "Update"* ]] || [[ $line == "update"* ]]; then
        changed_items+="- $line"$'\n'
    elif [[ $line == "Remove"* ]] || [[ $line == "remove"* ]] || [[ $line == *"remove"* ]]; then
        removed_items+="- $line"$'\n'
    else
        # Default to "Changed" if no specific category is found
        changed_items+="- $line"$'\n'
    fi
done < "$temp_file"

# Write to CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

if [ -n "$added_items" ]; then
    echo "## Added" >> CHANGELOG.md
    echo "$added_items" >> CHANGELOG.md
fi

if [ -n "$fixed_items" ]; then
    echo "## Fixed" >> CHANGELOG.md
    echo "$fixed_items" >> CHANGELOG.md
fi

if [ -n "$changed_items" ]; then
    echo "## Changed" >> CHANGELOG.md
    echo "$changed_items" >> CHANGELOG.md
fi

if [ -n "$removed_items" ]; then
    echo "## Removed" >> CHANGELOG.md
    echo "$removed_items" >> CHANGELOG.md
fi

rm "$temp_file"