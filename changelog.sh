#!/bin/bash

# Exit on any error
set -e

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# If no tags exist, get all commits
if [ -z "$latest_tag" ]; then
    echo "No tags found. Using initial commit as reference."
    commits_since=$(git rev-list --max-parents=0 HEAD)
    commit_range="$commits_since..HEAD"
else
    echo "Latest tag: $latest_tag"
    commit_range="$latest_tag..HEAD"
fi

# Get commits in the specified range
commits=$(git log --no-merges "$commit_range" --pretty=format:"%s" --reverse)

if [ -z "$commits" ]; then
    echo "# Changelog" > CHANGELOG.md
    echo "No commits found since $latest_tag" > /dev/null
    exit 0
fi

# Create or clear the changelog file
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

# Add the tag name as the new version
echo "## [$(git describe --tags --abbrev=0)] - $(date +'%Y-%m-%d')" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Categorize commits
added=$(echo "$commits" | grep -E "^(add|feat|new)" | sed 's/^/ - /')
fixed=$(echo "$commits" | grep -E "^(fix|fixed|fixes)" | sed 's/^/ - /')
changed=$(echo "$commits" | grep -E "^(change|update|refactor|refactored)" | sed 's/^/ - /')
removed=$(echo "$commits" | grep -E "^(remove|delete|rm)" | sed 's/^/ - /')

# Write categorized commits to the changelog
if [ -n "$added" ]; then
    echo "### Added" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "$added" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

if [ -n "$fixed" ]; then
    echo "### Fixed" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "$fixed" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

if [ -n "$changed" ]; then
    echo "### Changed" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
    echo "$changed" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
fi

if [ -n "$removed" ]; then
    echo "### Removed" >> CHANGELOG.md
    echo "$removed" >> CHANGELOG.md
fi