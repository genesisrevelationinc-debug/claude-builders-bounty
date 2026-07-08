#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# Get the latest tag, or empty if no tags exist
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag)
get_commits() {
    local tag
    tag=$(get_latest_tag)
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a single commit message
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    case "$lower" in
        *"fix"* | *"bug"* | *"patch"* | *"repair"* | *"resolve"* | *"close"*)
            echo "Fixed"
            ;;
        *"add"* | *"feat"* | *"new"* | *"introduce"* | *"implement"*)
            echo "Added"
            ;;
        *"remove"* | *"delete"* | *"drop"* | *"deprecate"*)
            echo "Removed"
            ;;
        *"update"* | *"change"* | *"refactor"* | *"improve"* | *"enhance"* | *"modify"* | *"upgrade"*)
            echo "Changed"
            ;;
        *)
            echo "Changed"
            ;;
    esac
}

# Generate the changelog
generate_changelog() {
    local tag
    tag=$(get_latest_tag)
    local version
    version=${tag:-$(git rev-parse --short HEAD)}

    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue
        local cat
        cat=$(categorize "$commit")
        case "$cat" in
            Added) added+=("$commit") ;;
            Fixed) fixed+=("$commit") ;;
            Changed) changed+=("$commit") ;;
            Removed) removed+=("$commit") ;;
        esac
    done < <(get_commits)

    {
        echo "# Changelog"
        echo ""
        echo "## [${version}] - ${DATE}"
        echo ""

        [ ${#added[@]} -gt 0 ] && { echo "### Added"; for c in "${added[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#fixed[@]} -gt 0 ] && { echo "### Fixed"; for c in "${fixed[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#changed[@]} -gt 0 ] && { echo "### Changed"; for c in "${changed[@]}"; do echo "- $c"; done; echo ""; }
        [ ${#removed[@]} -gt 0 ] && { echo "### Removed"; for c in "${removed[@]}"; do echo "- $c"; done; echo ""; }
    } > "$CHANGELOG_FILE"

    echo "✅ Generated $CHANGELOG_FILE (version: $version)"
}

generate_changelog