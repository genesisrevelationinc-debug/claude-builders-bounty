#!/bin/bash

# changelog.sh - Generate a structured CHANGELOG.md from git history

set -e

# Configuration
CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Cleanup function
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

# Get the latest tag or use initial commit if no tags exist
if ! git describe --tags --abbrev=0 HEAD >/dev/null 2>&1; then
    LAST_TAG=$(git rev-list --max-parents=0 HEAD)
else
    LAST_TAG=$(git describe --tags --abbrev=0 HEAD)
fi

# Get commits since last tag
COMMITS=$(mktemp)
trap "rm -f $COMMITS" EXIT
git log --no-merges --pretty=format:"- %s" "$LAST_TAG..HEAD" > "$COMMITS" 2>/dev/null || true

# Create categories
ADDED=$(mktemp)
FIXED=$(mktemp)
CHANGED=$(mktemp)
REMOVED=$(mktemp)
trap "rm -f $ADDED $FIXED $CHANGED $REMOVED" EXIT

# Categorize commits
while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove the leading "- " from commit line
    commit_msg=${line#- }
    case "$commit_msg" in
        *"add"*)
            echo "$commit_msg" >> "$ADDED"
            ;;
        *"Add"*)
            echo "$commit_msg" >> "$ADDED"
            ;;
        *"fix"*)
            echo "$commit_msg" >> "$FIXED"
            ;;
        *"Fix"*)
            echo "$commit_msg" >> "$FIXED"
            ;;
        *"remove"*)
            echo "$commit_msg" >> "$REMOVED"
            ;;
        *"Remove"*)
            echo "$commit_msg" >> "$REMOVED"
            ;;
        *"delete"*)
            echo "$commit_msg" >> "$REMOVED"
            ;;
        *"Delete"*)
            echo "$commit_msg" >> "$REMOVED"
            ;;
        *)
            echo "$commit_msg" >> "$CHANGED"
            ;;
    esac
done < "$COMMITS"

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    
    # Only output categories that have content
    if [ -s "$ADDED" ]; then
        echo "## Added"
        echo ""
        cat "$ADDED"
        echo ""
    fi
    
    if [ -s "$FIXED" ]; then
        echo "## Fixed"
        echo ""
        cat "$FIXED"
        echo ""
    fi
    
    if [ -s "$CHANGED" ]; then
        echo "## Changed"
        echo ""
        cat "$CHANGED"
        echo ""
    fi
    
    if [ -s "$REMOVED" ]; then
        echo "## Removed"
        echo ""
        cat "$REMOVED"
        echo ""
    fi
} > "$CHANGELOG_FILE"

echo "Changelog generated in $CHANGELOG_FILE"