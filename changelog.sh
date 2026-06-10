#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help     Display this help message"
    echo "  -t, --tag      Specify the tag to generate changelog from (default: latest tag)"
    echo "  -o, --output   Specify output file (default: CHANGELOG.md)"
    exit 1
}

# Default values
OUTPUT_FILE="CHANGELOG.md"
FROM_TAG=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -t=*|--tag=*)
            FROM_TAG="${1#*=}"
            ;;
        -o=*|--output=*)
            OUTPUT_FILE="${1#*=}"
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

# Get the last tag if not specified
if [ -z "$FROM_TAG" ]; then
    LAST_TAG=$(git describe --tags `git rev-list --tags --sort=taggerdate | tail -1`)
    echo "Generating changelog from tag: $LAST_TAG"
else
    LAST_TAG=$(git describe --tags `git rev-list --tags --sort=taggerdate | tail -1`)
fi

# Get the commits since the last tag
if [ -z "$FROM_TAG" ]; then
    COMMITS=$(git log $LAST_TAG..HEAD --oneline --no-merges)
else
    COMMITS=$(git log $FROM_TAG..HEAD --oneline --no-merges)
fi

# Initialize categories
added=""
changed=""
fixed=""
removed=""

# Categorize commits based on conventional commit prefixes
while IFS= read -r commit; do
    if [[ $commit == *"feat:"* ]] || [[ $commit == *"feature:"* ]]; then
        added="$added
- $commit"
    elif [[ $commit == *"fix:"* ]]; then
        fixed="$fixed
- $commit"
    elif [[ $commit == *"refactor:"* ]] || [[ $commit == *"chore:"* ]] || [[ $commit == *"style:"* ]] || [[ $commit == *"test:"* ]]; then
        # Skip these types of commits for changelog
        continue
    elif [[ $commit == *"remove:"* ]] || [[ $commit == *"delete:"* ]] || [[ $commit == *"delete"* ]]; then
        removed="$removed
- $commit"
    elif [[ $commit == *"change:"* ]] || [[ $commit == *"update:"* ]] || [[ $commit == *"modify:"* ]]; then
        changed="$changed
- $commit"
    else
        # Default to categorizing as "Changed" if it is a general update
        changed="$changed
- $commit"
    fi
done <<< "$COMMITS"

# Create the changelog content
{
    echo "# Changelog"
    echo ""
    if [ -n "$LAST_TAG" ] && [ -z "$FROM_TAG" ]; then
        echo "## Changes since $LAST_TAG"
    elif [ -n "$FROM_TAG" ]; then
        echo "## Changes since $FROM_TAG"
    else
        echo "## Recent Changes"
    fi
    echo ""
    
    if [ -n "$added" ]; then
        echo "### Added"
        echo "$added"
        echo ""
    fi
    
    if [ -n "$fixed" ]; then
        echo "### Fixed"
        echo "$fixed"
        echo ""
    fi
    
    if [ -n "$changed" ]; then
        echo "### Changed"
        echo "$changed"
        echo ""
    fi
    
    if [ -n "$removed" ]; then
        echo "### Removed"
        echo "$removed"
        echo ""
    fi
} > "$OUTPUT_FILE"

echo "Changelog generated: $OUTPUT_FILE"