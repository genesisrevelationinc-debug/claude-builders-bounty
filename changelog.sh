#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print usage
print_usage() {
    echo -e "${BLUE}Usage:${NC} bash changelog.sh"
    echo -e "${BLUE}Output:${NC} Generates CHANGELOG.md in current directory"
    echo -e "${BLUE}Requirements:${NC} Must be run in a git repository"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error:${NC} Not a git repository"
    print_usage
    exit 1
fi

# Get the last git tag or default to first commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LAST_TAG" ]; then
    echo -e "${YELLOW}No tags found, using first commit as starting point${NC}"
    LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

echo -e "${GREEN}Generating changelog from commits since: $LAST_TAG${NC}"

# Get commits since last tag
COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s" --no-merges)

# Create temporary files for each category
ADDED_FILE=$(mktemp)
FIXED_FILE=$(mktemp)
CHANGED_FILE=$(mktemp)
REMOVED_FILE=$(mktemp)

# Process each commit
while IFS= read -r commit; do
    # Convert to lowercase for matching
    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    # Categorize based on keywords
    if [[ $lower_commit == *"add"* ]] || [[ $lower_commit == *"new"* ]] || [[ $lower_commit == *"implement"* ]] || [[ $lower_commit == *"include"* ]]; then
        echo "- $commit" >> "$ADDED_FILE"
    elif [[ $lower_commit == *"fix"* ]] || [[ $lower_commit == *"resolve"* ]] || [[ $lower_commit == *"correct"* ]]; then
        echo "- $commit" >> "$FIXED_FILE"
    elif [[ $lower_commit == *"remove"* ]] || [[ $lower_commit == *"delete"* ]] || [[ $lower_commit == *"eliminate"* ]]; then
        echo "- $commit" >> "$REMOVED_FILE"
    else
        # Default to Changed category
        echo "- $commit" >> "$CHANGED_FILE"
    fi
done <<< "$COMMITS"

# Get version from tag or default
VERSION=${LAST_TAG#v}
if [ -z "$VERSION" ]; then
    VERSION="Unreleased"
fi

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "## [$VERSION] - $(date +%Y-%m-%d)"
    
    # Add Added section if exists
    if [ -s "$ADDED_FILE" ]; then
        echo ""
        echo "### Added"
        cat "$ADDED_FILE"
    fi
    
    # Add Fixed section if exists
    if [ -s "$FIXED_FILE" ]; then
        echo ""
        echo "### Fixed"
        cat "$FIXED_FILE"
    fi
    
    # Add Changed section if exists
    if [ -s "$CHANGED_FILE" ]; then
        echo ""
        echo "### Changed"
        cat "$CHANGED_FILE"
    fi
    
    # Add Removed section if exists
    if [ -s "$REMOVED_FILE" ]; then
        echo ""
        echo "### Removed"
        cat "$REMOVED_FILE"
    fi
    
    echo ""
} > CHANGELOG.md

# Clean up temp files
rm "$ADDED_FILE" "$FIXED_FILE" "$CHANGED_FILE" "$REMOVED_FILE"

echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"