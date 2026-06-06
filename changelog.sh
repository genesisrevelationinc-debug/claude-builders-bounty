#!/bin/bash

# Exit on any error
set -e

# Get the latest tag or default to v0.0.0
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Get commits since the latest tag
COMMITS=$(git log $LATEST_TAG..HEAD --no-merges --oneline)

# Initialize arrays for each category
ADDED=()
FIXED=()
CHANGED=()
REMOVED=()

# Categorize commits
while IFS= read -r line; do
  if [[ $line == *"feat:"* ]]; then
    ADDED+=("${line#*feat: }")
  elif [[ $line == *"fix:"* ]]; then
    FIXED+=("${line#*fix: }")
  elif [[ $line == *"remove:"* ]] || [[ $line == *"delete:"* ]]; then
    REMOVED+=("${line#*remove: }")
    REMOVED+=("${line#*delete: }")
  elif [[ $line == *"chore:"* ]] || [[ $line == *"refactor:"* ]]; then
    CHANGED+=("${line#*chore: }")
    CHANGED+=("${line#*refactor: }")
  fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
{
  echo "# Changelog"
  echo ""
  echo "## [$LATEST_TAG] - $(date +%Y-%m-%d)"
  echo ""

  if [ ${#ADDED[@]} -gt 0 ]; then
    echo "### Added"
    for item in "${ADDED[@]}"; do
      echo "- $item"
    done
    echo ""
  fi

  if [ ${#FIXED[@]} -gt 0 ]; then
    echo "### Fixed"
    for item in "${FIXED[@]}"; do
      echo "- $item"
    done
    echo ""
  fi

  # ... (similarly for CHANGED and REMOVED)
} > CHANGELOG.md

echo "CHANGELOG.md generated successfully!"