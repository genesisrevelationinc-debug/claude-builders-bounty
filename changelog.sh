#!/bin/bash

# Script to generate a structured CHANGELOG.md from git history

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
  echo -e "${GREEN}STATUS:${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}WARNING:${NC} $1"
}

print_error() {
  echo -e "${RED}ERROR:${NC} $1"
}

# Get the latest git tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$latest_tag" ]; then
  print_warning "No git tags found. Using initial commit as starting point."
  start_ref=$(git rev-list --max-parents=0 HEAD)
else
  print_status "Latest tag: $latest_tag"
  start_ref="$latest_tag"
fi

# Get commits since the last tag (or initial commit)
commits=$(git log --pretty=format:"%s" "$start_ref"..HEAD)

# Initialize changelog sections
added=""
fixed=""
changed=""
removed=""

# Categorize commits based on prefixes
while IFS= read -r commit; do
  if [[ $commit == "Add:"* ]] || [[ $commit == "feat:"* ]] || [[ $commit == "+ "* ]]; then
    added+="  - ${commit#*: }\n"
  elif [[ $commit == "Fix:"* ]] || [[ $commit == "fix:"* ]]; then
    fixed+="  - ${commit#*: }\n"
  elif [[ $commit == "Change:"* ]] || [[ $commit == "refactor:"* ]] || [[ $commit == "update:"* ]]; then
    changed+="  - ${commit#*: }\n"
  elif [[ $commit == "Remove:"* ]] || [[ $commit == "delete:"* ]]; then
    removed+="  - ${commit#*: }\n"
  fi
done <<< "$commits"

# Generate the changelog content
{
  echo "# Changelog"
  echo ""
  echo "## [Unreleased]"
  [ -n "$added" ] && echo -e "\n### Added\n$added"
  [ -n "$fixed" ] && echo -e "\n### Fixed\n$fixed"
  [ -n "$changed" ] && echo -e "\n### Changed\n$changed"
  [ -n "$removed" ] && echo -e "\n### Removed\n$removed"
} > CHANGELOG.md

print_status "CHANGELOG.md has been generated successfully!"