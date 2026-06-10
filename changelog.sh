#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them, and writes
# a properly formatted CHANGELOG.md.
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}📋 Generating CHANGELOG...${NC}"

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository.${NC}"
    exit 1
fi

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LATEST_TAG" ]; then
    echo -e "${YELLOW}Warning: No tags found. Using all commits.${NC}"
    COMMIT_RANGE=""
    VERSION="Unreleased"
    DATE=$(date +%Y-%m-%d)
else
    echo -e "${GREEN}Latest tag: $LATEST_TAG${NC}"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    VERSION="$LATEST_TAG → HEAD"
    DATE=$(date +%Y-%m-%d)
fi

# Get commits since last tag (or all commits)
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%s" --no-merges 2>/dev/null || true)
else
    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" --no-merges 2>/dev/null || true)
fi

if [ -z "$COMMITS" ]; then
    echo -e "${YELLOW}No commits found since last tag.${NC}"
    exit 0
fi

# Initialize category arrays
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

# Categorize commits
while IFS= read -r line; do
    [ -z "$line" ] && continue

    # Normalize for matching
    LOWER=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    if [[ "$LOWER" =~ ^(feat|add|added|feature|new|introduce|implement|create) ]] || \
       [[ "$LOWER" =~ (add|added|adds|adding)[[:space:]] ]] || \
       [[ "$LOWER" =~ (support|enable|allow)[[:space:]] ]]; then
        ADDED+=("$line")
    elif [[ "$LOWER" =~ ^(fix|fixed|bugfix|patch|resolve|hotfix|correct) ]] || \
         [[ "$LOWER" =~ (fix|fixes|fixed|fixing)[[:space:]] ]] || \
         [[ "$LOWER" =~ (bug|issue|crash|error|broken)[[:space:]] ]]; then
        FIXED+=("$line")
    elif [[ "$LOWER" =~ ^(remove|removed|delete|deleted|drop|dropped|cleanup|clean) ]] || \
         [[ "$LOWER" =~ (remove|removes|removed|removing|delete|deletes|deleted|deleting)[[:space:]] ]]; then
        REMOVED+=("$line")
    elif [[ "$LOWER" =~ ^(change|changed|update|updated|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|optimize|optimized|rework|upgrade|downgrade) ]] || \
         [[ "$LOWER" =~ (update|updates|updated|updating|change|changes|changed|changing|refactor|refactors|refactored|refactoring|improve|improves|improved|improving)[[:space:]] ]]; then
        CHANGED+=("$line")
    else
        OTHER+=("$line")
    fi
done <<< "$COMMITS"

# Generate CHANGELOG.md
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo "## [Unreleased] - $DATE"
    echo ""

    # Added
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        printf -- "- %s\n" "${ADDED[@]}"
        echo ""
    fi

    # Changed
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "### Changed"
        printf -- "- %s\n" "${CHANGED[@]}"
        echo ""
    fi
"...]
    fi

    # Removed
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        printf -- "- %s\n" "${REMOVED[@]}"
        echo ""
    fi

    # Other (uncategorized)
    if [ ${#OTHER[@]} -gt 0 ]; then
        echo "### Other"
        printf -- "- %s\n" "${OTHER[@]}"
        echo ""
    fi

    # Append existing changelog if it exists
    if [ -f CHANGELOG.md ]; then
        # Skip the header of the existing changelog
        tail -n +3 CHANGELOG.md | sed '/^# Changelog/d' | sed '/^All notable changes/d' | sed '/^$/d' || true
    fi
} > CHANGELOG.md.new

mv CHANGELOG.md.new CHANGELOG.md

echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo "  Added:   ${#ADDED[@]}"
echo "  Fixed:   ${#FIXED[@]}"
echo "  Changed: ${#CHANGED[@]}"
echo "  Removed: ${#REMOVED[@]}"
echo "  Other:   ${#OTHER[@]}"