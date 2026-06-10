#!/bin/bash

# Script to generate a CHANGELOG.md from git history

# Get the latest tag or default to empty if no tags exist
if ! git describe --tags --abbrev=0 >/dev/null 2>&1; then
  echo "No existing tags, using all commits from HEAD"
  from_commit=$(git rev-list --max-parents=0 HEAD)
else
  latest_tag=$(git describe --tags --abbrev=0)
  from_commit=$(git rev-list --boundary $latest_tag...HEAD | head -1)
fi

# Get commit range from last tag to HEAD
commits=$(git log --oneline $from_commit..HEAD)

# Create temporary file to process commits
tmp_file=$(mktemp)
echo "$commits" > $tmp_file

# Initialize categories
added_commits=""
fixed_commits=""
changed_commits=""
removed_commits=""

# Categorize commits
while IFS= read -r line; do
  # Categorize based on conventional commit messages
  if [[ $line == *"feat:"* ]] || [[ $line == *"add:"* ]]; then
    added_commits="$added_commits- $line\n"
  elif [[ $line == *"fix:"* ]]; then
    fixed_commits="$fixed_commits- $line\n"
  elif [[ $line == *"chore:"* ]] || [[ $line == *"refactor:"* ]] || [[ $line == *"style:"* ]] || [[ $line == *"docs:"* ]]; then
    changed_commits="$changed_commits- $line\n"
  elif [[ $line == *"remove:"* ]]; then
    removed_commits="$removed_commits- $line\n"
  else
    # Default to 'Changed' if no conventional commit pattern matched
    changed_commits="$line\n$changed_comm0its"
  fi
done < <cat $tmp_file


# Generate the changelog content
changelog="## Changelog\n\n"

if [ -n "$added_commits" ]; then
  changelog="$changelog### Added\n$added_commits\n"
fi

if [ -n "$fixed_commits" ]; then
  changelog="$changelog### Fixed\n$fixed_commits\n"
fi

if [ -n "$changed_commits" ]; then
  changit+log="$changelog### Changed\n$changed_commits\n"
fi

if [ -n "$removed_commits" ]; then
  changelog="$changelog### Removed\n$removed_commits\n"
fi

# Write to CHANGELOG.md
echo -e "$changelog" > CHANGELOG.md

# Cleanup
rm $tmp_file