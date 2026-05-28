#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# This script automatically generates a structured CHANGELOG.md file
# by analyzing the git commit history since the last tag.
#
# Usage:
#   bash changelog.sh
#
# Requirements:
#   - git

set -e  # Exit on any error

# Configuration
CHANGELOG_FILE="CHANGELOG.md"
TEMP_LOG_FILE=$(mktemp)

# Clean up temporary file on exit
trap 'rm -f "$TEMP_LOG_FILE"' EXIT

# Get the latest tag, or use initial commit if no tags exist
if latest_tag=$(git describe --tags --abbrev=0 2>/dev/null); then
    echo "Generating changelog since last tag: $latest_tag"
    git log --no-merges --pretty=format:"- %s (%h)" "$latest_tag..HEAD" > "$TEMP_LOG_FILE"
else
    echo "No tags found. Generating changelog for all commits."
    git log --no-merges --pretty=format:"- %s (%h)" > "$TEMP_LOG_FILE"
fi

# Initialize category arrays
declare -a added_arr=()
declare -a fixed_arr=()
declare -a changed_arr=()
declare -a removed_arr=()

# Categorize commits based on keywords in the commit message
while IFS= read -r line; do
    # Convert to lowercase for case-insensitive matching
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    
    if [[ $lower_line == *"add"* ]] || [[ $lower_line == *"feat"* ]] || [[ $lower_line == *"new"* ]]; then
        added_arr+=("$line")
    elif [[ $lower_line == *"fix"* ]] || [[ $lower_line == *"bug"* ]] || [[ $lower_line == *"repair"* ]]; then
        fixed_arr+=("$line")
    elif [[ $lower_line == *"change"* ]] || [[ $lower_line == *"update"* ]] || [[ $lower_line == *"modify"* ]] || [[ $lower_line == *"refactor"* ]]; then
        changed_arr+=("$line")
    elif [[ $lower_line == *"remove"* ]] || [[ $lower_line == *"delete"* ]] || [[ $lower_line == *"rm"* ]]; then
        removed_arr+=("$line")
    else
        # Default to Added if no keywords match
        added_arr+=("$line")
    fi
done < "$TEMP_LOG_FILE"

# Get current date for the new version entry
current_date=$(date +"%Y-%m-%d")

# Function to create a new Unreleased section
create_unreleased_section() {
    cat << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
$(printf '%s\n' "${added_arr[@]}")

### Fixed
$(printf '%s\n' "${fixed_arr[@]}")

### Changed
$(printf '%s\n' "${changed_arr[@]}")

### Removed
$(printf '%s\n' "${removed_arr[@]}")

EOF
}

# Generate the new changelog content
create_unreleased_section > "$CHANGELOG_FILE"

# Append previous changelog content if it exists (excluding the header and Unreleased section)
if [ -f "$CHANGELOG_FILE".bak ]; then
    # Remove the header and Unreleased section from the backup
    sed '1,/^## \[Unreleased\]/d' "$CHANGELOG_FILE".bak >> "$CHANGELOG_FILE"
    rm -f "$CHANGELOG_FILE".bak
fi

echo "Changelog generated successfully in $CHANGELOG_FILE"