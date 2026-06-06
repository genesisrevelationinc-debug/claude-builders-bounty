#!/bin/bash

# Function to determine commit type based on commit message
get_commit_type() {
    local message="$1"
    # Convert message to lowercase for case-insensitive matching
    local lower_message=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    
    # Check for keywords in the commit message
    if echo "$lower_message" | grep -q -E '\b(add|feature|implement)\b'; then
        echo "Added"
    elif echo "$lower-message" | grep -q -E '\b(fix|bugfix|resolve|solve)\b'; then
        echo "Fixed"
    elif echo "$lower_message" | grep -q -E '\b(change|update|modify)\b'; then
        echo "Changed"
    elif echo "$lower_message" | grep -q -E '\b(remove|delete|obsolete)\b'; then
        echo "Removed"
    else
        echo "Changed"
    fi
}

# Get the last tag
last_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If there are no tags, get all commits
if [ -z "$last_tag" ]; then
    commits=$(git log --pretty=format:"%s")
else
    # Get commits since last tag
    commits=$(git log $last_tag..HEAD --pretty=format:"%s")
fi

# Create or clear the changelog file
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

# Add unreleased section
echo "## [Unreleased]" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Process commits and categorize them
echo "$commits" | while read -r commit; do
    # Skip empty lines
    if [ -n "$commit" ]; then
        type=$(get_commit_type "$commit")
        echo "- $type: $commit" >> CHANGELOG.md
    fi
done

echo "" >> CHANGELOG.md
echo "Generated on: $(date)" >> CHANGELOG.md

echo "CHANGELOG.md has been generated."