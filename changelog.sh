#!/bin/bash

# Get the last tag or default to v0.0.0
LAST_TAG=$(git describe --tags --abbrev=0 --always --first-parent 2>/dev/empty)
if [ -z "$LAST_TAG" ]; then
    LAST_TAG="v0.0.0"
fi

# Get commit hash from last tag or initial commit
if [ "$LAST_TAG" != "v0.0.0" ]; then
    LAST_TAG_COMMIT=$(git rev-list -n 1 $LAST_TAG)
else
    LAST_TAG_COMMIT=$(git rev-parse HEAD)
fi

# Get the initial commit if there's no tag
if [ "$LAST_TAG" = "v0.0.0" ]; then
    INITIAL_COMMIT=$(git rev-list --max-parents=0 HEAD)
    if [ -z "$INITIAL_COMMIT" ]; then
        INITIAL_COMMIT=$(git rev-parse HEAD)
    fi
fi

# Get commits between last tag and now
COMMITS=$(git log $LAST_TAG_COMMIT..HEAD --oneline --no-merges)

# Create a temporary file for the changelog
CHANGELOG_FILE="CHANGELOG.md"
touch $CHANGELOG_FILE

# Write the changelog
echo "# Changelog" > $CHANGELOG_FILE
echo "All notable changes to this project will be documented in this file." >> $CHANGELOG_FILE
echo "" >> $CHANGELOG_FILE

# Auto-categorize commits
echo "## [Added]" >> $CHANGELOG_FILE
echo "" >> $CHANGELOG_FILE
echo "$COMMITS" | grep -E "^[a-zA-Z0-9]+" | while read line; do
    if [ -n "$line" ]; then
        echo "* $line" >> $CHANGELOG_FILE
    fi
done
echo "" >> $CHANGELOG_FILE