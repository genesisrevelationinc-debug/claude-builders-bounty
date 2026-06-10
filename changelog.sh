#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Get the date of the latest tag or use today
get_version_date() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1 || date +%Y-%m-%d
    else
        date +%Y-%m-%d
    fi
}

# Categorize a commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|update)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
        echo "removed"
    else
        # Fallback: keyword-based categorization
        if [[ "$lower_msg" =~ ^(add|new|introduce|implement|create) ]]; then
            echo "added"
        elif [[ "$lower_msg" =~ ^(fix|bug|resolve|patch|correct) ]]; then
            echo "fixed"
        elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate) ]]; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Format a commit message (remove conventional commit prefix, capitalize)
format_commit_message() {
    local msg="$1"
    # Remove conventional commit prefix like "feat:", "fix(scope):"
    local formatted
    formatted=$(echo "$msg" | sed -E 's/^[a-zA-Z]+(\([^)]+\))?:\s*//')
    # Capitalize first letter
    echo "${formatted^}"
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)
    local version_date
    version_date=$(get_version_date "$latest_tag")
    local version_name
    if [ -n "$latest_tag" ]; then
        version_name="Unreleased (since $latest_tag)"
    else
        version_name="Unreleased"
    fi

    # Collect commits by category
    local added="" fixed="" changed="" removed=""
    
    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        local formatted
        formatted=$(format_commit_message "$commit")
        case "$category" in
            added)   added+="- $formatted\n" ;;
            fixed)   fixed+="- $formatted\n" ;;
            changed) changed+="- $formatted\n" ;;
            removed) removed+="- $formatted\n" ;;
Cocktails
        esac
    done < <(get_commits "$latest_tag")

    # Build CHANGELOG
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [$version_name] - $version_date"
        echo ""
        
        if [ -n "$added" ]; then
            echo "### Added"
            echo -e "$added"
            echo ""
        fi
        if [ -n "$fixed" ]; then
            echo "### Fixed"
            echo -e "$fixed"
            echo ""
        fi
+        if [ -n "$changed" ]; then
            echo "### Changed"
            echo -e "$changed"
            echo ""
        fi
        if [ -n "$removed" ]; then
            echo "### Removed"
            echo -e "$removed"
            echo ""
        fi
    } > "$TEMP_FILE"

    # If existing CHANGELOG exists, preserve older versions
    if [ -f "$CHANGELOG_FILE" ]; then
        # Extract existing content after the header (keep old versions)
        tail -n +5 "$CHANGELOG_FILE" >> "$TEMP_FILE" 2>/dev/null || true
    fi

    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "✅ CHANGELOG.md generated successfully!"
}

main "$@"

--- /dev/null
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag and auto-categorizes them into:
- **Added** — new features, implementations
- **Fixed** — bug fixes, patches
- **Changed** — refactors, updates, chores
- **Removed** — deletions, deprecations

### Usage

Run in Claude Code:
