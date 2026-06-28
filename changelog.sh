#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them, and
# appends a new version section to CHANGELOG.md.
#

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────
CATEGORIES="Added Fixed Changed Removed"
CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# ── Helpers ─────────────────────────────────────────────────────────
error() { echo "❌ $1" >&2; exit 1; }
info()  { echo "ℹ️  $1"; }

# ── Ensure we're in a git repo ──────────────────────────────────────
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run this script from a git repo."
fi

# ── Find the latest tag ──────────────────────────────────────────────
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [ -z "$LATEST_TAG" ]; then
    info "No tags found. Using all commits."
    COMMIT_RANGE=""
    VERSION="v0.1.0"
else
    info "Latest tag: $LATEST_TAG"
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    # Derive next version (simple patch bump)
    VERSION=$(echo "$LATEST_TAG" | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
fi

# ── Fetch commits ───────────────────────────────────────────────────
if [ -z "$COMMIT_RANGE" ]; then
    COMMITS=$(git log --pretty=format:"%s" 2>/dev/null || true)
else
    COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%s" 2>/dev/null || true)
fi

if [ -z "$COMMITS" ]; then
    info "No new commits since $LATEST_TAG."
    exit 0
fi

# ── Categorize commits ──────────────────────────────────────────────
declare -A CATEGORY_COMMITS
for cat in $CATEGORIES; do
    CATEGORY_COMMITS[$cat]=""
done

while IFS= read -r line; do
    [ -z "$line" ] && continue

    # Skip merge commits and common noise
    [[ "$line" =~ ^Merge[[:space:]] ]] && continue
    [[ "$line" =~ ^Revert[[:space:]] ]] && continue

    # Determine category based on conventional commit prefixes
    if [[ "$line" =~ ^[Ff]eat(\(.*\))?: ]] || [[ "$line" =~ ^[Aa]dd ]]; then
        CATEGORY_COMMITS[Added]+="$line"$'\n'
    elif [[ "$line" =~ ^[Ff]ix(\(.*\))?: ]] || [[ "$line" =~ ^[Bb]ugfix ]] || [[ "$line" =~ ^[Pp]atch ]]; then
        CATEGORY_COMMITS[Fixed]+="$line"$'\n'
    elif [[ "$line" =~ ^[Rr]emove ]] || [[ "$line" =~ ^[Dd]elete ]] || [[ "$line" =~ ^[Dd]rop ]]; then
        CATEGORY_COMMITS[Removed]+="$line"$'\n'
    elif [[ "$line" =~ ^[Cc]hange ]] || [[ "$line" =~ ^[Uu]pdate ]] || [[ "$line" =~ ^[Rr]efactor ]] || [[ "$line" =~ ^[Mm]odify ]]; then
        CATEGORY_COMMITS[Changed]+="$line"$'\n'
    else
        # Default to Changed for uncategorized commits
        CATEGORY_COMMITS[Changed]+="$line"$'\n'
    fi
done <<< "$COMMITS"

# ── Build new changelog section ─────────────────────────────────────
NEW_SECTION=""
NEW_SECTION+="# $VERSION ($DATE)"$'\n\n'

for cat in $CATEGORIES; do
    if [ -n "${CATEGORY_COMMITS[$cat]}" ]; then
        NEW_SECTION+="## $cat"$'\n\n'
        while IFS= read -r commit; do
            [ -z "$commit" ] && continue
            # Clean up the commit message for display
            CLEAN_COMMIT=$(echo "$commit" | sed 's/^[a-zA-Z]*(\([^)]*\)): //; s/^[a-zA-Z]*: //')
            NEW_SECTION+="- $CLEAN_COMMIT"$'\n'
        done <<< "${CATEGORY_COMMITS[$cat]}"
        NEW_SECTION+=$'\n'
    fi
done

# ── Write or update CHANGELOG.md ────────────────────────────────────
if [ -f "$CHANGELOG_FILE" ]; then
    # Prepend new section after the header
    if head -1 "$CHANGELOG_FILE" | grep -q "^# "; then
        # Has a title/header line
        {
            head -1 "$CHANGELOG_FILE"
            echo ""
            echo "$NEW_SECTION"
            tail -n +2 "$CHANGELOG_FILE"
        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    else
        {
            echo "$NEW_SECTION"
            cat "$CHANGELOG_FILE"
        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    fi
else
    # Create new CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "$NEW_SECTION"
    } > "$CHANGELOG_FILE"
fi

info "CHANGELOG.md updated with version $VERSION"
info "Commits included: $(echo "$COMMITS" | wc -l | tr -d ' ')"