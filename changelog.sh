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
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if git is available
if ! command -v git &> /dev/null; then
  print_error "Git is not installed. Please install git and try again."
  exit 1
fi

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$latest_tag" ]; then
  print_warning "No tags found. Using initial commit as starting point."
  since_ref=$(git rev-list --max-parents=0 HEAD)
else
  print_status "Latest tag: $latest_tag"
  since_ref="$latest_tag"
fi

# Get commits since the latest tag
commits=$(git log --pretty=format:"%s" "$since_ref"..HEAD)

# If no commits, exit
if [ -z "$commits" ]; then
  print_warning "No commits found since $since_ref"
  exit 0
fi

# Initialize changelog sections
added=""
fixed=""
changed=""
removed=""

# Categorize commits based on prefixes
while IFS= read -r line; do
  case "$line" in
    Added*|ADD*|add*) added+="- $line\n" ;;
    Fixed*|FIX*|fix*) fixed+="- $line\n" ;;
    Changed*|CHANGE*|change*) changed+="- $line\n" ;;
    Removed*|REMOVE*|remove*) removed+="- $line\n" ;;
    *) added+="- $line\n" ;; # Default to Added if no prefix
  esac
done <<< "$commits"

# Generate the changelog content
{
  echo "# Changelog"
  echo ""
  echo "All notable changes to this project will be documented in this file."
  echo ""
  echo "## [Unreleased]"
  [ -n "$added" ] && echo -e "\n### Added\n${added}"
  [ -n "$fixed" ] && echo -e "\n### Fixed\n${fixed}"
  [ -n "$changed" ] && echo -e "\n### Changed\n${changed}"
  [ -n "$removed" ] && echo -e "\n### Removed\n${removed}"
} > CHANGELOG.md

print_status "CHANGELOG.md has been generated successfully!"