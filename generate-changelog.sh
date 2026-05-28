#!/usr/bin/env bash
set -euo pipefail

# generate-changelog.sh
# Automatically generates a structured CHANGELOG.md from git history
# Usage: ./generate-changelog.sh [output_file]

OUTPUT_FILE="${1:-CHANGELOG.md}"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Get the last git tag, or use empty tree if no tags exist
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since last tag (or all commits if no tag)
get_commits() {
    local since_ref="$1"
    if [ -z "$since_ref" ]; then
        git log --pretty=format:"%H|%s|%b" --
    else
        git log --pretty=format:"%H|%s|%b" "${since_ref}..HEAD" --
    fi
}

# Categorize a commit based on conventional commit patterns
categorize_commit() {
    local message="$1"
    local lower_msg
    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    
    # Check for conventional commit prefixes
    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
        echo "added"
    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|repair|correct|resolve|patch)'; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|bump)'; then
        echo "changed"
    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|deprecate|clean|cleanup)'; then
        echo "removed"
    else
        # Default categorization based on keywords
        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
            echo "added"
        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|repair|correct|bug)\b'; then
            echo "fixed"
        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|deprecate)\b'; then
            echo "removed"
        else
            echo "changed"
        fi
    fi
}

# Extract issue/PR references from commit message
extract_references() {
    local message="$1"
    # Match #NNN, GH-NNN, or full URLs
    echo "$message" | grep -oE '((#|GH-)[0-9]+|https?://[^ ]+/issues?[/-][0-9]+)' | sort -u | tr '\n' ' ' | sed 's/ $//'
}

generate_changelog() {
    local last_tag
    last_tag=$(get_last_tag)
    
    local version=""
    if [ -n "$last_tag" ]; then
        version="$last_tag"
    else
        version="Unreleased"
    fi
    
    local date_str
    date_str=$(date +%Y-%m-%d)
    
    # Initialize category files
    local added_file="$TEMP_DIR/added.txt"
    local fixed_file="$TEMP_DIR/fixed.txt"
    local changed_file="$TEMP_DIR/changed.txt"
    local removed_file="$TEMP_DIR/removed.txt"
    
    touch "$added_file" "$fixed_file" "$changed_file" "$removed_file"
    
    # Process commits
    local commits
    commits=$(get_commits "$last_tag")
    
    if [ -z "$commits" ]; then
        echo "No commits found since $last_tag" >&2
        return 1
    fi
    
    # Parse commits (format: hash|subject|body)
    echo "$commits" | while IFS='|' read -r hash subject body; do
        [ -z "$subject" ] && continue
        
        local category
        category=$(categorize_commit "$subject")
        
        local refs
        refs=$(extract_references "$subject $body")
        
        local entry="- $subject"
        if [ -n "$refs" ]; then
            entry="$entry ($refs)"
        fi
        
        case "$category" in
            added) echo "$entry" >> "$added_file" ;;
            fixed) echo "$entry" >> "$fixed_file" ;;
            changed) echo "$entry" >> "$changed_file" ;;
            removed) echo "$entry" >> "$removed_file" ;;
        esac
    done
    
    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [$version] - $date_str"
        echo ""
        
        if [ -s "$added_file" ]; then
            echo "### Added"
            sort -u "$added_file"
            echo ""
        fi
        
        if [ -s "$changed_file" ]; then
            echo "### Changed"
            sort -u "$changed_file"
            echo ""
        fi
        
        if [ -s "$fixed_file" ]; then
            echo "### Fixed"
            sort -u "$fixed_file"
            echo ""
        fi
        
        if [ -s "$removed_file" ]; then
            echo "### Removed"
            sort -u "$removed_file"
            echo ""
        fi
        
        echo "---"
        echo ""
        echo "Generated automatically from git history on $date_str"
    } > "$OUTPUT_FILE"
    
    echo "Generated $OUTPUT_FILE with version $version"
}

# Main execution
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository" >&2
    exit 1
fi

generate_changelog