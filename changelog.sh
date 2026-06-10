#!/bin/bash

# Script to generate a structured CHANGELOG.md from git history
# Usage: ./changelog.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print in color
print_red() {
    echo -e "${RED}$1${NC}"
}

print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_red "Git is not installed. Please install Git and try again."
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_red "This is not a git repository. Please run this script from the root of a git repository."
    exit 1
fi

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
    print_yellow "No tags found. Using initial commit as reference."
    LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

print_green "Generating changelog since tag: $LAST_TAG"

# Get commits since last tag
COMMITS=$(git log --pretty=format:"%s" $LAST_TAG..HEAD 2>/dev/null || git log --pretty=format:"%s" $LAST_TAG)

# Create temporary file for changelog content
TEMP_FILE=$(mktemp)

# Write header
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
EOF

# Initialize category arrays
ADDED=()
FIXED=()
CHANGED=()
REMOVED=()

# Categorize commits based on prefixes
while IFS= read -r commit; do
    case "$commit" in
        feat:*|add:*|new:*) ADDED+=("- $commit") ;;
        fix:*|fixed:*|bugfix:*) FIXED+=("- $commit") ;;
        refactor:*|update:*|change:*) CHANGED+=("- $commit") ;;
        remove:*|delete:*|rm:*) REMOVED+=("- $commit") ;;
        *) ADDED+=("- $commit") ;;
    esac
done <<< "$COMMITS"

# Write categories to changelog
echo -e "\n### Added" >> CHANGELOG.md
printf '%s\n' "${ADDED[@]}" >> CHANGELOG.md

echo -e "\n### Fixed" >> CHANGELOG.md
printf '%s\n' "${FIXED[@]}" >> CHANGELOG.md

echo -e "\n### Changed" >> CHANGELOG.md
printf '%s\n' "${CHANGED[@]}" >> CHANGELOG.md

echo -e "\n### Removed" >> CHANGELOG.md
printf '%s\n' "${REMOVED[@]}" >> CHANGELOG.md

print_green "CHANGELOG.md has been generated successfully!"