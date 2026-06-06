#!/bin/bash

# Get the latest tag or set to empty if none exists
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# Determine the range of commits to analyze
if [ -z "$latest_tag" ]; then
    commit_range="HEAD"
else
    commit_range="$latest_tage HEAD"
fi

# Create a temporary file to store the changelog
temp_file=$(mktemp)

# Function to add a commit to a section
add_to_changelog() {
    section=$1
    line=$2
    
    # Add section header if it doesn't exist yet
    if ! grep -q "### $section" "$temp_file"; then
        echo "### $section" >> "$temp_file"
    fi
    
    # Add the line to the appropriate section
    echo "- $line" >> "$temp_file"
}

# Initialize the changelog file with header
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [Unreleased]" >> CHANGELOG.md

# Create temporary file
touch "$temp_file"

# Process each commit
if [ "$commit_range" = "HEAD" ]; then
    # If no tags, process all commits
    git log --pretty=format:"%s" | while read -r line; do
        process_commit "$line"
    done
else
    # Process commits since last tag
    git log "$latest_tag..HEAD" --pretty=format:"%s" | while read -r line; do
        process_commit "$line"
    done
fi

# Function to process a commit message
process_commit() {
    local line="$1"
    
    # Categorize based on prefix
    if [[ $line == feat:* ]] || [[ $line == add:* ]]; then
        add_to_changelog "Added" "${line#*: }"
    elif [[ $line == fix:* ]] || [[ $line == bug:* ]]; then
        add_to_changelog "Fixed" "${line#*: }"
    elif [[ $line == change:* ]] || [[ $line == refactor:* ]]; then
        add_to_changelog "Changed" "${line#*: }"
    elif [[ $line == remove:* ]] || [[ $line == delete:* ]]; then
        add_to_changelog "Removed" "${line#*: }"
    else
        # Default categorization if no prefix match
        add_to_changelog "Other" "$line"
    fi
}

# Sort and organize the sections
if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
    # Process the temporary file to organize sections properly
    # This is a simplified version - a full implementation would need better section handling
    cat "$temp_file" >> CHANGELOG.md
fi

# Clean up
rm -f "$temp_file"

echo "Changelog generated in CHANGELOG.md"