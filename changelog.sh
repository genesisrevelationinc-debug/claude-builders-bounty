#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage:
#   bash changelog.sh              # Generates/updates CHANGELOG.md
#   bash changelog.sh --dry-run    # Preview changes without writing
#
# Features:
#   - Fetches commits since the last git tag
#   - Auto-categorizes into: Added / Fixed / Changed / Removed
#   - Appends to existing CHANGELOG.md or creates a new one
#

set -euo pipefail

# ── Configuration ───────────────────────────────────────────────────────────

SCRIPT_NAME=$(basename "$0")
DRY_RUN=false
OUTPUT_FILE="CHANGELOG.md"

# ── Parse arguments ─────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $SCRIPT_NAME [--dry-run] [-o|--output <file>]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# ── Helpers ─────────────────────────────────────────────────────────────────

error() {
    echo "Error: $1" >&2
    exit 1
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run from within a git project."
fi

# Get the latest tag, or empty if none
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

# Determine the commit range
if [[ -n "$LATEST_TAG" ]]; then
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    VERSION_HEADER="## [Unreleased] — since ${LATEST_TAG}"
else
    COMMIT_RANGE="HEAD"
    VERSION_HEADER="## [Unreleased] — all commits"
fi

# Get commits: hash and subject
mapfile -t COMMITS < <(git log "$COMMIT_RANGE" --pretty=format:"%s" 2>/dev/null || true)

if [[ ${#COMMITS[@]} -eq 0 ]]; then
    echo "No new commits found since ${LATEST_TAG:-the beginning}."
    exit 0
fi

# ── Categorization ──────────────────────────────────────────────────────────

declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

for commit in "${COMMITS[@]}"; do
    # Normalize for matching
    lower=$(echo "$commit" | tr '[:upper:]' '[:lower:]')

    if [[ "$lower" =~ ^(feat|feature|add|introduce|implement|create|new) ]]; then
        ADDED+=("$commit")
    elif [[ "$lower" =~ ^(fix|bugfix|hotfix|patch|resolve|correct) ]]; then
        FIXED+=("$commit")
    elif [[ "$lower" =~ ^(remove|delete|drop|revert|deprecate|clean) ]]; then
        REMOVED+=("$commit")
    elif [[ "$lower" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize) ]]; then
        CHANGED+=("$commit")
    else
        OTHER+=("$commit")
    fi
done

# ── Build output ────────────────────────────────────────────────────────────

BUILD_DATE=$(date +%Y-%m-%d)

{
    echo "$VERSION_HEADER ($BUILD_DATE)"
    echo ""

    print_section() {
        local title="$1"
        shift
        local -n arr="$1"
        if [[ ${#arr[@]} -gt 0 ]]; then
            echo "### $title"
            for item in "${arr[@]}"; do
                echo "- $item"
            done
            echo ""
        fi
    }

    print_section "Added" ADDED
    print_section "Fixed" FIXED
    print_section "Changed" CHANGED
    print_section "Removed" REMOVED

    if [[ ${#OTHER[@]} -gt 0 ]]; then
        echo "### Other"
        for item in "${OTHER[@]}"; do
            echo "- $item"
        done
        echo ""
    fi
} > /tmp/changelog_new_section.md

# ── Write or preview ────────────────────────────────────────────────────────

if $DRY_RUN; then
    echo "=== Preview of new section ==="
    cat /tmp/changelog_new_section.md
    exit 0
fi

# Prepend new section to existing CHANGELOG or create fresh
if [[ -f "$OUTPUT_FILE" ]]; then
    # Extract existing content after the header
    {
        cat /tmp/changelog_new_section.md
        # Skip the title if it exists, keep the rest
        if head -1 "$OUTPUT_FILE" | grep -q "^# Changelog"; then
            tail -n +2 "$OUTPUT_FILE"
        else
            cat "$OUTPUT_FILE"
        fi
    } > /tmp/changelog_combined.md
    mv /tmp/changelog_combined.md "$OUTPUT_FILE"
else
    {
        echo "# Changelog"
        echo ""
        cat /tmp/changelog_new_section.md
    } > "$OUTPUT_FILE"
fi

echo "✅ CHANGELOG updated: $OUTPUT_FILE"
--- /dev/null
# /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

## Usage

