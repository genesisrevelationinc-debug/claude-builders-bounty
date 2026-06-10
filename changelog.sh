#!/bin/bash

# Exit on any error
set -e

# Get the latest tag
latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)

# If no tags exist, get all commits from the beginning
if [ -z "$latest_tag" ]; then
    range=""
    since_tag=""
else
    range="$latest_tag..HEAD"
    since_tag="since $latest_tag"
fi

# Get commits in the format: "type: message"
commits=$(git log $range --pretty=format:"%s" --no-merges)

# Initialize sections
added=""
fixed=""
changed=""
removed=""

# Process each commit and categorize based on prefix
while read -r line; do
    if [[ $line == Added:* ]] || [[ $line == feat:* ]] || [[ $line == add:* ]]; then
        added+="  - $line\n"
    elif [[ $line == Fixed:* ]] || [[ $line == fix:* ]] || [[ $line == fixes:* ]] || [[ $line == bugfix:* ]]; then
        fixed+="  - $line\n"
    elif [[ $line == Changed:* ]] || [[ $line == updated:* ]] || [[ $line == update:* ]]; then
        changed+="  - $line\n"
    elif [[ $line == Removed:* ]] || [[ $line == Removed:* ]] || [[ $line == remove:* ]] || [[ $line == delete:* ]] || [[ $line == deleted:* ]]; then
        removed+="  - $line\n"
    fi
done <<< "$commits"

# Create CHANGELOG.md content
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
if [ -n "$since_tag" ]; then
    echo "## Changes $since_tag" >> CHANGELOG.md
else
    echo "## All Changes" >> CHANGELOG.md
fi
echo "" >> CHANGELOG.md
if [ -n "$added" ]; then echo "### Added" >> CHANGELOG.md && echo -e "$added" >> CHANGELOG.md; fi
if [ -n "$fixed" ]; then echo "### Fixed" >> CHANGELOG.md && echo -e "$fixed" >> CHANGELOG.md; fi
if [ -n "$changed" ]; then echo "### Changed" >> CHANGELOG.md && echo -e "$changed" >> CHANGELOG.md; fi
if [ -n "$removed" ]; then echo "### Removed" >> CHANGELOG.md && echo -e "$removed" >> CHANGELOG.md; fi

echo "CHANGELOG.md has been generated successfully!"