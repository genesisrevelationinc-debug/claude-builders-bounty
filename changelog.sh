#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

REPO_URL=""
OUTPUT_FILE="CHANGELOG.md"

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local since_tag="$1"
    if [ -n "$since_tag" ]; then
        git log "${since_tag}..HEAD" --pretty=format:"%H|%s|%b" --reverse
    else
        git log --pretty=format:"%H|%s|%b" --reverse
    fi
}

# Categorize a commit based on its message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    case "$lower_msg" in
        *"add"* | *"feat"* | *"feature"* | *"implement"* | *"introduce"* | *"create"*)
            echo "Added"
            ;;
        *"fix"* | *"bugfix"* | *"patch"* | *"resolve"* | *"hotfix"* | *"correct"*)
            echo "Fixed"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"* | *"clean"*)
            echo "Removed"
            ;;
        *"change"* | *"update"* | *"refactor"* | *"improve"* | *"enhance"* | *"modify"* | *"upgrade"* | *"rework"*)
            echo "Changed"
            ;;
        *)
            echo "Changed"
            ;;
    esac
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local since_ref
    if [ -n "$latest_tag" ]; then
        since_ref="$latest_tag"
    else
        since_ref="the beginning"
    fi
    
    local commits
    commits=$(get_commits "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo "No commits found since $since_ref."
        exit 0
    fi
    
    # Initialize category arrays
    local added=()
    local fixed=()
    local changed=()
    local removed=()
    
    # Process each commit
    while IFS='|' read -r hash subject body; do
        [ -z "$subject" ] && continue
        
        local category
        category=$(categorize_commit "$subject")
        
        case "$category" in
            "Added") added+=("$subject") ;;
            "Fixed") fixed+=("$subject") ;;
            "Changed") changed+=("$subject") ;;
            "Removed") removed+=("$subject") ;;
        esac
    done <<< "$commits"
    
    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] — since $since_ref"
        echo ""
        
        [ ${#added[@]} -gt 0 ] && { echo "### Added"; for item in "${added[@]}"; do echo "- $item"; done; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed"; for item in "${fixed[@]}"; do echo "- $item"; done; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "### Changed"; for item in "${changed[@]}"; do echo "- $item"; done; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "### Removed"; for item in "${removed[@]}"; do echo "- $item"; done; echo ""; }
    } > "$OUTPUT_FILE"
    
    echo "✅ CHANGELOG.md generated successfully with commits since $since_ref."
}

generate_changelog