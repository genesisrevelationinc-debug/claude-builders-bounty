#!/bin/bash

# Generate a structured CHANGELOG.md from git history

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# If no tag exists, use all commits
if [ -z "$LAST_TAG" ]; then
    COMMITS_RANGE=""
    echo "No tags found. Generating changelog for all commits."
else
    COMMITS_RANGE="$LAST_TAG..HEAD"
    echo "Generating changelog from $LAST_TAG to HEAD"
fi

# Create temporary file for commits
TEMP_FILE=$(mktemp)

# Get commits and save to temp file
git log --pretty=format:"%s" $COMMITS_RANGE > "$TEMP_FILE"

# Create CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)," >> CHANGELOG.md
echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)." >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## [Unreleased]" >> CHANGELOG.md
echo "" >> CHANGELOG.md

# Initialize sections
added=""
fixed=""
changed=""
removed=""

# Categorize commits
while IFS= read -r commit; do
    case "$commit" in
        Added*|Add*|New*) added+="- $commit"$'\n' ;;
        Fixed*|Fix*|Bug*) fixed+="- $commit"$'\n' ;;
        Changed*|Change*|Update*) changed+="- $commit"$'\n' ;;
        Removed*|Remove*|Delete*) removed+="- $commit"$'\n' ;;
    esac
done < "$TEMP_FILE"

# Write sections to CHANGELOG.md
[ -n "$added" ] && echo "### Added" >> CHANGELOG.md && echo "$added" >> CHANGELOG.md
[ -n "$fixed" ] && echo "### Fixed" >> CHANGELOG.md && echo "$fixed" >> CHANGELOG.md
[ -n "$changed" ] && echo "### Changed" >> CHANGELOG.md && echo "$changed" >> CHANGELOG.md
[ -n "$removed" ] && echo "### Removed" >> CHANGELOG.md && echo "$removed" >> CHANGELOG.md

# Cleanup
rm "$TEMP_FILE"

echo "CHANGELOG.md generated successfully!"