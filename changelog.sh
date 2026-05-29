#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# This script fetches commits since the last git tag and automatically
# categorizes them into Added, Fixed, Changed, and Removed sections.

set -e

# Function to get the latest git tag
get_latest_tag() {
  git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Function to get commits between two references
get_commits() {
  local from=$1
  if [ -z "$from" ]; then
    # If no previous tag, get all commits
    git log --oneline --no-merges
  else
    # Get commits since the last tag
    git log "$from"..HEAD --oneline --no-merges
  fi
}

# Function to categorize commits
categorize_commits() {
  local commits="$1"
  local added=""
  local fixed=""
  local changed=""
  local removed=""

  # Process each commit
  while IFS= read -r commit; do
    # Extract just the commit message (skip the hash)
    message=$(echo "$commit" | sed 's/^[0-9a-f]* *//')
    
    # Categorize based on prefixes
    case "$message" in
      Add:*|add:*|Added:*|added:*)
        added+="- $message"$'\n'
        ;;
      Fix:*|fix:*|Fixed:*|fixed:*)
        fixed+="- $message"$'\n'
        ;;
      Remove:*|remove:*|Removed:*|removed:*)
        removed+="- $message"$'\n'
        ;;
      Change:*|change:*|Changed:*|changed:*)
        changed+="- $message"$'\n'
        ;;
      *:*|*: *) 
        # Try to extract category from colon prefix
        prefix=$(echo "$message" | cut -d: -f1 | tr '[:upper:]' '[:lower:]')
        content=$(echo "$message" | cut -d: -f2- | sed 's/^ *//')
        case "$prefix" in
          add|added|adding)
            added+="- $content"$'\n'
            ;;
          fix|fixed)
            fixed+="- $content"$'\n'
            ;;
          remove|removed)
            removed+="- $content"$'\n'
            ;;
          change|changed|update|updated)
            changed+="- $content"$'\n'
            ;;
          *)
            # Default to Added for unknown prefixes
            added+="- $message"$'\n'
            ;;
        esac
        ;;
      *)
        # Default to Added for commits without colons
        added+="- $message"$'\n'
        ;;
    esac
  done <<< "$commits"

  echo "added|$added|fixed|$fixed|changed|$changed|removed|$removed"
}

# Main execution
main() {
  local latest_tag=$(get_latest_tag)
  local commits=$(get_commits "$latest_tag")
  local categorized=$(categorize_commits "$commits")
  
  # Extract categorized sections
  local added=$(echo "$categorized" | awk -F'|' '{print $2}')
  local fixed=$(echo "$categorized" | awk -F'|' '{print $4}')
  local changed=$(echo "$categorized" | awk -F'|' '{print $6}')
  local removed=$(echo "$categorized" | awk -F'|' '{print $8}')
  
  # Generate the new changelog content
  echo "# Changelog" > CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)," >> CHANGELOG.md
  echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)." >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  echo "## [Unreleased]" >> CHANGELOG.md
  echo "" >> CHANGELOG.md
  
  if [ -n "$added" ]; then
    echo "### Added" >> CHANGELOG.md
    echo "$added" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
  fi
  
  if [ -n "$fixed" ]; then
    echo "### Fixed" >> CHANGELOG.md
    echo "$fixed" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
  fi
  
  if [ -n "$changed" ]; then
    echo "### Changed" >> CHANGELOG.md
    echo "$changed" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
  fi
  
  if [ -n "$removed" ]; then
    echo "### Removed" >> CHANGELOG.md
    echo "$removed" >> CHANGELOG.md
    echo "" >> CHANGELOG.md
  fi
}

main "$@"