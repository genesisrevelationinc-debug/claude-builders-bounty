#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"

# Get the latest git tag, or empty if none
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Get the date of the latest commit
get_date() {
    git log -1 --pretty=format:"%ad" --date=short 2>/dev/null || date +%Y-%m-%d
}

# Get the latest tag for version header
get_version() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        echo "$tag"
    else
        echo "Unreleased"
    fi
}

# Categorize a commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    case "$lower" in
        *"fix"* | *"bugfix"* | *"hotfix"* | *"patch"*)
            echo "fixed"
            ;;
        *"add"* | *"feat"* | *"feature"* | *"implement"* | *"introduce"*)
            echo "added"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"*)
            echo "removed"
            ;;
        *"update"* | *"change"* | *"refactor"* | *"improve"* | *"optimize"* | *"rework"*)
            echo "changed"
            ;;
        *)
            # Default based on conventional commit prefix
            if echo "$lower" | grep -qE "^(feat|feature)"; then
                echo "added"
            elif echo "$lower" | grep -qE "^(fix|bugfix|hotfix)"; then
                echo "fixed"
            elif echo "$lower" | grep -qE "^(remove|drop|delete)"; then
                echo "removed"
            elif echo "$lower" | grep -qE "^(chore|docs|style|test|build|ci|perf|refactor)"; then
                echo "changed"
            else
                echo "changed"
            fi
            ;;
    esac
}

# Generate the changelog
generate_changelog() {
    local version date added fixed changed removed
    version=$(get_version)
    date=$(get_date)
    
    added=""
    fixed=""
    changed=""
    removed=""
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        
        local category
        category=$(categorize "$commit")
        
        case "$category" in
            added)   added="${added}- ${commit}"$'\n' ;;
            fixed)   fixed="${fixed}- ${commit}"$'\n' ;;
            changed) changed="${changed}- ${commit}"$'\n' ;;
            removed) removed="${removed}- ${commit}"$'\n' ;;
        esac
    done < <(get_commits)
    
    # Build changelog content
    local output=""
    output="## [${version}] - ${date}"$'\n\n'
    
    if [ -n "$added" ]; then
        output="${output}### Added"$'\n\n'"${added}"$'\n'
    fi
    
    if [ -n "$changed" ]; then
        output="${output}### Changed"$'\n\n'"${changed}"$'\n'
    fi
    
    if [ -n "$fixed" ]; then
        output="${output}### Fixed"$'\n\n'"${fixed}"$'\n'
    fi
    
    if [ -n "$removed" ]; then
        output="${output}### Removed"$'\n\n'"${removed}"$'\n'
    fi
    
    # Write to file
    {
        echo "# Changelog"$'\n\n'
        echo "All notable changes to this project will be documented in this file."$'\n\n'
        echo "$output"
    } > "$CHANGELOG_FILE"
    
    echo "✅ Generated $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
# Generate Changelog Skill

## Description

Automatically generate a structured `CHANGELOG.md` from a project's git history.

## Usage

Run the following command in your terminal:

