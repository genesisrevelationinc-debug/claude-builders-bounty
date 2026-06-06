#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: bash changelog.sh [OPTIONS]"
  echo "Generate a changelog from git history."
  echo ""
  echo "Options:"
  echo "  -h, --help     Display this help message"
  echo "  -t, --tag      Specify the previous tag (default: latest tag)"
  echo "  -o, --output    Output file (default: CHANGELOG.md)"
  exit 1
}

# Default values
OUTPUT_FILE="CHANGELOG.md"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -h|--help) usage ;;
    -t|--tag) PREV_TAG="$2"; shift ;;
    -o|--output) OUTPUT_FILE="$2"; shift ;;
    *) echo "Unknown parameter: $1"; usage ;;
  esac
  shift
done

# Get the previous tag if not specified
if [ -z "$PREV_TAG" ]; then
  PREV_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
  if [ $? -ne 0 ]; then
    echo "Error: No tags found in the repository. Please create a tag first."
    exit 1
  fi
fi

# Get commit hash for the previous tag
PREV_TAG_COMMIT=$(git rev-list -n 1 "$PREV_TAG" 2>/dev/null)

if [ -z "$PREV_TAG_COMMIT" ]; then
  echo "Error: Could not find commit for tag $PREV_TAG"
  exit 1
fi

# Get commits since the last tag
COMMITS=$(git log --no-merges --pretty=format:"%s" "$PREV_TAG..HEAD")

# Generate the changelog
echo "# Changelog" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "## [Unreleased]" >> "$OUTPUT_FILE"
echo "$COMMITS" | awk '
  /^feat/ { print "### Added\n\n" $0 "\n" }
  /^fix/ { print "### Fixed\n\n" $0 "\n" }
  /^refactor/ { print "### Changed\n\n" $0 "\n" }
  /^remove/ { print "### Removed\n\n" $0 "\n" }
' >> "$OUTPUT_FILE"

echo "Generated changelog saved to $OUTPUT_FILE"