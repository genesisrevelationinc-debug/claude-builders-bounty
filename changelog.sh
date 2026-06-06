#!/bin/bash

# Configuration
OUTPUT_FILE="CHANGELOG.md"

# Get the last git tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag is found, use the initial commit
if [ -z "$LAST_TAG" ]; then
  LAST_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit messages from the last tag to HEAD
if [ -z "$LAST_TAG" ]; then
  COMMITS=$(git log --oneline)
else
  COMMITS=$(git log $LAST_TAG..HEAD --oneline 2>/dev/null || git log --oneline)
fi

# Initialize categories
declare -a ADDED=()
declare -a CHANGED=()
declare -a FIXED=()
declare -a REMOVED=()

# Categorize commits based on prefixes
echo "$COMMITS" | while read -r line; do
  if [[ $line == *"feat:"* ]] || [[ $line == *"add:"* ]] || [[ $line == *"new:"* ]]; then
    ADDED+=("$line")
  elif [[ $line == *"fix:"* ]] || [[ $line == *"fixed:"* ]] || [[ $line == *"bug:"* ]]; then
    FIXED+=("$line")
  elif [[ $line == *"remove:"* ]] || [[ $line == *"del:"* ]] || [[ $line == *"delete:"* ]]; then
    REMOVED+=("$line")
  elif [[ $line == *"update:"* ]] || [[ $line == *"change:"* ]] || [[ $line == *"refactor:"* ]] || [[ $line == *"deprecated:"* ]]; then
    CHANGED+=("$line")
  else
    # Default to "Changed" if no prefix is found
    CHANGED+=("$line")
  fi
done

# Function to write section to file
write_section() {
  local section_name=$1
  local -n commits_ref=$2
  if [ ${#commits_ref[@]} -gt 0 ]; then
    echo "### $section_name" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    for commit in "${commits_ref[@]}"; do
      # Remove commit hash and prefix from the commit message for cleaner output
      clean_message=$(echo "$commit" | sed 's/^[a-z0-9]*\s*[a-z]*:\s*//' | sed 's/^[a-z]*\s*//')
      echo "- $clean_message" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
  fi
}

# Create or clear the changelog file
> "$OUTPUT_FILE"

# Write changelog
echo "# Changelog" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

write_section "Added" ADDED
write_section "Changed" CHANGED
write_section "Fixed" FIXED
write_section "Removed" REMOVED

echo "CHANGELOG.md has been generated."