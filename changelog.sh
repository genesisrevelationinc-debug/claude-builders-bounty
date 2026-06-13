#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the latest git tag, or empty if none exists
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a commit message into a section
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes
    if echo "$lower" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "Added"
    elif echo "$lower" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
        echo "Fixed"
    elif echo "$lower" | grep -qE '^(remove|delete|drop|deprecate|revert)'; then
        echo "Removed"
    elif echo "$lower" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|optimize)'; then
        echo "Changed"
    else
        # Fallback: keyword matching in message body
        if echo "$lower" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
            echo "Added"
        elif echo "$lower" | grep -qE '\b(fix|fixed|fixing|bug|resolve|patch|correct)\b'; then
            echo "Fixed"
        elif echo "$lower" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|deprecate)\b'; then
            echo "Removed"
        elif echo "$lower" | grep -qE '\b(change|changed|changing|update|updated|updating|modify|modified|refactor|improve|improved|enhance|enhanced|upgrade|upgraded|optimize|optimized)\b'; then
            echo "Changed"
        else
            echo "Changed"  # Default category
        fi
    fi
}

# Generate the changelog
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
        echo ""
        
        if [ -n "$tag" ]; then
            echo "## [Unreleased] — since $tag"
        else
            echo "## [Unreleased]"
        fi
        echo ""
        
        # Collect commits by category
        local added=""
        local fixed=""
        local changed=""
        local removed=""
        
        while IFS= read -r commit; do
            [ -z "$commit" ] && continue
            
            local category
            category=$(categorize_commit "$commit")
            local formatted="- $commit"
            
            case "$category" in
                Added)   added="$added$formatted"$'\n' ;;
                Fixed)   fixed="$fixed$formatted"$'\n' ;;
                Changed) changed="$changed$formatted"$'\n' ;;
                Removed) removed="$removed$formatted"$'\n' ;;
            esac
        done < <(get_commits)
        
        # Output sections in order
        [ -n "$added" ]   && { echo "### Added"; echo -e "$added"; echo ""; }
        [ -Echo "$fixed" ]   && { echo "### Fixed"; echo -e "$fixed"; echo ""; }
        [ -n "$changed" ] && { echo "### Changed"; echo -e "$changed"; echo ""; }
        [ -n "$removed" ] && { echo "### Removed"; echo -e "$removed"; echo ""; }
        
    } > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "✅ Generated $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not a git repository" >&2
    exit 1
fi

generate_changelog
# Generate Changelog Skill

## Description

Automatically generate a structured `CHANGELOG.md` from a project's git history.

## Usage

Run the following command in your project:

