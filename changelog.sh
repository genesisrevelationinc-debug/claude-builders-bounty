#!/bin/bash
#
# CHANGELOG Generator Script
#

# Function to get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
}

# Get the previous tag from the latest tag
PREVIOUS_TAG=$(get_latest_tag)

# If no previous tag, set it to the initial commit
if [ "$PREVIOUS_TAG" = "v0.0.0" ]; then
    PREVIOUS_TAG=$(git rev-list --max-parents=0 HEAD)
fi

# Create a temporary file to store the changelog
CHANGELOG_TEMP=$(mktemp)

# Write the changelog header
echo "# Changelog" > "$CHANGELOG_TEMP"
echo "" >> "$CHANGELOG_TEMP"

# Get the current date
DATE=$(date +%%Y-%%m-%%d)

echo "## $DATE" >> "$CHANGELOG_TEMP"
echo "" >> "$CHANGELOG_TEMP"

# Get the commits since the last tag
if [ "$PREVIOUS_TAG" != "" ]; then
    COMMITS=$(git log --pretty=format:"%%s" $PREVIOUS_TAG..HEAD)
else
    COMMITS=$(git log --pretty=format:"%%s" HEAD)
fi

# Categorize commits
ADDED=()
FIXED=()
CHANGED=()
REMOVED=()

while read -r line; do
    if [[ $line == *"add:"* ]] || [[ $line == *"feature:"* ]] || [[ $line == *"feat:"* ]]; then
        ADDED+=("$line")
    elif [[ $line == *"fix:"* ]]; then
        FIXED+=("$line")
    elif [[ $line == *"change:"* ]] || [[ $line == *"refactor:"* ]] || [[ $line == *"chore:"* ]]; then
        CHANGED+=("$line")
    elif [[ $line == *"remove:"* ]] || [[ $line == *"delete:"* ]]; then
        REMOVED+=("$line")
    else
        CHANGED+=("$line")
    fi
done <<< "$COMMITS"

echo "### Added" >> "$CHANGELOG_TEMP"
printf '%s\n' "${ADDED[@]}" >> "$CHANGELOG_TEMP"
echo "### Fixed" >> "$CHANGELOG_TEMP"
printf '%s\n' "${FIXED[@]}" >> "$CHANGELOG_TEMP"
echo "### Changed" >> "$CHANGELOG_TEMP"
printf '%s\n' "${CHANGED[@]}" >> "$CHANGELOG_TEMP"
echo "### Removed" >> "$CHANGELOG_TEMP"
printf '%s\n' "${REMOVED[@]}" >> "$CHANGELOG_TEMP"

cat "$CHANGELOG_TEMP"
rm "$CHANGELOG_TEMP"