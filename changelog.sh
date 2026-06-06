#!/bin/bash

# Exit on any error
set -e

# Function to print usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "  --help     Show this message"
  echo "  --since    Starting tag (default: latest tag)"
  echo "  --until    Ending tag (default: HEAD)"
  exit 1
}

# Parse arguments
SINCE=""
UNTIL="HEAD"

while [[ $# -gt 0 ]]; do
  case $1 in
    --help)
      usage
      ;;
    --since)
      SINCE="$2"
      shift 2
      ;;
    --until)
      UNTIL="$2"
      shift 2
      ;;
    *)
      echo "Unknown option $1"
      usage
      ;;
  esac
done

# Get latest tag if not specified
if [ -z "$SINCE" ]; then
  SINCE=$(git describe --tags --abbrev=0 2>/dev/null)
  if [ -z "$SINCE" ]; then
    echo "No git tags found. Please create at least one tag or specify --since."
    exit 1
  fi
fi

# Create temporary file for commit messages
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Get commit messages
git log "$SINCE..$UNTIL" --no-merges --pretty=format:"- %s" > "$TEMP_FILE"

# Initialize CHANGELOG.md
cat > CHANGELOG.md << EOF
# Changelog

## [Unreleased]
EOF

# Categorize commits
ADDED=$(grep -i 'add\|feat' "$TEMP_FILE" | sed 's/^- //')
FIXED=$(grep -i 'fix\|patch' "$TEMP_FILE" | sed 's/^- //')
CHANGED=$(grep -i 'change\|update\|modify' "$TEMP_FILE" | sed 's/^- //')
REMOVED=$(grep -i 'remove\|delete' "$TEMP_FILE" | sed 's/^- //')

# Write categories to changelog if they have content
if [ -n "$ADDED" ]; then
  echo -e "\n### Added\n$ADDED" >> CHANGELOG.md
fi

if [ -n "$FIXED" ]; then
  echo -e "\n### Fixed\n$FIXED" >> CHANGELOG.md
fi

if [ -n "$CHANGED" ]; then
  echo -e "\n### Changed\n$CHANGED" >> CHANGELOG.md
fi

if [ -n "$REMOVED" ]; then
  echo -e "\n### Removed\n$REMOVED" >> CHANGELOG.md
fi

echo "CHANGELOG.md generated successfully!"