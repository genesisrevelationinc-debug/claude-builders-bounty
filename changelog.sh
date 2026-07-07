#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage:
#   bash changelog.sh              # Generate CHANGELOG.md
#   bash changelog.sh --dry-run    # Preview without writing file
#
# Features:
#   - Fetches commits since the last git tag
#   - Auto-categorizes into: Added / Fixed / Changed / Removed
#   - Outputs a properly formatted CHANGELOG.md
#

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

OUTPUT_FILE="CHANGELOG.md"
DRY_RUN=false

# ─── Parse arguments ─────────────────────────────────────────────────────────

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# ─── Helpers ─────────────────────────────────────────────────────────────────

error() {
    echo "Error: $1" >&2
    exit 1
}

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run this script from a git repo."
fi

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [[ -z "$LATEST_TAG" ]]; then
    echo "No tags found. Using all commits."
    COMMIT_RANGE=""
else
    echo "Latest tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# Get commits since last tag (or all commits if no tag)
if [[ -z "$COMMIT_RANGE" ]]; then
    COMMITS=$(git log --pretty=format:"%s" --no-merges 2>/dev/null || true)
else
    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" --no-merges 2>/dev/null || true)
fi

if [[ -z "$COMMITS" ]]; then
    echo "No commits found since last tag."
    exit 0
fi

# ─── Categorize commits ──────────────────────────────────────────────────────

declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Categorize based on conventional commit prefixes or keywords
    if [[ "$line" =~ ^[Ff]eat(\(.*\))?: ]] || \
       [[ "$line" =~ ^[Aa]dd ]] || \
       [[ "$line" =~ ^[Ii]ntroduce ]]; then
        ADDED+=("$line")
    elif [[ "$line" =~ ^[Ff]ix(\(.*\))?: ]] || \
         [[ "$line" =~ ^[Bb]ugfix ]] || \
         [[ "$line" =~ ^[Rr]esolve ]] || \
         [[ "$line" =~ ^[Cc]orrect ]]; then
        FIXED+=("$line")
    elif [[ "$line" =~ ^[Cc]hange(\(.*\))?: ]] || \
         [[ "$line" =~ ^[Uu]pdate ]] || \
         [[ "$line" =~ ^[Rr]efactor ]] || \
         [[ "$line" =~ ^[Mm]odify ]] || \
         [[ "$line" =~ ^[Ii]mprove ]]; then
        CHANGED+=("$line")
    elif [[ "$line" =~ ^[Rr]emove(\(.*\))?: ]] || \
         [[ "$line" =~ ^[Dd]elete ]] || \
         [[ "$line" =~ ^[Rr]emove ]] || \
         [[ "$line" =~ ^[Dd]rop ]]; then
        REMOVED+=("$line")
    else
        OTHER+=("$line")
    fi
done <<< "$COMMITS"

# ─── Build CHANGELOG content ─────────────────────────────────────────────────

TODAY=$(date +%Y-%m-%d)

CHANGELOG="# Changelog\n\n"
CHANGELOG+="## [Unreleased] - ${TODAY}\n\n"

if [[ ${#ADDED[@]} -gt 0 ]]; then
    CHANGELOG+="### Added\n\n"
    for item in "${ADDED[@]}"; do
        CHANGELOG+="- ${item}\n"
    done
    CHANGELOG+="\n"
fi

if [[ ${#FIXED[@]} -gt 0 ]]; then
    CHANGELOG+="### Fixed\n\n"
    for item in "${FIXED[@]}"; do
        CHANGELOG+="- ${item}\n"
    done
    CHANGELOG+="\n"
fi

if [[ ${#CHANGED[@]} -gt 0 ]]; then
    CHANGELOG+="### Changed\n\n"
    for item in "${CHANGED[@]}"; do
        CHANGELOG+="- ${item}\n"
    done
    CHANGELOG+="\n"
fi

if [[ ${#REMOVED[@]} -gt 0 ]]; then
    CHANGELOG+="### Removed\n\n"
    for item in "${REMOVED[@]}"; do
        CHANGELOG+="- ${item}\n"
    done
    CHANGELOG+="\n"
fi

if [[ ${#OTHER[@]} -gt 0 ]]; then
    CHANGELOG+="### Other\n\n"
    for item in "${OTHER[@]}"; do
        CHANGELOG+="- ${item}\n"
    done
    CHANGELOG+="\n"
fi

# ─── Output ────────────────────────────────────────────────────────────────────

if $DRY_RUN; then
    echo "=== DRY RUN — Would write to $OUTPUT_FILE ==="
    echo -e "$CHANGELOG"
else
    echo -e "$CHANGELOG" > "$OUTPUT_FILE"
    echo "✅ CHANGELOG generated: $OUTPUT_FILE"
fi

exit 0