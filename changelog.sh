#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tags are found, use the initial commit
if [ -z "$latest_tag" ]; then
  latest_tag=$(git rev-list --max-parents=0 HEAD)
fi

# Get the commit hash of the latest tag
tag_commit=$(git rev-parse "$latest_tag" 2>/dev/null)

# If we can't get the tag commit, default to HEAD
if [ -z "$tag_commit" ]; then
  tag_commit="HEAD"
fi

# Get commit messages between last tag and HEAD
commits=$(git log --oneline $tag_commit..HEAD)

# Create or overwrite CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [Unreleased]" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Initialize categories
added=()
fixed=()
changed=()
removed=()

# Process each commit
while IFS= read -r line; do
  if [[ $line == *"add"* ]] || [[ $line == *"new"* ]] || [[ $line == *"create"* ]]; then
    added+=("$line")
  elif [[ $line == *"fix"* ]] || [[ "line" == *"resolve"* ]] || [[ "line" == *"close"* ]]; then
    fixed+=("$line")
  elif [[ $line == *"change"* ]] || [[ $line == *"update"* ]] || [[ $line == *"modify"* ]]; then
    changed+=("$line")
  elif [[ $line == *"remove"* ]] || [[ $line == *"delete"* ]] || [[ $line == *"delet"* ]]; then
    removed+=("$line")
  fi
done <<< "$commits"

# Write categorized commits to changelog
echo "### Added" >> CHANGELOG.md
for item in "${added[@]}"; do
  echo "- $item" >> CHANGELOG.md
done

echo "" >> CHANGELOG.md
echo "### Fixed" >> CHANGELOG.md
for item in "${fixed[@]}"; do
  echo "- $item" >> CHANGELOG.md
done

echo "" >> CHANGELOG.md
echo "### Changed" >> CHANGELOG.md
for item in "${changed[@]}"; do
  echo "- $item" >> CHANGELOG.md
done

echo "" >> CHANGELOG.md
echo "### Removed" >> CHANGELOG.md
for item in "${removed[@]}"; do
  echo "- $item" >> CHANGELOG.md
done