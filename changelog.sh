#!/bin/bash

# Generate a structured CHANGELOG.md from git history

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tags found, use the initial commit
if [ -z "$latest_tag" ]; then
  latest_tag=$(git rev-list --max-parents=0 HEAD)
fi

# Get commit messages since the latest tag
commits=$(git log --pretty=format:"%s" "$latest_tag"..HEAD)

# Initialize changelog sections
added=""
fixed=""
changed=""
removed=""

# Categorize commits (simplified logic based on prefixes)
while IFS= read -r commit; do
  case "$commit" in
    Add*|add*|ADD*) added+="- $commit\n" ;;
    Fix*|fix*|FIX*) fixed+="- $commit\n" ;;
    Change*|change*|CHANGE*) changed+="- $commit\n" ;;
    Remove*|remove*|REMOVE*) removed+="- $commit\n" ;;
    *) added+="- $commit\n" ;; # Default to Added
  esac
done <<< "$commits"

# Get current date
date=$(date +"%Y-%m-%d")

# Generate the changelog content
changelog_content="# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
${added}
### Fixed
${fixed}
### Changed
${changed}
### Removed
${removed}
"

# Write to CHANGELOG.md
echo -e "$changelog_content" > CHANGELOG.md

echo "CHANGELOG.md has been generated successfully."