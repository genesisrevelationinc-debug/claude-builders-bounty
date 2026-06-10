#!/bin/bash

# Exit on any error
set -e

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "  -h, --help     Display this help message"
    echo "  -o, --output    Specify output file (default: CHANGELOG.md)"
    echo "  -v, --verbose   Enable verbose output"
    echo ""
    echo "Examples:"
    echo "  $0                    # Generate CHANGELOG.md with default settings"
    echo "  $0 -o MyChangelog.md # Generate with custom output file"
    exit 1
}

# Default values
OUTPUT_FILE="CHANGELOG.md"
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD")

if [ "$LAST_TAG" != "HEAD" ]; then
    COMMITS=$(git log --oneline "$LAST_TAG"..HEAD)
else
    COMMITS=$(git log --oneline)
fi

if [ -z "$COMMITS" ]; then
    echo "No commits found since last tag: $LAST_TAG" >&2
    exit 1
fi

# Generate changelog
{
    echo "# Changelog"
    echo ""
    echo "## [Unreleased]"
    echo ""
    echo "$COMMITS" | while read -r line; do
        echo "- $line"
    done
} > "$OUTPUT_FILE"

echo "Changelog generated: $OUTPUT_FILE"