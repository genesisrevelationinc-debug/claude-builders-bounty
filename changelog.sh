#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Generate a CHANGELOG.md from git history since last tag"
  echo ""
  echo "Options:"
  echo "  -h, --help    Display this help message"
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag is found, use all commits
if [ -z "$LAST_TAG" ]; then
  echo "No git tags found. Please create at least one tag to generate a changelog."
  exit 1
fi

# Create a temporary file for commits
TEMP_FILE=$(mktemp)
git log $LAST_TAG..HEAD --pretty=format:"%s" > "$TEMP_FILE"

# Create sections
ADDED=$(grep -E "^(add|feat|feature)" "$TEMP_FILE" -i)
FIXED=$(grep -E "^(fix|fixed)" "$TEMP_FILE" -i)
CHANGED=$(grep -E "^(change|update|update)" "$TEMP_FILE" -i)
REMOVED=$(grep -E "^(remove|delete|rm)" "$TEMP_FILE" -i)

# Create CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [Unreleased]" >> CHANGELOG.md

if [ -n "$ADDED" ]; then
  echo "### Added" >> CHANGELOG.md
  echo "$ADDED" | while read -r line; do
    echo "- $line" >> CHANGELOG.md
  done
fi

echo "" >> CHANGELOG.md
echo "### Fixed" >> CHANGELOG.md
echo "$FIXED" | while read -r line; do
  echo "- $line" >> CHANGELOG.md
done

echo "" >> CHANGELOG.md
echo "### Changed" >> CHANGELOG.md
echo "$CHANGED" | while read -r line; do
  echo "- $line" >> CHANGELOG.md
done

echo "" >> CHANGELOG.md
echo "### Removed" >> CHANGELOG.md
echo "$REMOVED" | while read -r line; do
  echo "- $line" >> CHANGELOG.md
done

# Cleanup
rm "$TEMP_FILE"

echo "CHANGELOG.md has been generated!"