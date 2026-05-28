#!/bin/bash

# Exit on any error
set -e

# Get the latest git tag
latest_tag=$(git describe --tags $(git rev-list --tags --max-count=1))

# If no tags exist, default to initial commit
if [ -z "$latest_tag" ]; then
  latest_tag=$(git rev-list --max-parents=0 --abbrev-commit HEAD)
fi

# Get commit hash of the latest tag
from_commit=$(git rev-parse $latest_tag)

# Get all commits since the latest tag
since_last_tag=$(git rev-list --oneline $from_commit..HEAD)

# Create a temporary file to hold commit messages
tmp_file=$(mktemp)

# Write since_last_tag to temp file, one line per commit
echo "$since_last_tag" > "$tmp_file"

# Categorize commits
added_commits=$(grep -c "add" "$tmp_file")
fixed_commits=$(grep -c "fix" "$tmp_file")
changed_commits=$(grep -c "change" "$tmp_file")
removed_commits=$(grep -c "remove" "$tmp_file")

if [ $added_commits -gt 0 ]; then
  echo "### Added" >> CHANGELOG.md
  echo "$added_commits" >> CHANGELOG.md
fi

if [ $fixed_commits -gt 0 ]; then
  echo "### Fixed" >> CHANGELOG.md
  echo "$fixed_comminks" >> CHANGELOG.md
fi

if [ $changed_commits -gt 0 ]; then
  echo "### Changed" >> CHANGELOG.md
  echo "$changed_commits" >> CHANGELOG.md
fi

if [ $removed_commits -gt 0 ]; then
  echo "### Removed" >> CHANGELOG.md
  echo "$removed_commits" >> CHANGELOG.md
fi

# Clean up
rm "$tmp_file"

# Output the changelog
cat CHANGELOG.md

# Remove temp file
rm CHANGELOG.md

# Exit with success
exit 0