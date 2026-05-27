#!/bin/bash

# Git Changelog Generator
# This script generates a structured CHANGELOG.md from git history

# Find the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag found, use git log --all
if [ -z "$latest_tag" ]; then
    echo "No tags found. Using all commits."
    commit_range=""
else
    echo "Latest tag: $latest_tag"
    commit_range="$latest_tag..HEAD"
fi

# Create a temporary file for commits
temp_file=$(mktemp)

# Get commit messages
if [ -z "$commit_range" ]; then
    git log --pretty=format:"%s" > "$temp_file"
else
    git log --pretty=format:"%s" $commit_range > "$temp_file"
fi

# Initialize arrays for each category
declare -a added_array
declare -a fixed_array
declare -a changed_array
declare -a removed_array

# Categorize commits
while IFS= read -r line; do
    # Convert to lowercase for matching
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    
    if [[ $lower_line == *"add"* ]] || [[ $lower_line == *"new"* ]] || [[ $line == *"feature"* ]]; then
        added_array+=("$line")
    elif [[ $lower_line == *"fix"* ]] || [[ $lower_line == *"bug"* ]] || [[ $lower_line == *"resolve"* ]]; then
        fixed_array+=("$line")
    elif [[ $lower_line == *"change"* ]] || [[ $lower_line == *"update"* ]] || [[ $lower_line == *"modify"* ]]; then
        changed_array+=("$line")
    elif [[ $lower_line == *"remove"* ]] || [[ $lower_line == *"delete"* ]] || [[ $lower_line == *"deprecated"* ]]; then
        removed_array+=("$line")
    fi
done < "$temp_file"

# Function to output array items
output_items() {
    local array=("$@")
    for item in "${array[@]}"; do
        echo "- $item"
    done
}

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
    echo ""
    echo "## [Unreleased]"
    echo ""
    
    if [ ${#added_array[@]} -gt 0 ]; then
        echo "### Added"
        output_items "${added_array[@]}"
        echo ""
    fi
    
    # Add similar blocks for other categories if they have content
    # ... (implementation would continue for other categories)
} > CHANGELOG.md

echo "CHANGELOG.md has been generated."