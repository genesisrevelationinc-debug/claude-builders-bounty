#!/usr/bin/env bash
set -euo pipefail

# generate-changelog.sh
# Automatically generates a structured CHANGELOG.md from git history.
# Fetches commits since the last git tag and auto-categorizes them.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"

# Get the latest git tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || echo ""
    else
        git log --pretty=format:"%s" 2>/dev/null || echo ""
    fi
}

# Categorize a single commit message
categorize_commit() {
    local msg="$1"
    local lower_msg
    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    if [[ "$lower_msg" =~ ^(feat|add|create|implement|introduce) ]] || \
       [[ "$lower_msg" =~ ^.*(add|adds|added|adding)\ .* ]] || \
       [[ "$lower_msg" =~ ^.*(create|creates|created|creating)\ .* ]] || \
       [[ "$lower_msg" =~ ^.*(implement|implements|implemented|implementing)\ .* ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch) ]] || \
         [[ "$lower_msg" =~ ^.*(fix|fixes|fixed|fixing)\ .* ]] || \
         [[ "$lower_msg" =~ ^.*(resolve|resolves|resolved|resolving)\ .* ]] || \
         [[ "$lower_msg" =~ ^.*(correct|corrects|corrected|correcting)\ .* ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert) ]] || \
         [[ "$lower_msg" =~ ^.*(remove|removes|removed|removing)\ .* ]] || \
         [[ "$lower_msg" =~ ^.*(delete|deletes|deleted|deleting)\ .* ]] || \
         [[ "$lower_msg" =~ ^.*(drop|drops|dropped|dropping)\ .* ]]; then
        echo "removed"
    else
        echo "changed"
    fi
}

# Main execution
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        exit 1
    fi

    local latest_tag
    latest_tag=$(get_latest_tag)

    local commits
    commits=$(get_commits_since_tag "$latest_tag")

    if [ -z "$commits" ]; then
        echo "No commits found since the last tag." >&2
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
            added)   added+=("- $commit") ;;
            fixed)   fixed+=("- $commit") ;;
            removed) removed+=("- $commit") ;;
            changed) changed+=("- $commit") ;;
        esac
    done <<< "$commits"

    {
        echo "# Changelog"
        echo ""
        if [ -n "$latest_tag" ]; then
            echo "## Unreleased (since $latest_tag)"
        else
            echo "## Unreleased"
        fi
        echo ""

        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf '%s\n' "${added[@]}"
            echo ""
        fi

        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf '%s\n' "${fixed[@]}"
            echo ""
        fi

        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf '%s\n' "${changed[@]}"
            echo ""
        fi

        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf '%s\n' "${removed[@]}"
            echo ""
        fi
    } > "$CHANGELOG_FILE"

    echo "CHANGELOG.md generated successfully at $CHANGELOG_FILE"
}

main "$@"
# Generate Changelog Skill

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

**Behavior:**
- Fetches all commits since the latest git tag
- Auto-categorizes commits into `Added`, `Fixed`, `Changed`, or `Removed`
- Writes the result to `CHANGELOG.md` in the repository root

**Usage:**
