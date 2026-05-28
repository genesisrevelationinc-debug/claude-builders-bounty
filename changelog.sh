#!/bin/bash

# Generate Changelog
# This script generates a structured CHANGELOG.md from git history

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

# Check if git repository exists
if [ ! -d ".git" ]; then
    print_error "This is not a git repository. Please run this script from the root of a git repository."
    exit 1
fi

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

if [ -z "$LATEST_TAG" ]; then
    print_warning "No tags found. Using initial commit as starting point."
    COMMITS_SINCE=$(git log --oneline | tail -n 1 | cut -d' ' -f1)
    COMMITS_RANGE="$COMMITS_SINCE..HEAD"
else
    print_status "Latest tag: $LATEST_TAG"
    COMMITS_RANGE="$LATEST_TAG..HEAD"
fi

# Get commits since last tag
COMMITS=$(git log --oneline $COMMITS_RANGE 2>/dev/null)

if [ -z "$COMMITS" ]; then
    print_warning "No commits found since $LATEST_TAG"
    exit 0
fi

# Initialize arrays for categories
declare -a ADDED COMMITS
declare -a FIXED COMMITS
declare -a CHANGED COMMITS
declare -a REMOVED COMMITS

# Categorize commits
while IFS= read -r commit; do
    commit_msg=$(echo "$commit" | cut -d' ' -f2-)
    
    case "$commit_msg" in
        *add*|*Add*|*new*|*New*|*feature*|*Feature*)
            ADDED+=("$commit_msg")
            ;;
        *fix*|*Fix*|*bug*|*Bug*|*patch*|*Patch*)
            FIXED+=("$commit_msg")
            ;;
        *change*|*Change*|*update*|*Update*|*modify*|*Modify*)
            CHANGED+=("$commit_msg")
            ;;
        *remove*|*Remove*|*delete*|*Delete*|*deprecated*|*Deprecated*)
            REMOVED+=("$commit_msg")
            ;;
        *)
            CHANGED+=("$commit_msg")  # Default to Changed if no match
            ;;
    esac
done <<< "$COMMITS"

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [Unreleased]"
    echo ""
    
    [ ${#ADDED[@]} -gt 0 ] && echo "### Added" && printf '%s\n' "${ADDED[@]/#/ - }" && echo ""
    [ ${#FIXED[@]} -gt 0 ] && echo "### Fixed" && printf '%s\n' "${FIXED[@]/#/ - }" && echo ""
    [ ${#CHANGED[@]} -gt 0 ] && echo "### Changed" && printf '%s\n' "${CHANGED[@]/#/ - }" && echo ""
    [ ${#REMOVED[@]} -gt 0 ] && echo "### Removed" && printf '%s\n' "${REMOVED[@]/#/ - }" && echo ""
} > CHANGELOG.md

print_success "CHANGELOG.md generated successfully!"