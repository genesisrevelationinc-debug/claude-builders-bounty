#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$latest_tag" ]; then
  echo "No tags found. Using 'HEAD' to get all commits."
  latest_tag="HEAD"
fi

# Get commits since the last tag
if [ "$latest_tag" = "HEAD" ]; then
  commit_range="HEAD"
else
  commit_range="$latest_tag..HEAD"
fi

commits=$(git log --oneline $commit_range)

# Initialize arrays for changelog categories
added=()
fixed=()
changed=()
removed=()

# Categorize commits based on commit message prefixes
while read -r line; do
  if [[ $line == *"add:"* ]] || [[ $line == *"feat:"* ]]; then
    added+=("$line")
  elif [[ $line == *"fix:"* ]]; then
    fixed+=("$line")
  elif [[ $line == *"refactor:"* ]] || [[ $line == *"update:"* ]]; then
    changed+=("$line")
  elif [[ $line == *"remove:"* ]] || [[ $line == *"delete:"* ]] || [[ $line == *"rm:"* ]]; then
    removed+=("$line")
  else
    # If no specific type, add to "Changed" section
    changed+=("$line")
  fi
done <<< "$commits"

# Generate the changelog
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

if [ ${#added[@]} -gt 0 ]; then
  echo "## Added" >> CHANGELOG.md
  for commit in "${added[@]}"; do
    echo "- $commit" >> CHANGELOG.md
  done
  echo "" >> CHANGELOG.md
fi

if [ ${#fixed[@]} -gt 0 ]; then
  echo "## Fixed" >> CHANGELOG.md
  for commit in "${fixed[@]}"; do
    echo "- $commit" >> CHANGELOG.md
  done
  echo "" >> CHANGELOG.md
fi