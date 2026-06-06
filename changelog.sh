#!/bin/bash

# Exit on any error
set -e

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# If there are no tags, use the initial commit
if [ "$LAST_TAG" = "v0.0.0" ]; then
    LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit messages since last tag
COMMITS_SINCE_TAG=$(git log --oneline "$LAST_TAG"..HEAD)

# If no commits since last tag, exit
if [ -z "$COMMITS_SINCE_TAG" ]; then
    echo "No commits since last tag ($LAST_TAG)"
    exit 0
fi

# Create temporary file for changelog
TEMP_FILE=$(mktemp)
echo "## Changelog" > "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "### Added" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "### Fixed" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "### Changed" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "### Removed" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Process commits and categorize them
echo "$COMMITS_SINCE_TAG" | while read -r line; do
    # Here we would normally categorize based on commit message
    # For now, we'll just add all to "Changed" section as a placeholder
    echo "* $line" >> "$TEMP_FILE"
done

# Move the temporary file to CHANGELOG.md
mv "$TEMP_FILE" CHANGELOG.md
echo "CHANGELOG.md has been generated."