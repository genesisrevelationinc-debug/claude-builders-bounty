#!/bin/bash

# Exit on any error
set -e

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the latest tag
LATEST_TAG=$(git describe --tags `git tag --sort=taggerdate | tail -1`)

# If there are no tags, use empty string
if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG=""
fi

# Generate the changelog
echo "Generating changelog since last tag: $LATEST_TAG"
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

if [ -n "$LATEST_TAG" ]; then
    # Get commits since last tag
    COMMITS=$(git log --pretty=format:"%h %s" $LATEST_TAG..HEAD)
else
    # Get all commits
    COMMITS=$(git log --pretty=format:"%h %s")
fi

# Write the commits to the changelog
echo "$COMMITS" >> CHANGELOG.md

# Categorize commits
echo "## [Unreleased]" > tmp_changelog.md
echo "" >> tmp_changelog.md

while read -r line; do
    if [[ $line == *"fix:"* ]]; then
        echo "### Fixed" >> tmp_changelog.md
        echo "$line" >> tmp_changelog.md
    elif [[ $line == *"feat:"* ]] || [[ $line == *"add:"* ]]; then
        echo "### Added" >> tmp_changelog.md
        echo "$line" >> tmp_changelog.md
    elif [[ $line == *"change:"* ]] || [[ $line == *"refactor:"* ]]; then
        echo "### Changed" >> tmp_changelog.md
        echo "$line" >> tmp_changelog.md
    elif [[ $line == *"remove:"* ]] || [[ $line == *"delete:"* ]]; then
        echo "### Removed" >> tmp_changelog.md
        echo "$line" >> tmp_changelog.md
    else
        echo "### Other" >> tmp_changelog.md
        echo "$line" >> tmp_changelog.md
    fi
done < <(git log --pretty=format:"%s" $LATEST_TAG..HEAD)

cat tmp_changelog.md >> CHANGELOG.md
rm tmp_changelog.md

echo "Changelog generated successfully!"