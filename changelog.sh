#!/bin/bash

# Exit on any error
set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Change to the target repository directory
cd "$SCRIPT_DIR" || exit 1

# Get the last tag, or use a default start point
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD")

# If there are no tags, get all commits
if [ "$LAST_TAG" = "HEAD" ]; then
  COMMITS=$(git log --oneline)
else
  # Get commits since the last tag
  COMMITS=$(git log "$LAST_TAG"..HEAD --oneline 2>/dev/null || git log --oneline)
fi

# Initialize changelog content
CHANGELOG="## Changelog\n\n"

# Try to get the version from the latest tag, otherwise use date
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || date +%Y-%m-%d)
CHANGELOG+="### $VERSION\n\n"

# Categorize commits
ADDED=$(echo "$COMMITS" | grep -E '^[0-9a-f]+ (feat|add|new):' || true)
FIXED=$(echo "$COMMITS" | grep -E '^[0-9a-f]+ (fix|fixed):' || true)
CHANGED=$(echo "$COMMITS" | grep -E '^[0-9a-f]+ (change|update|refactor):' || true)
REMOVED=$(echo "$COMMITS" | grep -E '^[0-9a-f]+ (remove|delete|rm):' || true)

# Function to format commit messages
format_commits() {
  if [ -n "$1" ]; then
    echo "$1" | while read -r line; do
      if [ -n "$line" ]; then
        # Remove commit hash and keep only the message
        echo "- ${line#* }"
      fi
    done
  fi
}

[ -n "$ADDED" ] && CHANGELOG+="#### Added\n$(format_commits "$ADDED")\n\n"
[ -n "$FIXED" ] && CHANGELOG+="#### Fixed\n$(format_commits "$FIXED")\n\n"
[ -n "$CHANGED" ] && CHANGELOG+="#### Changed\n$(format_commits "$CHANGED")\n\n"
[ -n "$REMOVED" ] && CHANGELOG+="#### Removed\n$(format_commits "$REMOVED")\n\n"

# Write to CHANGELOG.md
echo -e "$CHANGELOG" > CHANGELOG.md

echo "CHANGELOG.md generated successfully!"