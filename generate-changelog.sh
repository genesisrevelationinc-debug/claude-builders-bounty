#!/usr/bin/env bash
set -euo pipefail

# generate-changelog.sh
# Generates a structured CHANGELOG.md from git history since the last tag.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since a given tag (or all commits if no tag)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a commit message into one of: Added, Fixed, Changed, Removed
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "Added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "Fixed"
    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
        echo "Changed"
    elif [[ "$lower_msg" =~ ^remove(\(.+\))?: ]] || [[ "$lower_msg" =~ ^delete(\(.+\))?: ]] || [[ "$lower_msg" =~ ^drop(\(.+\))?: ]]; then
        echo "Removed"
    else
        # Fallback: keyword-based categorization
        if [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|feature) ]]; then
            echo "Added"
        elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|resolve|patch|correct) ]]; then
            echo "Fixed"
        elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|clean) ]]; then
            echo "Removed"
        else
            echo "Changed"
        fi
    fi
}

# Generate the CHANGELOG.md content
generate_changelog() {
    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No commits found since the last tag."
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
            Added)   added+=("$commit") ;;
            Fixed)   fixed+=("$commit") ;;
            Changed) changed+=("$commit") ;;
            Removed) removed+=("$commit") ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        echo "## $(date +%Y-%m-%d)"
        echo ""

        print_section() {
            local title="$1"
            shift
            local items=("$@")
            if [ ${#items[@]} -gt 0 ]; then
                echo "### $title"
                echo ""
                for item in "${items[@]}"; do
                    echo "- $item"
                done
                echo ""
            fi
        }

        print_section "Added"   "${added[@]}"
        print_section "Fixed"   "${fixed[@]}"
        print_section "Changed" "${changed[@]}"
        print_section "Removed" "${removed[@]}"
    } > "$CHANGELOG_FILE"

    echo "CHANGELOG.md generated at $CHANGELOG_FILE"
}

# Main
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a git repository." >&2
    exit 1
fi

generate_changelog
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Description

This skill fetches commits since the last git tag, auto-categorizes them into
`Added`, `Fixed`, `Changed`, and `Removed`, and outputs a properly formatted
`CHANGELOG.md`.

## Usage

Run the script from the repository root:

