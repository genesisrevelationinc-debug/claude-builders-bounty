#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
  color=$1
  message=$2
  echo -e "${color}${message}${NC}"
}

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  print_color $RED "Error: Not in a git repository"
  exit 1
fi

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LATEST_TAG" ]; then
  print_color $YELLOW "No tags found. Using initial commit as starting point."
  COMMITS_SINCE=$(git rev-list --max-parents=0 HEAD)
else
  print_color $BLUE "Generating changelog since tag: $LATEST_TAG"
  COMMITS_SINCE=$LATEST_TAG
fi

# Create temporary file for changelog content
TMP_FILE=$(mktemp)

# Get commit messages and categorize them
{
  if [ -z "$LATEST_TAG" ]; then
    # If no tags, get all commits since initial commit
    git log --oneline --no-merges --reverse $COMMITS_SINCE..HEAD
  else
    # Get commits since the last tag
    git log --oneline --no-merges --reverse $LATEST_TAG..HEAD
  fi
} > "$TMP_FILE"

# Initialize changelog sections
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Categorize commits based on keywords in subject line
while IFS= read -r commit; do
  # Skip empty lines
  [ -z "$commit" ] && continue
  
  # Extract the commit message (skip the commit hash)
  message=$(echo "$commit" | sed 's/^[0-9a-f]* *//')
  
  # Categorize based on keywords
  if [[ "$message" == *"add:"* ]] || [[ "$message" == *"Add:"* ]] || [[ "$message" == *"new:"* ]] || [[ "$message" == *"New:"* ]]; then
    ADDED+="- $message"$'\n'
  elif [[ "$message" == *"fix:"* ]] || [[ "$message" == *"Fix:"* ]] || [[ "$message" == *"fix "* ]] || [[ "$message" == *"Fix "* ]]; then
    FIXED+="- $message"$'\n'
  elif [[ "$message" == *"remove:"* ]] || [[ "$message" == *"Remove:"* ]] || [[ "$message" == *"delete:"* ]] || [[ "$message" == *"Delete:"* ]]; then
    REMOVED+="- $message"$'\n'
  else
    # Default to "Changed" category
    CHANGED+="- $message"$'\n'
  fi
done < "$TMP_FILE"

# Write changelog to file
{
  echo "# Changelog"
  echo ""
  if [ -n "$LATEST_TAG" ]; then
    echo "## Changes since $LATEST_TAG"
  else
    echo "## Initial release"
  fi
  echo ""
  if [ -n "$ADDED" ]; then
    echo "### Added"
    echo "$ADDED"
  fi
  if [ -n "$FIXED" ]; then
    echo "### Fixed"
    echo "$FIXED"
  fi
  if [ -n "$CHANGED" ]; then
    echo "### Changed"
    echo "$CHANGED"
  fi
  if [ -n "$REMOVED" ]; then
    echo "### Removed"
    echo "$REMOVED"
  fi
} > CHANGELOG.md

print_color $GREEN "CHANGELOG.md generated successfully!"