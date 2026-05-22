#!/usr/bin/env bash

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

set -euo pipefail

# Get the last git tag
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits() {
    local last_tag
    last_tag=$(get_last_tag)
    
    if [ -z "$last_tag" ]; then
        git log --pretty=format:"%s" --no-merges
    else
        git log "${last_tag}..HEAD" --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test|build|ci|revert)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^remove(\(.+\))?: ]]; then
        echo "removed"
    else
        # Fallback: keyword-based categorization
        if [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|support|enable) ]]; then
            echo "added"
        elif [[ "$lower_msg" =~ ^(fix|bug|repair|correct|resolve|patch) ]]; then
            echo "fixed"
        elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate) ]]; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    local version
    version=${last_tag:-"0.0.0"}
    local date_str
    date_str=$(date +%Y-%m-%d)
    
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Read and categorize commits
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize_commit "$commit")
        
        case "$category" in
            added)   added+=("- $commit") ;;
            fixed)   fixed+=("- $commit") ;;
            removed) removed+=("- $commit") ;;
            changed) changed+=("- $commit") ;;
        esac
    done < <(get_commits)
    
    # Output CHANGELOG
    echo "# Changelog"
    echo ""
    echo "## [${version}] - ${date_str}"
    echo ""
    
    if [ ${#added[@]} -gt 0 ]; then
        echo "### Added"
        printf "%s\n" "${added[@]}"
        echo ""
    fi
    
    if [ ${#fixed[@]} -gt 0 ]; then
        echo "### Fixed"
        printf "%s\n" "${fixed[@]}"
        echo ""
    fi
    
    if [ ${#changed[@]} -gt 0 ]; then
        echo "### Changed"
        printf "%s\n" "${changed[@]}"
        echo ""
    fi
    
    if [ ${#removed[@]} -gt 0 ]; then
        echo "### Removed"
        printf "%s\n" "${removed[@]}"
        echo ""
    fi
}

# Main execution
main() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        exit 1
    fi
    
    generate_changelog > CHANGELOG.md
    echo "CHANGELOG.md generated successfully!"
}

main "$@"
# Generate Changelog Skill

A Claude Code skill to automatically generate a structured `CHANGELOG.md` from a project's git history.

## Command

