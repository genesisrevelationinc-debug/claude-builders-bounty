#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
REPO_URL=$(git remote get-url origin 2>/dev/null | sed 's/\.git$//' || echo "")

# Get the latest tag; if none, use the first commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE=""
else
    echo "Generating changelog since tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# Fetch commits: hash, subject
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%H|%s" --no-merges)
else
    COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%H|%s" --no-merges)
fi

if [ -z "$COMMITS" ]; then
    echo "No new commits found since ${LATEST_TAG:-'the beginning'}."
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

while IFS= read -r line; do
    HASH=$(echo "$line" | cut -d'|' -f1)
    SUBJECT=$(echo "$line" | cut -d'|' -f2-)
    
    # Generate commit link if repo URL looks like a GitHub URL
    if [[ "$REPO_URL" == *"github.com"* ]]; then
        SHORT_HASH="${HASH:0:7}"
        COMMIT_LINK="[$SHORT_HASH](${REPO_URL}/commit/${HASH})"
    else
        COMMIT_LINK="${HASH:0:7}"
    fi
    
    FORMATTED="- ${SUBJECT} — ${COMMIT_LINK}"
    
    # Categorize based on conventional commit keywords and patterns
    LOWER_SUBJECT=$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$LOWER_SUBJECT" == feat* ]] || [[ "$LOWER_SUBJECT" == add* ]] || [[ "$LOWER_SUBJECT" == implement* ]] || [[ "$LOWER_SUBJECT" == introduce* ]]; then
        ADDED="${ADDED}${FORMATTED}"$'\n'
    elif [[ "$LOWER_SUBJECT" == fix* ]] || [[ "$LOWER_SUBJECT" == bugfix* ]] || [[ "$LOWER_SUBJECT" == resolve* ]] || [[ "$LOWER_SUBJECT" == patch* ]]; then
        FIXED="${FIXED}${FORMATTED}"$'\n'
    elif [[ "$LOWER_SUBJECT" == remove* ]] || [[ "$LOWER_SUBJECT" == delete* ]] || [[ "$LOWER_SUBJECT" == drop* ]] || [[ "$LOWER_SUBJECT" == deprecate* ]]; then
        REMOVED="${REMOVED}${FORMATTED}"$'\n'
    elif [[ "$LOWER_SUBJECT" == change* ]] || [[ "$LOWER_SUBJECT" == update* ]] || [[ "$LOWER_SUBJECT" == refactor* ]] || [[ "$LOWER_SUBJECT" == modify* ]] || [[ "$LOWER_SUBJECT" == improve* ]] || [[ "$LOWER_SUBJECT" == chore* ]] || [[ "$LOWER_SUBJECT" == docs* ]] || [[ "$LOWER_SUBJECT" == style* ]] || [[ "$LOWER_SUBJECT" == perf* ]] || [[ "$LOWER_SUBJECT" == test* ]]; then
        CHANGED="${CHANGED}${FORMATTED}"$'\n'
    else
        OTHER="${OTHER}${FORMATTED}"$'\n'
    fi
done <<< "$COMMITS"

# Build the new changelog section
DATE=$(date +%Y-%m-%d)
VERSION=${LATEST_TAG:-"Unreleased"}

NEW_SECTION="## [${VERSION}] - ${DATE}"$'\n\n'

if [ -n "$ADDED" ]; then
    NEW_SECTION="${NEW_SECTION}### Added"$'\n\n'"${ADDED}"$'\n'
fi

if [ -n "$FIXED" ]; then
    NEW_SECTION="${NEW_SECTION}### Fixed"$'\n\n'"${FIXED}"$'\n'
fi

if [ -n "$CHANGED" ]; then
    NEW_SECTION="${NEW_SECTION}### Changed"$'\n\n'"${CHANGED}"$'\n'
fi

if [ -n "$REMOVED" ]; then
    NEW_SECTION="${NEW_SECTION}### Removed"$'\n\n'"${REMOVED}"$'\n'
fi

if [ -n "$OTHER" ]; then
    NEW_SECTION="${NEW_SECTION}### Other"$'\n\n'"${OTHER}"$'\n'
fi

# Prepend to existing CHANGELOG or create new one
if [ -f "$CHANGELOG_FILE" ]; then
    EXISTING=$(cat "$CHANGELOG_FILE")
    # Check if header exists
    if [[ "$EXISTING" == *"# Changelog"* ]]; then
        # Insert after the header
        HEADER=$(echo "$EXISTING" | sed -n '1,/^$/p')
        REST=$(echo "$EXISTING" | sed '1,/^$/d')
        echo -e "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n${NEW_SECTION}${REST}" > "$CHANGELOG_FILE"
    else
        echo -e "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n${NEW_SECTION}${EXISTING}" > "$CHANGELOG_FILE"
    fi
else
    echo -e "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\n${NEW_SECTION}" > "$CHANGELOG_FILE"
fi

echo "CHANGELOG.md generated successfully!"
if [ -n "$LATEST_TAG" ]; then
    echo "Included commits since tag: $LATEST_TAG"
fi