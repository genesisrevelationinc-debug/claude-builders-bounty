#!/usr/bin/env bash
set -euo pipefail

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"

# Get the last git tag, or use empty string if no tags exist
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get commits since last tag (or all commits if no tag)
if [ -n "$LAST_TAG" ]; then
    COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s" 2>/dev/null || echo "")
else
    COMMITS=$(git log --pretty=format:"%s" 2>/dev/null || echo "")
fi

# If no commits found, exit with message
if [ -z "$COMMITS" ]; then
    echo "No commits found since last tag."
    exit 0
fi

# Initialize category arrays
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

# Categorize commits based on conventional commit prefixes and keywords
while IFS= read -r commit; do
    [ -z "$commit" ] && continue
    
    # Normalize for matching
    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_commit" =~ ^feat(\(.*\))?: ]]; then
        ADDED+=("$commit")
    elif [[ "$lower_commit" =~ ^fix(\(.*\))?: ]]; then
        FIXED+=("$commit")
    elif [[ "$lower_commit" =~ ^(chore|refactor|perf|style|docs|test|build|ci)(\()? ]]; then
        CHANGED+=("$commit")
    elif [[ "$lower_commit" =~ ^remove(d)?(\(.*\))?: ]] || [[ "$lower_commit" =~ ^delete ]]; then
        REMOVED+=("$commit")
    # Fallback to keyword matching
    elif [[ "$lower_commit" =~ (fix|bug|patch|repair|resolve|close) ]]; then
        FIXED+=("$commit")
    elif [[ "$lower_commit" =~ (add|new|create|introduce|implement|feature) ]]; then
        ADDED+=("$commit")
    elif [[ "$lower_commit" =~ (remove|delete|drop|eliminate|deprecate) ]]; then
        REMOVED+=("$commit")
    elif [[ "$lower_commit" =~ (update|change|modify|refactor|improve|enhance|upgrade) ]]; then
        CHANGED+=("$commit")
    else
        OTHER+=("$commit")
    fi
done <<< "$COMMITS"

# Add other commits to changed as a fallback
if [ ${#OTHER[@]} -gt 0 ]; then
    for commit in "${OTHER[@]}"; do
        CHANGED+=("$commit")
    done
fi

# Generate the CHANGELOG.md content
{
    echo "# Changelog"
    echo ""
    
    # Determine version/date header
    if [ -n "$LAST_TAG" ]; then
        echo "## [Unreleased] - since $LAST_TAG"
    else
        echo "## [Unreleased]"
    fi
    echo ""
    echo "*Generated on $(date +%Y-%m-%d)*"
    echo ""
    
    # Added
    if [ ${#ADDED[@]} -gt 0 ]; then
        echo "### Added"
        for commit in "${ADDED[@]}"; do
            echo "- $commit"
        done
        echo ""
    fi
    
    # Fixed
    if [ ${#FIXED[@]} -gt 0 ]; then
        echo "### Fixed"
        for commit in "${FIXED[@]}"; do
            echo "- $commit"
        done
        echo ""
    fi
    
    # Changed
    if [ ${#CHANGED[@]} -gt 0 ]; then
        echo "### Changed"
        for commit in "${CHANGED[@]}"; do
            echo "- $commit"
        done
        echo ""
    fi
    
    # Removed
    if [ ${#REMOVED[@]} -gt 0 ]; then
        echo "### Removed"
        for commit in "${REMOVED[@]}"; do
            echo "- $commit"
        done
        echo ""
    fi
} > "$CHANGELOG_FILE"

echo "✅ CHANGELOG.md generated at $CHANGELOG_FILE"