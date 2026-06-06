#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

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
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not a git repository. Please run this script from a git repository."
    exit 1
fi

# Get the latest tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag..HEAD" --pretty=format:"%s" --no-merges
    else
        log_warn "No tags found. Using all commits."
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message
categorize_commit() {
    local message="$1"
    local lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
        return
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
        return
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
        echo "changed"
        return
    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
        echo "removed"
        return
    fi
    
    # Fallback to keyword matching
    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|feat) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|repair|resolve|patch|hotfix) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|revert) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Clean commit message for changelog (remove conventional commit prefix)
clean_message() {
    local message="$1"
    # Remove conventional commit prefix like "feat:", "fix(scope):", etc.
    echo "$message" | sed -E 's/^[a-z]+(\([^)]+\))?:[[:space:]]*//'
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    log_info "Latest tag: ${latest_tag:-none}"
    
    local commits
    commits=$(get_commits_since_tag "$latest_tag")
    
    if [ -z "$commits" ]; then
        log_warn "No commits found since last tag."
        exit 0
    fi
    
    # Initialize category arrays
    declare -a added=() fixed=() changed=() removed=()
    
    # Process each commit
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        local clean_msg
        clean_msg=$(clean_message "$commit")
        
        case "$category" in
            added)   added+=("$clean_msg") ;;
            fixed)   fixed+=("$clean_msg") ;;
            removed) removed+=("$clean_msg") ;;
            changed) changed+=("$clean_msg") ;;
        esac
    done <<< "$commits"
    
    # Generate output
    local version="## [Unreleased]"
    if [ -n "$latest_tag" ]; then
        version="## [Unreleased] (since $latest_tag)"
    fi
    
    local date_str
    date_str=$(date +"$DATE_FORMAT")
    
    # Build changelog content
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "$version - $date_str"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
    } > "$OUTPUT_FILE"
    
    log_info "CHANGELOG generated successfully at $OUTPUT_FILE"
}

# Main execution
generate_changelog