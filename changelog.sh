#!/bin/bash

# changelog.sh - A script to generate CHANGELOG.md from git history

set -e

# Get the latest git tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$latest_tag" ]; then
  # If no tags, get all commits
  since_ref=""
  echo "No previous tag found. Including all commits."
else
  # Use triple dot syntax to get commits since the last tag
  since_ref="$latest_tag..HEAD"
  echo "Generating changelog since: $latest_tag"
fi

# Get commit hashes and messages since last tag (or all if no tag)
if [ -z "$latest_tag" ]; then
  commits=$(git log --pretty=format:"%h|%s" 2>/dev/null)
else
  commits=$(git log $since_ref --pretty=format:"%h|%s" 2>/dev/null)
fi

# Initialize categories
added=""
fixed=""
changed=""
removed=""

# Read through the commits and categorize
echo "$commits" | while IFS='|' read -r hash message; do
  # Categorize based on commit message
  if [[ $message == fix* ]] || [[ $message == Fix* ]] || [[ $message == "fix:"* ]] || [[ $message == "Fix:"* ]]; then
    fixed="$fixed- $message ($hash)$IFS"
  elif [[ $message == add* ]] || [[ $message == Add* ]] || [[ $message == "* add"* ]] || [[ $message == "* Add"* ]]; then
    added="$added- $message ($hash)$IFS"
  elif [[ $message == change* ]] || [[ $message == Change* ]] || [[ $message == "change:"* ]] || [[ $message == "Change:"* ]]; then
    changed="$changed- $message ($hash)$IFS"
  elif [[ $message == remove* ]] || [[ $message == Remove* ]] || [[ $message == "remove:"* ]] || [[ $message == "Remove:"* ]]; then
    removed="$removed- $message ($hash)$IFS"
  fi
done

# Generate the CHANGELOG.md
{
  echo "# Changelog"
  echo ""

  if [ -n "$added" ]; then
    echo "## Added"
    echo "$added"
    echo ""
  fi
  if [ -n "$fixed" ]; then
    echo "## Fixed"
    echo "$fixed"
    echo ""
  fi
  if [ -n "$changed" ]; then
    echo "## Changed"
    echo "$changed"
    echo ""
  fi
  if [ -n "$removed" ]; then
    echo "## Removed"
    echo "$removed"
    echo ""
  fi
} > CHANGELOG.md

echo "CHANGELOG.md generated!"