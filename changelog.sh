#!/bin/bash

# Generate a structured CHANGELOG.md from git history

# Configuration
CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)

# Determine commit range
if [ -z "$LAST_TAG" ]; then
    echo "No tags found. Processing all commits."
    COMMITS=$(git log --pretty=format:"%s" --reverse)
else
    echo "Processing commits since tag: $LAST_TAG"
    COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"%s" --reverse)
fi

# Initialize categories
added=()
fixed=()
changed=()
removed=()

# Categorize commits
while IFS= read -r commit; do
    case "$commit" in
        fix:*|fix(*):*|fixed:*|fixes:*)
            fixed+=("- $commit")
            ;;
        feat:*|feature:*|add:*|adds:*|added:*)
            added+=("- $commit")
            ;;
        remove:*|removes:*|removed:*|delete:*|deletes:*|deleted:*)
            removed+=("- $commit")
            ;;
        refactor:*|refactored:*|update:*|updates:*|updated:*|change:*|changes:*|changed:*)
            changed+=("- $commit")
            ;;
        *)
            # Default to "changed" if no clear pattern
            changed+=("- $commit")
            ;;
    esac
done <<< "$COMMITS"

# Write to changelog file
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
    echo ""
    echo "## [Unreleased]"
    echo ""
    
    if [ ${#added[@]} -gt 0 ]; then echo "### Added"; printf '%s\n' "${added[@]}"; echo ""; fi
    if [ ${#fixed[@]} -gt 0 ]; then echo "### Fixed"; printf '%s\n' "${fixed[@]}"; echo ""; fi
    if [ ${#changed[@]} -gt 0 ]; then echo "### Changed"; printf '%s\n' "${changed[@]}"; echo ""; fi
    if [ ${#removed[@]} -gt 0 ]; then echo "### Removed"; printf '%s\n' "${removed[@]}"; echo ""; fi
} > "$TEMP_FILE"

# Prepend to existing changelog or create new
if [ -f "$CHANGELOG_FILE" ]; then
    cat "$TEMP_FILE" "$CHANGELOG_FILE" > "$CHANGELOG_FILE.tmp" && mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"
else
    cat "$TEMP_FILE" > "$CHANGELOG_FILE"
fi

rm "$TEMP_FILE"

echo "Changelog generated in $CHANGELOG_FILE"