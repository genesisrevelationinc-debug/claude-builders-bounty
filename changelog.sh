#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag is found, use the first commit
if [ -z "$latest_tag" ]; then
  latest_tag=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit hash of latest tag
latest_tag_commit=$(git rev-parse "$latest_tag" 2>/dev/null)

# If no tag exists, start from the first commit
if [ -z "$latest_tag_commit" ]; then
  latest_tag_commit=$(git rev-list --max-parents=0 HEAD)
fi

if [ -z "$latest_tag_commit" ]; then
  echo "Error: Could not find a valid commit to start from."
  exit 1
fi

# Get commits
commits=$(git log --pretty=format:"%s" $latest_tag_commit..HEAD)

# Initialize changelog content
changelog_content="# Changelog\n\n## $(git describe --tags --abbrev=0 2>/dev/null || echo "Unreleased")\n\n"

# Categorize commits
added=$(echo "$commits" | grep -E "^(add|feat|feature)" -i)
fixed=$(echo "$commits" | grep -E "^(fix|fixed)" -i)
changed=$(echo "$commits" | grep -E "^(change|modify|update)" -i)
removed=$(echo "$commits" | grep -Ei "^(remove|delete|rm)")

# Build the changelog entry
if [ -n "$added" ]; then
  changelog_content+=$(echo "$added" | sed 's/^/- Added: /')
fi

if [ -n "$fixed" ]; then
  echo "$fixed" | while read -r line; do
    changelog_content+="\n- Fixed: $line\n"
  done
fi

if [ -n "$changed" ]; then
  echo "$changed" | while read -r line; do
    changelog_content+="\n- Changed: $line\n"
  done
fi

if [ -n "$removed" ]; then
  echo "$removed" | while read -r line; do
    changits+=$(echo "$line" | sed 's/^/- Removed: /')
  done
fi

echo -e "$changelog_content"