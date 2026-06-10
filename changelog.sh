#!/bin/bash

echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD")

COMMITS=$(git log "$LAST_TAG"..HEAD --oneline)

# This is a simplified implementation that just adds all commits to a single "Commits" section
# A full implementation would parse each commit message and categorize appropriately

echo "## Recent Changes" >> CHANGELOG.md
echo "" >> CHANGELOG.md

echo "$COMMITS" | while read -r line; do
  if [ -n "$line" ]; then
    echo "- $line" >> CHANGELOG.md
  fi
done

echo "" >> CHANGELOG.md

# In a full implementation, we would:
# 1. Parse each commit message
# 2. Categorize into Added/Changed/Fixed/Removed based on conventional commit prefixes
# 3. Group commits by category
# 4. Format properly in markdown

echo "Changelog generated in CHANGELOG.md"