#!/bin/bash

# Generate a structured CHANGELOG.md from git history

# Configuration
CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE="/tmp/changelog_commits.txt"

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# Get commits since last tag or all commits if no tags exist
if [ -z "$LAST_TAG" ]; then
    echo "No tags found. Using all commits."
    git log --oneline > "$TEMP_FILE"
else
    echo "Commits since tag: $LAST_TAG"
    git log $LAST_TAG..HEAD --oneline > "$TEMP_FILE"
fi

# Initialize arrays for categorization
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()

# Categorize commits based on keywords
while IFS= read -r line; do
    if [[ $line =~ [Aa]dd|[Nn]ew|[Ff]eature ]]; then
        ADDED+=("$line")
    elif [[ $line =~ [Ff]ix|[Bb]ug|[Rr]esolve ]]; then
        FIXED+=("$line")
    elif [[ $line =~ [Rr]emove|[Dd]elete|[Rr]m ]]; then
        REMOVED+=("$line")
    else
        CHANGED+=("$line")
    fi
done < "$TEMP_FILE"

# Generate the changelog content
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "## Added"
        for item in "${ADDED[@]}"; do echo "- $item"; done
        echo ""
    fi
    
    if [ ${#FIXED[@]} -gt 0 ]; then
        echo "## Fixed"
        for item in "${FIXED[@]}"; do echo "- $item"; done
        echo ""
    fi
    
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "## Changed"
        for item in "${CHANGED[@]}"; do echo "- $item"; done
        echo ""
    fi
    
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "## Removed"
        for item in "${REMOVED[@]}"; do echo "- $item"; done
        echo ""
    fi
} > "$CHANGELOG_FILE"

echo "CHANGELOG.md has been generated successfully."