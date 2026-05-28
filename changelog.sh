#!/bin/bash

# Get the last tag
last_tag=$(git describe --tags $(git rev-list --tags --max-count=1))

# Get the commits since the last tag
commits=$(git log --pretty=format:"%s" $last_tag..HEAD)

# Initialize changelog categories
added=""
fixed=""
changed=""
removed=""

# Categorize commits
while IFS= read -r commit; do
    if [[ $commit == *"add"* ]] || [[ $commit == *"Add"* ]] || [[ $commit == *"added"* ]] || [[ $commit == *"Added"* ]] || [[ $commit == *"feat"* ]] || [[ $commit == *"feature"* ]]; then
        added="$added- $commit"$'\n'
    elif [[ $commit == *"fix"* ]] || [[ $commit == *"Fix"* ]] || [[ $commit == *"fixed"* ]] || [[ $commit == *"Fixed"* ]]; then
        fixed="$fixed- $commit"$'\n'
    elif [[ $commit == *"change"* ]] || [[ $commit == *"Change"* ]] || [[ $commit == *"changed"* ]] || [[ $commit == *"Changed"* ]] || [[ $commit == *"update"* ]] || [[ $commit == *"Update"* ]]; then
        changed="$changed- $commit"$'\n'
    elif [[ $commit == *"remove"* ]] || [[ $commit == *"Remove"* ]] || [[ $commit == *"removed"* ]] || [[ $commit == *"Removed"* ]] || [[ $commit == *"delete"* ]] || [[ $commit == *"Delete"* ]]; then
        removed="$removed- $commit"$'\n'
    else
        added="$added- $commit"$'\n'
    fi
done < <(echo "$commits")

# Write the changelog
if [ -n "$added" ]; then
    echo "### Added" >> CHANGELOG.md
    echo "$added" >> CHANGELOG.md
fi

if [ -n "$fixed" ]; then
    echo "### Fixed" >> CHANGELOG.md
    echo "$fixed" >> CHANGELOG.md
fi

if [ -n "$changed" ]; then
    echo "### Changed" >> CHANGELOG.md
    echo "$changed" >> CHANGELOG.md
fi

if [ -n "$removed" ]; then
    echo "### Removed" >> CHANGELOG.md
    echo "$removed" >> CHANGELOG.md
fi

echo "Generated CHANGELOG.md"