#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag exists, get all commits from the beginning
if [ -z "$LATEST_TAG" ]; then
    COMMIT_RANGE=""
    echo "No tags found. Generating changelog for all commits."
else
    echo "Generating changelog since tag: $LATEST_TAG"
    COMMIT_RANGE="$LATEST_TAG..HEAD"
fi

# Create a temporary file for commit messages
TEMP_FILE=$(mktemp)

# Get commit messages excluding merge commits
if [ -z "$COMMIT_RANGE" ]; then
    git log --no-merges --pretty=format:"- %s" > "$TEMP_FILE"
else
    git log "$COMMIT_RANGE" --no-merges --pretty=format:"- %s" > "$TEMP_FILE"
fi

# Create or clear CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)," >> CHANGELOG.md
echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)." >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [Unreleased]" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Initialize category arrays
declare -a added=()
declare -a changed=()
declare -a fixed=()
declare -a removed=()

# Categorize commits based on keywords
while IFS= read -r line; do
    # Remove the leading dash and space
    commit_message=${line#"- "}
    
    # Convert to lowercase for case-insensitive matching
    lower_message=$(echo "$commit_message" | tr '[:upper:]' '[:lower:]')
    
    # Categorize based on keywords
    if [[ $lower_message == *"add"* ]] || [[ $lower_message == *"new"* ]] || [[ $lower_message == *"implement"* ]] || [[ $lower_message == *"feature"* ]]; then
        added+=("$line")
    elif [[ $lower_message == *"change"* ]] || [[ $lower_message == *"update"* ]] || [[ $lower_message == *"modify"* ]] || [[ $lower_message == *"improve"* ]]; then
        changed+=("$line")
    elif [[ $lower_message == *"fix"* ]] || [[ $lower_message == *"resolve"* ]] || [[ $lower_message == *"correct"* ]] || [[ $lower_message == *"bug"* ]]; then
        fixed+=("$line")
    elif [[ $lower_message == *"remove"* ]] || [[ $lower_message == *"delete"* ]] || [[ $lower_message == *"drop"* ]]; then
        removed+=("$line")
    else
        # Default to "added" if no keywords match
        added+=("$line")
    fi
done < "$TEMP_FILE"

# Write categorized changes to CHANGELOG.md
if [ ${#added[@]} -gt 0 ]; then
    echo "### Added" >> CHANGELOG.md
    printf '%s\n' "${added[@]}" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

if [ ${#fixed[@]} -gt 0 ]; then
    echo "### Fixed" >> CHANGELOG.md
    printf '%s\n' "${fixed[@]}" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

if [ ${#changed[@]} -gt 0 ]; then
    echo "### Changed" >> CHANGELOG.md
    printf '%s\n' "${changed[@]}" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

if [ ${#removed[@]} -gt 0 ]; then
    echo "### Removed" >> CHANGELOG.md
    printf '%s\n' "${removed[@]}" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

# Clean up
rm "$TEMP_FILE"

echo "CHANGELOG.md has been generated."