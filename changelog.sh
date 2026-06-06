#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Get the latest tag, or use a default "v0.0.0" if no tags exist
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Get commit messages since the latest tag
commits=$(git log --oneline "$latest_tag..HEAD" --no-merges)

# Create a temporary file to store the changelog content
temp_file=$(mktemp)

# Write header to the changelog file
echo "# Changelog" > "$temp_file"
echo "" >> "$temp_file"
echo "## [Unreleased]" >> "$temp_file"
echo "" >> "$temp_file"

# Categorize commits and write to the changelog
while IFS= read -r commit; do
  # Extract the commit message (everything after the hash)
  message=$(echo "$commit" | sed 's/^[0-9a-f]* //')
  
  # Categorize based on commit message prefixes
  if [[ $message == *"fix:"* ]] || [[ $message == *"fix("* ]]; then
    echo "- $message" >> "$temp_file"
  elif [[ $message == *"feat:"* ]] || [[ $message == *"feat("* ]]; then
    echo "- $message" >> "$temp_file"
  elif [[ $message == *"remove:"* ]] || [[ $message == *"remove("* ]]; then
    echo "- $message" >> "$temp_file"
  elif [[ $message == *"refactor:"* ]] || [[ $message == *"refactor("* ]]; then
    echo "- $message" >> "$temp_file"
  else
    echo "- $message" >> "$temp_file"
  fi
done <<< "$commits"

# Move temp file to CHANGELOG.md
mv "$temp_file" CHANGELOG.md

echo "CHANGELOG.md generated successfully!"