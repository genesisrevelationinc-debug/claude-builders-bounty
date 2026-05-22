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

# Get the date range for the changelog section
get_date_range() {
    local tag="$1"
    local end_date
    end_date=$(date +%Y-%m-%d)
    if [ -n "$tag" ]; then
        local start_date
        start_date=$(git log -1 --format=%ci "$tag" 2>/dev/null | cut -d' ' -f1 || echo "")
        if [ -n "$start_date" ]; then
            echo "$start_date to $end_date"
        else
            echo "up to $end_date"
        fi
    else
        echo "up to $end_date"
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower_msg" in
        *fix*|*bug*|*patch*|*resolve*|*repair*|*correct*|*hotfix*)
            echo "fixed"
            ;;
        *add*|*feat*|*introduce*|*implement*|*create*|*new*)
            echo "added"
            ;;
        *remove*|*delete*|*drop*|*clean*|*deprecate*)
            echo "removed"
            ;;
        *update*|*change*|*modify*|*refactor*|*improve*|*enhance*|*upgrade*|*rework*)
            echo "changed"
            ;;
        *)
            echo "changed"
            ;;
    esac
}

# Main generation logic
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No commits found since the last tag."
        exit 0
    fi

    local date_range
    date_range=$(get_date_range "$latest_tag")

    local version_header
    if [ -n "$latest_tag" ]; then
        version_header="## [Unreleased] — $date_range"
    else
        version_header="## [Unreleased] — $date_range"
    fi

    # Initialize category arrays
    local added=() fixed=() changed=() removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local category
        category=$(categorize_commit "$commit")
        case "$category" in
            added) added+=("$commit") ;;
            fixed) fixed+=("$commit") ;;
            removed) removed+=("$commit") ;;
            changed) changed+=("$commit") ;;
        esac
    done <<< "$commits"

    # Build changelog content
    {
        echo "# Changelog"
        echo ""
        echo "$version_header"
        echo ""

        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
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

        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
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
    } > "$TEMP_FILE"

    # Prepend to existing CHANGELOG or create new one
    if [ -f "$CHANGELOG_FILE" ]; then
        # Extract existing content after the header
        tail -n +3 "$CHANGELOG_FILE" > "${TEMP_FILE}.old" 2>/dev/null || true
        if [ -s "${TEMP_FILE}.old" ]; then
            cat "$TEMP_FILE" > "$CHANGELOG_FILE"
            cat "${TEMP_FILE}.old" >> "$CHANGELOG_FILE"
        else
            cat "$TEMP_FILE" > "$CHANGELOG_FILE"
        fi
        rm -f "${TEMP_FILE}.old"
    else
        cat "$TEMP_FILE" > "$CHANGELOG_FILE"
    fi

    echo "✅ CHANGELOG.md generated successfully!"
    echo ""
    echo "Categories:"
    echo "  - Added:   ${#added[@]}"
    echo "  - Changed: ${#changed[@]}"
    echo "  - Fixed:   ${#fixed[@]}"
    echo "  - Removed: ${#removed[@]}"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi
    generate_changelog
fi