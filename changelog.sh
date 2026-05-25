#!/bin/bash

set -e

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to get the latest tag
get_latest_tag() {
  git describe --tags --abbrev=0 2>/dev/null || echo "No tags found"
}

# Function to categorize commits
categorize_commits() {
  local commit_msg="$1"
  local category="Changed"  # Default category

  # Categorize based on commit message
  case "$commit_msg" in
    fix:*)          category="Fixed" ;;
    feat:*)          category="Added" ;;
    remove:*)         category="Removed" ;;
    remove*          category="Removed" ;;
    refactor:*)      category="Changed" ;;
    *)               category="Changed" ;;
  esac

  echo "$category"
}

# Get the last tag or default to "v0.0.0"
last_tag=$(get_latest_tag)
if [ "$last_tag" = "No tags found" ]; then
  last_tag="v0.0.0"
  echo "No previous tags found. Using $last_tag as the starting point."
fi

# Get commit messages between the last tag and the current HEAD
echo "Generating changelog since $last_tag..."

# Create a temporary file to store commit history
temp_file=$(mktemp)

# Use git log to get the commits and write to the temp file
git log "$last_tag..HEAD" --pretty=format:"%s" --no-merges > "$temp_file"

# Initialize changelog content
changelog_content=""

# Check if the temp file has any content
if [ -s "$temp_file" ]; then
  # Read the commit messages from the temp file
  while IFS= read -r commit; do
    # Categorize the commit
    category=$(categorize_commits "$commit")
    
    # Add to changelog content
    if [ "$category" = "Added" ]; then
      changelog_content="$changelog_content- $commit\n"
    else
      changelog_content="$changelog_content### $category\n\n$changelog_content"  
    fi
  done < "$temp_file"
  
  # If we have "Added" commits, add the section header
  if [ "$category" = "Added" ]; then
    changelog_content="### Added\n\n$changelog_content"
  fi
fi

# Create or update CHANGELOG.md
cat > CHANGELOG.md << EOF
# Changelog

## [Unreleased]

$changelog_content

<!-- Additional sections will be added here as needed for other types -->
EOF

# Clean up
rm -f "$temp_file"

echo "CHANGELOG.md has been generated."