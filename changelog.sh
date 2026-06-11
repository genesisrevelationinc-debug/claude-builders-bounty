#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
TEMP_FILE=$(mktemp)

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes first
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
        echo "Removed"
    elif echo "$lower_msg" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|style|docs|test|chore|perf)'; then
        echo "Changed"
    # Fallback: keyword-based detection
    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
        echo "Added"
    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|resolved|patch)\b'; then
        echo "Fixed"
    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|reverted)\b'; then
        echo "Removed"
    else
        echo "Changed"
    fi
}

# Generate the changelog
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local since_text
    if [ -n "$latest_tag" ]; then
        since_text="since ${latest_tag}"
    else
        since_text="(all commits)"
    fi
    
    # Header
    cat > "$TEMP_FILE" << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] ${since_text}

EOF
    
    # Collect and categorize commits
    local commits
    commits=$(get_commits_since_tag "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo "No new commits found ${since_text}." >> "$TEMP_FILE"
    else
        # Process each commit and group by category
        while IFS= read -r commit; do
            [ -z "$commit" ] && continue
            category=$(categorize_commit "$commit")
            echo "${category}|${commit}" >> "$TEMP_FILE.categorized"
        done <<< "$commits"
        
        # Output each category
        for cat in "Added" "Changed" "Fixed" "Removed"; do
            if grep -q "^${cat}|" "$TEMP_FILE.categorized" 2>/dev/null; then
                echo "### ${cat}" >> "$TEMP_FILE"
                echo "" >> "$TEMP_FILE"
                grep "^${cat}|" "$TEMP_FILE.categorized" | sed 's/^[^|]*|/- /' >> "$TEMP_FILE"
                echo "" >> "$TEMP_FILE"
            fi
        done
    fi
    
    # Move temp file to final location
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    rm -f "$TEMP_FILE.categorized"
    
    echo "✅ CHANGELOG.md generated successfully!"
}

generate_changelog
# Generate Changelog Skill

## Description

Automatically generate a structured `CHANGELOG.md` from a project's git history.

## Usage

Run the changelog generator script:

