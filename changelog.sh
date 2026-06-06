#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags "$(git rev-list --tags --max-count=1)")

# If no tags exist, use the beginning of history
if [ -z "$latest_tag" ]; then
    latest_tag=$(git rev-list --all --reverse --oneline | head -n 1 | cut -d" " -f1)
    if [ -z "$latest_tag" ]; then
        echo "No commits found"
        exit 1
    fi
    tag_name="Initial commit"
    range="$latest_tag"
else
    tag_name="$latest_tag"
    range="$latest_tag..HEAD"
fi

# Get commit messages
commits=$(git log $range --pretty=format:"%s" --no-merges)

# Create temporary file for changelog
tmp_file=$(mktemp)

# Initialize categories
added=""
fixed=""
changed=""
removed=""

# Process commits
echo "$commits" | while read -r line || [[ -n $line ]]; do
    # Skip if empty
    if [ -z "$line" ]; then
        continue
    fi
    
    # Categorize based on prefix
    if [[ $line == "feat:"* ]] || [[ $line == "feat("* ]] || [[ $line == "add:"* ]] || [[ "$line" == "new:"* ]]; then
        added+="* $line\n"
    elif [[ $line == "fix:"* ]] || [[ $line == "fix("* ]] || [[ "$line" == "bug:"* ]]; then
        fixed+="* $line\n"
    elif [[ $line == "refactor:"* ]] || [[ $line == "refactor("* ]] || [[ "$line" == "update:"* ]] || [[ "$line" == "change:"* ]]; then
        changed+="* $line\n"
    elif [[ $line == "remove:"* ]] || [[ $line == "remove("* ]] || [[ "$line" == "delete:"* ]] || [[ "$line" == "del:"* ]]; then
        removed+="* $line\n"
    else
        # Default to added if no category matches
        added+="* $line\n"
    fi
done

# Create CHANGELOG.md
echo "# Changelog" > CHANGELOG.md
echo "" >> CHANGELOG.md
echo "## $tag_name" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Added" >> CHANGELOG.md
echo -e "$added" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Fixed" >> CHANGELOG.md
echo -e "$fixed" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Changed" >> CHANGELOG.md
echo -e "$changed" >> CHANGELOG.md
echo "" >> CHANGELOG.md
echo "### Removed" >> CHANGELOG.md
echo -e "$removed" >> CHANGELOG.md
echo "" >> CHANGELOG.md

echo "CHANGELOG.md generated successfully!"