#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

set -e

REPO_DIR=$(pwd)
CHANGELOG_FILE="CHANGELOG.md"

# Function to determine change type from commit message
get_change_type() {
  local message="$1"
  case "$message" in
    *fix*|*Fix*|*bug*|*Bug*) echo "Fixed" ;;
    *remove*|*delete*|*Remove*|*Delete*) echo "Removed" ;;
    *change*|*update*|*modify*|*Change*|*Update*|*Modify*) echo "Changed" ;;
    *) echo "Added" ;;
  esac
}

# Get the last tag or use initial commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -z "$LAST_TAG" ]; then
  LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commits since last tag
COMMITS=$(git log "$LAST_TAG"..HEAD --no-merges --oneline)

# Generate changelog content
{
  echo "# Changelog"
  echo ""
  echo "## [Unreleased]"
  echo "$COMMITS" | while read -r commit; do
    message=$(echo "$commit" | sed 's/^[a-f0-9]* *//')
    type=$(get_change_type "$message")
    echo "  - $type: $message"
  done
} > $CHANGELOG_FILE

echo "Generated $CHANGELOG_FILE"