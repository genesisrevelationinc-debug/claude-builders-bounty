#!/bin/bash

# Generate a structured CHANGELOG.md from git history

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the latest tag or first commit if no tags exist
if git describe --tags --abbrev=0 >/dev/null 2>&1; then
    LAST_TAG=$(git describe --tags --abbrev=0)
    echo -e "${BLUE}Generating changelog since tag: $LAST_TAG${NC}"
    COMMITS_RANGE="$LAST_TAG..HEAD"
else
    FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
    echo -e "${BLUE}No tags found. Generating changelog since first commit: $FIRST_COMMIT${NC}"
    COMMITS_RANGE="$FIRST_COMMIT..HEAD"
fi

# Create temporary file for commit messages
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Get commits in the specified range
git log --pretty=format:"%s" "$COMMITS_RANGE" > "$TEMP_FILE"

# Initialize arrays for each category
declare -a ADDED_ARRAY
declare -a FIXED_ARRAY
declare -a CHANGED_ARRAY
declare -a REMOVED_ARRAY

# Categorize commits based on prefixes
while IFS= read -r line; do
    if [[ $line == feat:* ]] || [[ $line == add:* ]]; then
        ADDED_ARRAY+=("${line#*: }")
    elif [[ $line == fix:* ]]; then
        FIXED_ARRAY+=("${line#*: }")
    elif [[ $line == change:* ]] || [[ $line == update:* ]]; then
        CHANGED_ARRAY+=("${line#*: }")
    elif [[ $line == remove:* ]] || [[ $line == delete:* ]]; then
        REMOVED_ARRAY+=("${line#*: }")
    fi
done < "$TEMP_FILE"

# Generate new changelog content
NEW_CHANGELOG=$(mktemp)

# Get current date and version
DATE=$(date +%Y-%m-%d)
VERSION="[$(git describe --tags --abbrev=0 --always)]"

{
    echo "# Changelog"
    echo ""
    echo "## $VERSION - $DATE"
    echo ""
    
    if [ ${#ADDED_ARRAY[@]} -gt 0 ]; then
        echo "### Added"
        for item in "${ADDED_ARRAY[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    if [ ${#FIXED_ARRAY[@]} -gt 0 ]; then
        echo "### Fixed"
        for item in "${FIXED_ARRAY[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    if [ ${#CHANGED_ARRAY[@]} -gt 0 ]; then
        echo "### Changed"
        for item in "${CHANGED_ARRAY[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
    
    if [ ${#REMOVED_ARRAY[@]} -gt 0 ]; then
        echo "### Removed"
        for item in "${REMOVED_ARRAY[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
} > "$NEW_CHANGELOG"

# Prepend new content to existing changelog or create new one
if [ -f "CHANGELOG.md" ]; then
    # Save the existing content without the first line (header)
    tail -n +2 "CHANGELOG.md" > "CHANGELOG.md.tmp"
    # Add new content and then the rest
    cat "$NEW_CHANGELOG" "CHANGELOG.md.tmp" > "CHANGELOG.md"
    rm "CHANGELOG.md.tmp"
else
    cat "$NEW_CHANGELOG" > "CHANGELOG.md"
fi

echo -e "${GREEN}Changelog generated successfully!${NC}"