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
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Get the date range for the changelog entry
get_date_range() {
    local tag="$1"
    local start_date
    local end_date
    
    end_date=$(git log -1 --pretty=format:"%ad" --date=short 2>/dev/null || date +%Y-%m-%d)
    
    if [ -n "$tag" ]; then
        start_date=$(git log -1 "$tag" --pretty=format:"%ad" --date=short 2>/dev/null || echo "")
    fi
    
    if [ -n "$start_date" ]; then
        echo "$start_date to $end_date"
    else
        echo "$end_date"
    fi
}

# Categorize a single commit
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
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|deprecate)(\(.+\))?: ]]; then
        echo "removed"
    # Fallback to keyword matching
    elif echo "$lower_msg" | grep -qiE "\b(add|create|implement|introduce|new)\b"; then
        echo "added"
    elif echo "$lower_msg" | grep -qiE "\b(fix|resolve|patch|bug|hotfix|correct)\b"; then
        echo "fixed"
    elif echo "$lower_msg" | grep -qiE "\b(remove|delete|drop|deprecate|revert)\b"; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Main generation
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)
    
    local commits
    commits=$(get_commits_since_tag "$latest_tag")
    
    if [ -z "$commits" ]; then
        echo "No commits found since last tag."
        exit 0
    fi
    
    local version_header
    if [ -n "$latest_tag" ]; then
        version_header="## Unreleased (since $latest_tag)"
    else
        version_header="## Unreleased"
    fi
    
    local date_range
    date_range=$(get_date_range "$latest_tag")
    
    {
        echo "# Changelog"
        echo ""
        echo "$version_header — $date_range"
        echo ""
        
        # Process and categorize commits
        echo "$commits" | while IFS= read -r commit; do
            [ -z "$commit" ] && continue
            category=$(categorize_commit "$commit")
            echo "$category: $commit"
        done | awk '
            BEGIN { FS=": " }
            {
                cat = $1
                msg = substr($0, index($0, ": ") + 2)
                if (cat == "added") added[++a] = msg
                else if (cat == "fixed") fixed[++f] = msg
                else if (cat == "changed") changed[++c] = msg
                else if (cat == "removed") removed[++r] = msg
            }
            END {
                if (a > 0) {
                    print "\n### Added"
                    for (i=1; i<=a; i++) print "- " added[i]
                }
                if (f > 0) {
                    print "\n### Fixed"
                    for (i=1; i<=f; i++) print "- " fixed[i]
                }
                if (c > 0) {
                    print "\n### Changed"
                    for (i=1; i<=c; i++) print "- " changed[i]
                }
                if (r > 0) {
                    print "\n### Removed"
                    for (i=1; i<=r; i++) print "- " removed[i]
                }
            }
        '
        
        # Append existing changelog if it exists
        if [ -f "$CHANGELOG_FILE" ]; then
            echo ""
            # Skip the header of existing changelog
            tail -n +3 "$CHANGELOG_FILE" 2>/dev/null || true
        fi
    } > "$TEMP_FILE"
    
    mv "$TEMP_FILE" "$CHANGELOG_FILE"
    echo "✅ CHANGELOG.md generated successfully!"
}

# Run
generate_changelog
# Generate Changelog Skill

Generate a structured `CHANGELOG.md` from a project's git history.

## Setup

1. Save `changelog.sh` to your project root
2. Make it executable: `chmod +x changelog.sh`
3. Run: `./changelog.sh`

## Usage

