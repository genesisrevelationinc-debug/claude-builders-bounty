#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags $(git tag --sort=-v:refname | head -n 1)

# Get all commits since the last tag
if [ -z "$latest_tag" ]; then
  # If no tag exists, get all commits from the beginning
  commits=$(git log --oneline)
else
  # Get commits since the last tag
  commits=$(git log $latest_tag..HEAD --oneline)
fi

# If no commits since last tag, exit gracefully
if [ -z "$commits" ]; then
  echo "No commits since last tag ($latest_tag)"
  echo "No changes to add to changelog."
  exit 0
fi

# Create a temporary file for the changelog content
tmp_file=$(mktemp)

# Initialize categories
added=""
fixed=""
changed=""
removed=""

# Categorize commits based on keywords in subject
while IFS= read -r line; do
  if [[ $line == *"fix:"* ]] || [[ $line == *"fix("* ]] || [[ $line == *"fixed:"* ]] || [[ $line == *"fixed("* ]]; then
    fixed+="  - $line"$'\n'
  elif [[ $line == *"remove:"* ]] || [[ $line == *"remove("* ]] || [[ $line == *"removed:"* ]] || [[ $line == *"removed("* ]] || [[ $line == *"delete:"* ]] || [[ $line == *"deleted:"* ]]; then
    removed+="  - $line"$'\n'
  elif [[ $line == *"change:"* ]] || [[ $line == *"change("* ]] || [[ $line == *"update:"* ]] || [[ $line == *"updated:"* ]] || [[ $line == *"modify:"* ]] || [[ $line == *"modified:"* ]] || [[ $line == *"refactor:"* ]]; then
    changed+="  - $line"$'\n'
  else
    added+="  - $line"$'\n'
  fi
done <<< "$commits"

# Function to write section if not empty
write_section() {
  local section_content=$1
  local section_title=$2
  if [ -n "$section_content" ]; then
    echo "## $section_title" >> "$tmp_file"
    echo -e "$section_content" >> "$tmp_file"
  fi
}

# Write changelog to tmp file
echo "# Changelog" > "$tmp_file"
echo "" >> "$tmp_file"
write_section "$added" "Added" 
write_section "$fixed" "Fixed"
write_section "$changed" "Changed" 
write_section "$removed" "Removed"

# If changelog file exists, back it up
if [ -f "CHANGELOG.md" ]; then
  mv CHANGELOG.md CHANGELOG.md.backup
fi

# Move the new changelog in place
mv "$tmp_file" CHANGELOG.md

echo "Changelog generated successfully!"