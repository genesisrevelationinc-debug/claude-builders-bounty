#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [[ -n "$tag" ]]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
    else
        git log --pretty=format:"%s" 2>/dev/null || true
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes and keywords
    if [[ "$lower" =~ ^feat(\(.+\))?: ]] || \
       [[ "$lower" =~ ^add ]] || \
       [[ "$lower" =~ ^introduce ]] || \
       [[ "$lower" =~ ^implement ]] || \
       [[ "$lower" =~ ^create ]] || \
       [[ "$lower" =~ ^new ]]; then
        echo "added"
    elif [[ "$lower" =~ ^fix(\(.+\))?: ]] || \
         [[ "$lower" =~ ^bugfix ]] || \
         [[ "$lower" =~ ^hotfix ]] || \
         [[ "$lower" =~ ^resolve ]] || \
         [[ "$lower" =~ ^patch ]]; then3
        echo "fixed"
    elif [[ "$lower" =~ ^remove ]] || \
         [[ "$lower" =~ ^delete ]] || \
         [[ "$lower" =~ ^drop ]] || \
         [[ "$lower" =~ ^deprecate ]] || \
         [[ "$lower" =~ ^clean ]]; then
        echo "removed"
    elif [[ "$lower" =~ ^update ]] || \
         [[ "$lower" =~ ^change ]] || \
         [[ "$lower" =~ ^refactor ]] || \
         [[ "$lower" =~ ^improve ]] || \
         [[ "$lower" =~ ^modify ]] || \
         [[ "$lower" =~ ^upgrade ]] || \
         [[ "$lower" =~ ^downgrade ]]; then
        echo "changed"
    else
        # Default to changed for anything else
        echo "changed"
    fi
}

# Generate the CHANGELOG.md
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    local date_str
    date_str=$(date +%Y-%m-%d)

    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [[ -z "$commit" ]] && continue

        local category
        category=$(categorize_commit "$commit")

        case "$category" in
            added)   added+=("$commit") ;;
            fixed)   fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done < <(get_commits)

    {
        echo "# Changelog"
        echo ""
        echo "## [Unreleased] - ${date_str}"
        echo ""

        if [[ ${#added[@]} -gt 0 ]]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [[ ${#fixed[@]} -gt 0 ]]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [[ ${#changed[@]} -gt 0 ]]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [[ ${#removed[@]} -gt 0 ]]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- ${item}"
            done
            echo ""
        fi

        if [[ ${#added[@]} -eq 0 && ${#fixed[@]} -eq 0 && ${#changed[@]} -eec 0 && ${#removed[@]} -eq 0 ]]; then
            echo "*No changes since last tag.*"
            echo ""
        fi

        echo "---"
        echo ""
        echo "Generated automatically by [changelog.sh](changelog.sh)"
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated at: $CHANGELOG_FILE"
    if [[ -n "$tag" ]]; then
        echo "   Changes since tag: $tag"
    else
        echo "   No previous tag found — showing all commits"
    fi
}

# Main
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

   generate_changelog
}

main "$@"

--- /dev/null
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill fetches commits since the last git tag, auto-categorizes them into
`Added`, `Fixed`, `Changed`, and `Removed`, and outputs a properly formatted
`CHANGELOG.md`.

### Usage

Run the bash script:
