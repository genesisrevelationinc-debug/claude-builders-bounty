#!/usr/bin/env bash
#
# changelog.sh - Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# This script fetches commits since the last git tag and auto-categorizes
# them into: Added / Fixed / Changed / Removed
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_FILE="CHANGELOG.md"
DATE_FORMAT="%Y-%m-%d"

# Function to print colored messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run this script from a git repository."
fi

# Get the latest tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits() {
    local tag="$1"
    
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message into one of the sections
categorize_commit() {
    local message="$1"
    local lower_msg
    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\([a-z]+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\([a-z]+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\([a-z]+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\([a-z]+\))?: ]]; then
        echo "removed"
    # Fallback to keyword matching
    elif [[ "$lower_msg" =~ ^(add|create|implement|introduce|new) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|resolve|patch|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|clean) ]]; then
        echo "removed"
    else
        # Default to changed for anything else
        echo "changed"
    fi
}

# Clean commit message (remove conventional commit prefix)
clean_message() {
    local message="$1"
    # Remove conventional commit prefix like "feat:", "fix(scope):", etc.
    echo "$message" | sed -E 's/^[a-z]+(\([a-z]+\))?:\s*//'
}

# Main script
main() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    if [ -n "$latest_tag" ]; then
        info "Found latest tag: $latest_tag"
    else
        warn "No tags found. Using all commits."
    fi
    
    local commits
    commits=$(get_commits "$latest_tag")
    
    if [ -z "$commits" ]; then
        warn "No commits found since the last tag."
        exit 0
    fi
    
    info "Processing commits..."
    
    # Initialize category arrays
    declare -A categories
    categories[added]=""
    categories[fixed]=""
    categories[changed]=""
    categories[removed]=""
    
    # Process each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        local clean_msg
        clean_msg=$(clean_message "$commit")
        
        categories[$category]="${categories[$category]}- $clean_msg"$'\n'
    done <<< "$commits"
    
    # Generate CHANGELOG.md
    local version
    if [ -n "$latest_tag" ]; then
        version="$latest_tag"
    else
        version="Unreleased"
    fi
    
    local current_date
    current_date=$(date +"$DATE_FORMAT")
    
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [$version] - $current_date"
        echo ""
        
        if [ -n "${categories[added]}" ]; then
            echo "### Added"
            echo ""
            echo -n "${categories[added]}"
            echo ""
        fi
        
        if [ -n "${categories[fixed]}" ]; then
            echo "### Fixed"
            echo ""
            echo -n "${categories[fixed]}"
            echo ""
        fi
        
        if [ -n "${categories[changed]}" ]; then
            echo "### Changed"
            echo ""
            echo -n "${categories[changed]}"
            echo ""
        fi
        
        if [ -n "${categories[removed]}" ]; then
            echo "### Removed"
            echo ""
            echo -n "${categories[removed]}"
            echo ""
        fi
    } > "$OUTPUT_FILE"
    
    info "CHANGELOG.md generated successfully!"
    info "Output: $OUTPUT_FILE"
}

main "$@"