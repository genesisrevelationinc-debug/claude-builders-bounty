#!/usr/bin/env bash
set -euo pipefail

# changelog.sh - Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given tag (or all commits if no tag)
get_commits_since() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Get the date of the latest tag or use current date
get_version_date() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log -1 --format=%cd --date=short "$tag" 2>/dev/null || date +%Y-%m-%d
    else
        date +%Y-%m-%d
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
    
    # Fallback: keyword-based categorization
    if [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|support|enable) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|resolve|patch|correct|repair) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|clean) ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    local version_name
    version_name=${latest_tag:-"0.0.0"}
    local version_date
    version_date=$(get_version_date "$latest_tag")
    
    local commits
    commits=$(get_commits_since "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi
    
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added) added+=("$commit") ;;
            fixed) fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done <<< "$commits"
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## [${version_name}] - ${version_date}"
        echo ""
        
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf -- "- %s\n" "${added[@]}"
            echo ""
        fi
        
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf -- "- %s\n" "${fixed[@]}"
            echo ""
        fi
        
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf -- "- %s\n" "${changed[@]}"
            echo ""
        fi
        
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf -- "- %s\n" "${removed[@]}"
            echo ""
        fi
    } > "$CHANGELOG_FILE"
    
    echo "CHANGELOG.md generated successfully at ${CHANGELOG_FILE}"
}

# Main execution
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository."
    exit 1
fi

generate_changelog