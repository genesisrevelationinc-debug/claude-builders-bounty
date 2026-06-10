#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# This script generates a CHANGELOG.md file by analyzing git commit history
# since the last git tag and categorizing commits into sections:
# Added, Fixed, Changed, and Removed.
#
# Usage:
#   bash changelog.sh
#
# Requirements:
# - Must be run from the root of a git repository
# - The repository should have at least one git tag
#


# Function to display script usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Generate a structured CHANGELOG.md from git history"
  echo
  echo "Options:"
  echo "  -h, --help     Display this help message"
  echo
  echo "The script:"
  echo "1. Finds commits since the last git tag"
  echo "2. Categorizes commits into Added/Changed/Fixed/Removed"
  echo "3. Generates a structured CHANGELOG.md"
  echo
  echo "Requirements:"
  echo "- Run from the root of a git repository"
  echo "- Repository must have at least one git tag"
  exit 1
}

# Display usage if requested
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
fi

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

# Get the last tag
last_tag=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$last_tag" ]; then
  echo "No tags found. Creating changelog for all commits."
  last_tag=$(git rev-list --max-parents=0 HEAD)
  if [ -z "$last_tag" ]; then
    echo "Error: No initial commit found"
    exit 1
  fi
fi

# Get commit messages since last tag
commits=$(git log --pretty=format:"%s" "$last_tag"..HEAD)

# Initialize changelog sections
added=""
fixed=""
changed=""
removed=""

# Categorize commits based on prefixes
echo "$commits" | while IFS= read -r line; do
  if [[ $line == *"add:"* ]] || [[ $line == *"feat:"* ]] || [[ $line == *"new:"* ]]; 
    then added+="* $line\n"
  elif [[ $line == *"fix:"* ]] || [[ $line == *"fixed:"* ]]; 
    then fixed+="* $line\n"
  elif [[ $line == *"change:"* ]] || [[ $line == *"updated:"* ]] || [[ $line == *"update:"* ]] || [[ $line == *"modified:"* ]] || [[ $line == *"refactor:"* ]]; 
    then changed+="* $line\n"
  elif [[ $line == *"remove:"* ]] || [[ $line == *"delete:"* ]] || [[ $line == *"removed:"* ]] || [[ $line == *"deleted:"* ]]; 
    then removed+="* $line\n"
  fi
done

# Add uncategorized commits to changed section if no match
echo "$commits" | while IFS= read -r line; do
  if ! echo "$added$fixed$changed$removed" | grep -q "$line"; then
    changed+="* $line\n"
  fi
done < <(echo "$commits")

# Get the current date in ISO 8601 format
date=$(date -I)

# Write the changelog
cat > CHANGELOG.md << EOF
## Changelog

### $date

#### Added
$added
#### Fixed
$fixed
#### Changed
$changed
#### Removed
$removed
EOF

echo "CHANGELOG.md has been generated."