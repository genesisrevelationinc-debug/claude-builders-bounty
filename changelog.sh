#!/bin/bash

# Exit on any error
set -e

# Function to print usage
usage() {
  echo "Usage: $0"
  echo "Generates a structured CHANGELOG.md from git history"
  exit 1
}

# Check if the current directory is a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: This script must be run from a Git repository"
  exit 1
fi

# Get the latest tag
latest_tag=$(git describe --tags $(git rev-list --tags --sort=taggerdate --max-count=1))

# If no tags are found, use the initial commit
if [ -z "$latest_tag" ]; then
  latest_tag=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit messages since last tag
if [ -z "$latest_tag" ]; then
  echo "No tags found, using all commits"
  commit_range=""
else
  echo "Using commit range from $latest_tag"
  commit_range="$latest_tag..HEAD"
fi

# Create a temporary file to store the changelog
tmp_file=$(mktemp)

# Write the changelog header
cat > "$tmp_file" << 'EOF'
# Changelog
EOF

# Categorize commits
added=()
fixed=()
changed=()
removed=()
uncategorized=()

if [ -z "$commit_range" ]; then
  commit_list=$(git log --oneline)
else
  commit_list=$(git log --oneline $commit_range)
fi

echo "Processing commits..."
while read -r line; do
  if [[ $line == *"add:"* ]] || [[ $line == *"feat:"* ]] || [[ $line == *"feature:"* ]]; then
    added+=("- $line")
  elif [[ $line == *"fix:"* ]]; then
    fixed+=("- $line")
  elif [[ $line == *"refactor:"* ]] || [[ $line == *"update:"* ]] || [[ $a == *"modify:"* ]]; then
    changed+=("- $line")
  elif [[ $line == *"remove:"* ]] || [[ $line == *"rm:"* ]] || [[ $line == *"delete:"* ]]; then
    removed+=("- $line")
  else
    uncategorized+=("- $line")
  fi
done <<< "$commit_list"

# Write categorized commits to temporary file
{
  if [ ${#added[@]} -gt 0 ]; then
    echo "## Added" >> "$tmp_file"
    for line in "${added[@]}"; do
      echo "$line" >> "$tmp_file"
    done
  fi
  
  if [ ${#fixed[@]} > 0 ]; then
    echo "## Fixed" >> "$tmp_file"
    for line in "${fixed[@]}"; do
      echo "- $line" >> "$tmp_file"
    done
  fi
  
  # Add other categories as needed...
} > "$tmp_file"

# Move the changelog to the final location
mv "$tmp_file" CHANGELOG.md

echo "CHANGELOG.md has been generated!"