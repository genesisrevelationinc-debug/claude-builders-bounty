#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE=""
else
    COMMIT_RANGE="${LAST_TAG}..HEAD"
    echo "Generating changelog for commits since: $LAST_TAG"
fi

# Get commits: hash|date|author|message (first line)
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%h|%ad|%an|%s" --date=short)
else
    COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%h|%ad|%an|%s" --date=short)
fi

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

while IFS='|' read -r hash date author message; do
    # Skip merge commits
    [[ "$message" == Merge* ]] && continue
    
    # Categorize based on conventional commit patterns and keywords
    if [[ "$message" =~ ^[Ff]eat(\(.*\))?: ]] || \
       [[ "$message" =~ [Aa]dd ]] || \
       [[ "$message" =~ [Ii]ntroduce ]] || \
       [[ "$message" =~ [Ss]upport ]] || \
       [[ "$message" =~ [Ii]mplement ]]; then
        ADDED="${ADDED}- ${message} (${hash})"$'\n'
    elif [[ "$message" =~ ^[Ff]ix(\(.*\))?: ]] || \
         [[ "$message" =~ [Bb]ug ]] || \
         [[ "$message" =~ [Rr]esolve ]] || \
         [[ "$message" =~ [Cc]orrect ]] || \
         [[ "$message" =~ [Pp]atch ]]; then
        FIXED="${FIXED}- ${message} (${hash})"$'\n'
    elif [[ "$message" =~ ^[Rr]emove(\(.*\))?: ]] || \
         [[ "$message" =~ [Rr]emove ]] || \
         [[ "$message" =~ [Dd]elete ]] || \
         [[ "$message" =~ [Dd]rop ]] || \
         [[ "$message" =~ [Uu]ninstall ]]; then
        REMOVED="${REMOVED}- ${message} (${hash})"$'\n'
    elif [[ "$message" =~ ^[Rr]efactor(\(.*\))?: ]] || \
         [[ "$message" =~ ^[Uu]pdate(\(.*\))?: ]] || \
         [[ "$message" =~ [Uu]pdate ]] || \
         [[ "$message" =~ [Cc]hange ]] || \
         [[ "$message" =~ [Mm]odify ]] || \
         [[ "$message" =~ [Rr]ework ]] || \
         [[ "$message" =~ [Ee]nhance ]]; then
        CHANGED="${CHANGED}- ${message} (${hash})"$'\n'
    else
        OTHER="${OTHER}- ${message} (${hash})"$'\n'
    fi
done <<< "$COMMITS"

# Build CHANGELOG
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    
    VERSION_DATE=$(date +%Y-%m-%d)
    if [ -n "$LAST_TAG" ]; then
        echo "## [Unreleased] - ${VERSION_DATE}"
    else
        echo "## [Unreleased] - ${VERSION_DATE}"
    fi
    echo ""
    
    if [ -n "$ADDED" ]; then
        echo "### Added"
        echo -e "$ADDED"
    fi
    
    if [ -n "$CHANGED" ]; then
        echo "### Changed"
        echo -e "$CHANGED"
    fi
    
    if [ -n "$FIXED" ]; then
        echo "### Fixed"
        echo -e "$FIXED"
    fi
    
    if [ -n "$REMOVED" ]; then
        echo "### Removed"
        echo -e "$REMOVED"
    fi
    
    if [ -n "$OTHER" ]; then
        echo "### Other"
        echo -e "$OTHER"
    fi
} > CHANGELOG.md

echo "CHANGELOG.md generated successfully!"