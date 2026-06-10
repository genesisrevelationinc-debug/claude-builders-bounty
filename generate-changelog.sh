#!/usr/bin/env bash
#
# generate-changelog.sh
# Automatically generates a structured CHANGELOG.md from git history.
#
# Usage:
#   bash generate-changelog.sh
#   ./generate-changelog.sh
#
# Features:
#   - Fetches commits since the last git tag
#   - Auto-categorizes into: Added / Fixed / Changed / Removed
#   - Outputs a properly formatted CHANGELOG.md
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    log_error "Not a git repository. Please run this script from a git repository."
    exit 1
fi

# Get the latest tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Get commits since the last tag (or all commits if no tag exists)
get_commits_since_tag() {
    local tag="$1"
    if [ -n "$tag" ]; then
        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
    else
        git log --pretty=format:"%s" --no-merges
    fi
}

# Categorize a commit message
categorize_commit() {
    local message="$1"
    local lower_msg
    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(refactor|perf|style)(\(.+\))?: ]]; then
        echo "changed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
        echo "removed"
    # Fallback to keyword matching
    elif [[ "$lower_msg" =~ ^(add|create|implement|introduce|new) ]]; then
        echo "added"
    elif [[ "$lower_msg" =~ ^(fix|bugfix|resolve|patch|hotfix|correct) ]]; then
        echo "fixed"
    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|undo) ]]; then
        echo "removed"
    elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|migrate) ]]; then
        echo "changed"
    else
        echo "changed"  # Default category
    fi
}

# Main execution
main() {
    log_info "Generating CHANGELOG.md..."

    local latest_tag
    latest_tag=$(get_latest_tag)

    if [ -n "$latest_tag" ]; then
        log_info "Found latest tag: $latest_tag"
    else
        log_warn "No tags found. Using all commits."
    fi

    # Read commits into arrays by category
    local added=() fixed=() changed=() removed=()

    while IFS= read -r commit; do
        [ -z "$commit" ] && continue

        local category
        category=$(categorize_commit "$commit")

        case "$category" in
            added)   added+=("$commit") ;;
            fixed)   fixed+=("$commit") ;;
            changed) changed+=("$commit") ;;
            removed) removed+=("$commit") ;;
        esac
    done < <(get_commits_since_tag "$latest_tag")

    # Generate CHANGELOG.md
    {
        echo "# Changelog"
        echo ""

        if [ -n "$latest_tag" ]; then
            echo "## Unreleased (since $latest_tag)"
        else
            echo "## Unreleased"
        fi
        echo ""

        # Added
        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            for item in "${added[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        # Fixed
        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            for item in "${fixed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        # Changed
        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            for item in "${changed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        # Removed
        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            for item in "${removed[@]}"; do
                echo "- $item"
            done
            echo ""
        fi

        # Append existing changelog content if it exists (excluding header)
        if [ -f CHANGELOG.md ]; then
            tail -n +3 CHANGELOG.md 2>/dev/null || true
        fi

    } > CHANGELOG.md.new

    mv CHANGELOG.md.new CHANGELOG.md

    log_info "CHANGELOG.md generated successfully!"

    # Show a preview
    echo ""
    echo "Preview:"
    echo "--------"
    head -n 30 CHANGELOG.md
}

main "$@"