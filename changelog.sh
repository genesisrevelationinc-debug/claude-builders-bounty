#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest tag, or empty if no tags exist
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Build the git log range
if [ -n "$LATEST_TAG" ]; then
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    VERSION="${LATEST_TAG}"
else
    COMMIT_RANGE="HEAD"
    VERSION="unreleased"
fi

# Fetch commits since last tag (or all commits if no tag)
COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%s" 2>/dev/null || true)

if [ -z "$COMMITS" ]; then
    echo "No commits found since last tag."
    exit 0
fi

# Categorize commits
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

while IFS= read -r line; do
    # Skip empty lines and merge commits
    [ -z "$line" ] && continue
    [[ "$line" =~ ^Merge[[:space:]] ]] && continue

    # Categorize based on conventional commit patterns
    if [[ "$line" =~ ^[Ff]eat(\(.*\))?: ]] || [[ "$line" =~ ^[Aa]dd ]] || [[ "$line" =~ ^[Aa]dded ]]; then
        ADDED="${ADDED}- ${line}"$'\n'
    elif [[ "$line" =~ ^[Ff]ix(\(.*\))?: ]] || [[ "$line" =~ ^[Ff]ixed ]] || [[ "$line" =~ ^[Bb]ugfix ]] || [[ "$line" =~ ^[Rr]esolve ]] || [[ "$line" =~ ^[Ss]olve ]]; then
        FIXED="${FIXED}- ${line}"$'\n'
    elif [[ "$line" =~ ^[Rr]emove(\(.*\))?: ]] || [[ "$line" =~ ^[Rr]emoved ]] || [[ "$line" =~ ^[Dd]elete ]] || [[ "$line" =~ ^[Dd]eleted ]]; then
        REMOVED="${REMOVED}- ${line}"$'\n'
    elif [[ "$line" =~ ^[Cc]hange(\(.*\))?: ]] || [[ "$line" =~ ^[Cc]hanged ]] || [[ "$line" =~ ^[Uu]pdate ]] || [[ "$line" =~ ^[Uu]pdated ]] || [[ "$line" =~ ^[Rr]efactor ]] || [[ "$line" =~ ^[Rr]estyle ]] || [[ "$line" =~ ^[Mm]odify ]] || [[ "$line" =~ ^[Mm]odified ]]; then
        CHANGED="${CHANGED}- ${line}"$'\n'
    else
        OTHER="${OTHER}- ${line}"$'\n'
    fi
done <<< "$COMMITS"

# Build the changelog entry
CHANGELOG_ENTRY="## [${VERSION}] - ${DATE}"$'\n\n'

if [ -n "$ADDED" ]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Added"$'\n\n'"${ADDED}"$'\n'
fi

if [ -n "$CHANGED" ]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Changed"$'\n\n'"${CHANGED}"$'\n'
fi

if [ -n "$FIXED" ]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Fixed"$'\n\n'"${FIXED}"$'\n'
fi

if [ -n "$REMOVED" ]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Removed"$'\n\n'"${REMOVED}"$'\n'
fi

if [ -n "$OTHER" ]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### Other"$'\n\n'"${OTHER}"$'\n'
fi

# Check if CHANGELOG.md exists
if [ -f "$CHANGELOG_FILE" ]; then
    # Prepend new entry after the header
    EXISTING=$(cat "$CHANGELOG_FILE")
    # Find where to insert (after the first header)
    if echo "$EXISTING" | grep -q "^# Changelog"; then
        {
            echo "# Changelog"
            echo ""
            echo "$CHANGELOG_ENTRY"
            echo "$EXISTING" | tail -n +3
        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    else
        {
            echo "# Changelog"
            echo ""
            echo "$CHANGELOG_ENTRY"
            cat "$CHANGELOG_FILE"
        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    fi
else
    # Create new CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "$CHANGELOG_ENTRY"
    } > "$CHANGELOG_FILE"
fi

echo "✅ CHANGELOG.md generated successfully!"
echo ""
echo "Preview:"
head -n 30 "$CHANGELOG_FILE"