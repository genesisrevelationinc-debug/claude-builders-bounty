#!/usr/bin/env bash
#
# changelog.sh
# Generate a structured CHANGELOG.md from git history.
#
# Usage:
#   bash changelog.sh
#
# This script fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

# Determine the range of commits to include
# Use the latest tag if available; otherwise, use all commits
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [ -n "$LATEST_TAG" ]; then
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    echo "Generating changelog for commits since tag: $LATEST_TAG"
else
    COMMIT_RANGE="HEAD"
    echo "No tags found. Generating changelog for all commits."
fi

# Get commits in the range
COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" 2>/dev/null || true)

if [ -z "$COMMIT_RANGE" ] || [ -z "$COMMITS" ]; then
    echo "No new commits found since the last tag."
    exit 0
fi

# Initialize category arrays
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

# Categorize each commit
while IFS= read -r line; do
    [ -z "$line" ] && continue

    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if [[ "$lower_line" =~ ^(feat|add|create|implement|introduce) ]]; then
        ADDED+=("$line")
    elif [[ "$lower_line" =~ ^(fix|bugfix|hotfix|resolve|patch) ]]; then
        FIXED+=("$line")
    elif [[ "$lower_line" =~ ^(change|update|modify|refactor|improve|enhance|upgrade) ]]; then
        CHANGED+=("$line")
    elif [[ "$lower_line" =~ ^(remove|delete|drop|revert) ]]; then
        REMOVED+=("$line")
    else
        OTHER+=("$line")
    fi
done <<< "$COMMITS"

# Generate the new changelog section
DATE=$(date +%Y-%m-%d)
if [ -n "$LATEST_TAG" ]; then
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "$LATEST_TAG")
    NEXT_VERSION="$VERSION"
else
    NEXT_VERSION="0.0.1"
fi

# Build the changelog entry
CHANGELOG_ENTRY=""
CHANGELOG_ENTRY+="## [Unreleased] - $DATE\n\n"

if [ ${#ADDED[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+="### Added\n"
    for item in "${ADDED[@]}"; do
        CHANGELOG_ENTRY="- $item\n"
    done
    CHANGELOG_ENTRY+="\n"
fi

if [ ${#FIXED[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+="### Fixed\n"
    for item in "${FIXED[@]}"; do
        CHANGELOG_ENTRY="- $item\n"
    done
    CHANGELOG_ENTRY+="\n"
fi

if [ ${#CHANGED[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+="### Changed\n"
    for item in "${CHANGED[@]}"; do
        CHANGELOG_ENTRY="- $item\n"
    done
    CHANGELOG_ENTRY+="\n"
fi

if [ ${#REMOVED[@]} -gt 0 ]; then
    CHANGELOG_ENTRY+="### Removed\n"
    for item in "${REMOVED[@]}"; do
        CHANGELOG_ENTRY="- $item\n"
    done
    CHANGELOG_ENTRY+="\n"
fi

# Prepend to existing CHANGELOG.md or create new one
if [ -f CHANGELOG.md ]; then
    EXISTING=$(cat CHANGELOG.md)
    printf "# Changelog\n\n$CHANGELOG_ENTRY\n$EXISTING" > CHANGELOG.md
else
    printf "# Changelog\n\n$CHANGELOG_ENTRY" > CHANGELOG.md
fi

echo "CHANGELOG.md updated successfully."
# Generate Changelog Skill

## Description

Automatically generate a structured `CHANGELOG.md` from a project's git history.

## Usage

Run the following command in Claude Code:

