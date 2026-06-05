#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

set -e

# Function to display usage
usage() {
    echo "Usage: $0 <since_tag>"
    echo "Example: $0 v1.0.0"
    echo "        $0 --all # to generate changelog for all commits"
    exit 1
}

# Check if git repository
if [ ! -d .git ] && [ ! -f .git ]; then
    echo "Error: Not a git repository"
    exit 1
fi

# Default values
SINCE_TAG=""
OUTPUT_FILE="CHANGELOG.md"

# Parse arguments
if [ "$#" -eq 0 ]; then
    # Get the last tag or all commits if no tags exist
    SINCE_TAG=$(git describe --tags --abbrev=0 HEAD~ 2>/dev/null) || true
elif [ "$#" -eq 1 ]; then
    if [ "$1" = "--all" ]; then
        SINCE_TAG=$(git rev-list --tags --max-count=1)
    else
        SINCE_TAG="$1"
    fi
else
    usage
fi

# If no previous tag, start from the first commit
if [ -z "$SINCE_TAG" ]; then
    SINCE_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get the commits
if [ "$SINCE_TAG" = "$(git rev-list --tags --max-count=1)" ]; then
    COMMITS=$(git log --oneline)
else
    COMMITS=$(git log "$SINCE_TAG..HEAD" --oneline)
fi

# Create a temporary file to store commit messages
TEMP_FILE=$(mktemp)
echo "$COMMITS" > "$TEMP_FILE"

# Initialize sections
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

# Categorize commits
while IFS= read -r line; do
    if [[ $line == *"feat:"* ]] || [[ $line == *"add:"* ]] || [[ $line == *"new:"* ]]; then
        ADDED+="- $line"$'\n'
    elif [[ $line == *"fix:"* ]] || [[ $line == *"bug:"* ]]; then
        FIXED+="- $line"$'\n'
    elif [[ $line == *"refactor:"* ]] || [[ $line == *"update:"* ]] || [[ $line == *"improve:"* ]]; then
        CHANGED+="- $line"$'\n'
    elif [[ $line == *"remove:"* ]] || [[ $line == *"delete:"* ]] || [[ $line == *"revert:"* ]]; then
        REMOVED+="- $line"$'\n'
    else
        # Default to Added if no matching pattern
        ADDED+="- $line"$'\n'
    fi
done < "$TEMP_FILE"

# Write to CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    if [ -n "$ADDED" ]; then
        echo "## Added"
        echo "$ADDED"
    fi
    if [ -n "$FIXED" ]; then
        echo "## Fixed"
        echo "$FIXED"
    fi
    if [ -n "$CHANGED" ]; then
        echo "## Changed"
        echo "$CHANGED"
    fi
    if [ -n "$REMOVED" ]; then
        echo "## Removed"
        echo "$REMOVED"
    fi
} > "$OUTPUT_FILE"

rm "$TEMP_FILE"
echo "CHANGELOG.md has been generated."