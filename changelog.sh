#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

set -e

#########################
# Configuration
#########################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
CHANGELOG_FILE="CHANGELOG.md"
REPO_URL=""

#########################
# Functions
#########################

print_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "  -h, --help     Show this help message"
  echo "  -o, --output    Specify output file (default: CHANGELOG.md)"
  echo "  -r, --repo      Specify repository URL for commit links"
  echo ""
  echo "Examples:"
  echo "  bash changelog.sh"
  echo "  bash changelog.sh -o custom_changelog.md"
  echo "  bash changelog.sh -r https://github.com/user/repo"
}

generate_changelog() {
  # Get the last tag or use initial commit if no tags exist
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null) || true
  
  if [ -z "$LAST_TAG" ]; then
    # If no tags, use the initial commit
    LAST_TAG=$(git rev-list --max-parents=0 HEAD)
  fi
  
  # Get commits since last tag
  COMMITS=$(git log --pretty=format:"%s" $LAST_TAG..HEAD)
  
  # Generate the changelog content
  echo "# Changelog" > $CHANGELOG_FILE
  echo "" >> $CHANGELOG_FILE
  
  # Categorize commits
  while IFS= read -r line; do
    if [[ $line == *"fix"* ]] || [[ $line == *"Fix"* ]] || [[ $line == *"fixed"* ]] || [[ $line == *"Fixed"* ]]; then
      echo "### Fixed" >> $CHANGELOG_FILE
      echo "- $line" >> $CHANGELOG_FILE
    elif [[ $line == *"add"* ]] || [[ $line == *"Add"* ]] || [[ $line == *"new"* ]] || [[ $line == *"New"* ]]; then
      echo "### Added" >> $CHANGELOG_FILE
      echo "- $line" >> $CHANGELOG_FILE
    elif [[ $line == *"change"* ]] || [[ $line == *"Change"* ]] || [[ $line == *"refactor"* ]] || [[ $line == *"Refactor"* ]] || [[ $line == *"update"* ]] || [[ $line == *"Update"* ]]; then
      echo "### Changed" >> $CHANGELOG_FILE
      echo "- $line" >> $CHANGELOG_FILE
    elif [[ $line == *"remove"* ]] || [[ $line == *"Remove"* ]] || [[ $line == *"delete"* ]] || [[ $line == *"Delete"* ]]; then
      echo "### Removed" >> $CHANGELOG_FILE
      echo "- $line" >> $CHANGELOG_FILE
    else
      echo "### Added" >> $CHANGELOG_FILE
      echo "- $line" >> $CHANGELOG_FILE
    fi
    echo "" >> $CHANGELOG_FILE
  done <<< "$COMMITS"
  
  echo -e "${GREEN}Changelog generated in $CHANGELOG_FILE${NC}"
  if [ "$REPO_URL" ]; then
    echo "You can find it at: $REPO_URL"
  fi
}

# Parse command line arguments
while getopts "o:r:h" opt; do
  case $opt in
    o) CHANGELOG_FILE="$OPTARG" ;;
    r) REPO_URL="$OPTARG" ;;
    h) print_usage; exit 0 ;;
    *) echo "Invalid option"; print_usage; exit 1 ;;
  esac
done

generate_changelog