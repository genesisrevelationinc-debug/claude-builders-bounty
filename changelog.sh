#!/bin/bash

# Generate a structured CHANGELOG.md from git history

# Function to display usage
usage() {
    echo "Usage: bash changelog.sh [OPTIONS]"
    echo "Options:"
    echo "  -h, --help     Display this help message"
    echo "  -o, --output   Output file (default: CHANGELOG.md)"
    echo "  -t, --tag      Starting tag (default: latest tag)"
}

# Default values
OUTPUT_FILE="CHANGELOG.md"
START_TAG=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -t|--tag)
            START_TAG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Find the latest tag if not provided
if [[ -z "$START_TAG" ]]; then
    START_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
fi

# If no tag found, use initial commit
if [[ -z "$START_TAG" ]]; then
    START_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commits since the starting tag
COMMITS=$(git log "$START_TAG"..HEAD --oneline --no-merges)

# Initialize arrays for each category
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()

# Categorize commits
while IFS= read -r commit; do
    commit_lower=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    if [[ $commit_lower == *"add"* ]] || [[ $commit_lower == *"new"* ]] || [[ $commit_lower == *"create"* ]]; then
        ADDED+=("- $commit")
    elif [[ $commit_lower == *"fix"* ]] || [[ $commit_lower == *"bug"* ]] || [[ $commit_lower == *"resolve"* ]]; then
        FIXED+=("- $commit")
    elif [[ $commit_lower == *"change"* ]] || [[ $commit_lower == *"update"* ]] || [[ $commit_lower == *"modify"* ]]; then
        CHANGED+=("- $commit")
    elif [[ $commit_lower == *"remove"* ]] || [[ $commit_lower == *"delete"* ]] || [[ $commit_lower == *"cleanup"* ]]; then
        REMOVED+=("- $commit")
    fi
done <<< "$COMMITS"

# Write changelog to file
{
    echo "# Changelog"
    echo ""
    echo "## [Unreleased]"
    echo ""
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        printf '%s\n' "${ADDED[@]}"
        echo ""
    fi
    if [ ${#FIXED[@]} -gt 0 ]; then
        echo "### Fixed"
        printf '%s\n' "${FIXED[@]}"
        echo ""
    fi
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "### Changed"
        printf '%s\n' "${CHANGED[@]}"
        echo ""
    fi
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        printf '%s\n' "${REMOVED[@]}"
        echo ""
    fi
} > "$OUTPUT_FILE"

echo "Changelog generated: $OUTPUT_FILE"