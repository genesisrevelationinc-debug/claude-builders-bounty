#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them, and appends
# a new section to CHANGELOG.md (creates it if missing).
#
# Categories: Added / Fixed / Changed / Removed
#

set -euo pipefail

# ── Helpers ─────────────────────────────────────────────────────────

error() {
  echo "Error: $1" >&2
  exit 1
}

# Check we're inside a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  error "Not a git repository."
fi

# ── Determine range ────────────────────────────────────────────────

# Get the latest tag (empty if none)
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [ -z "$LATEST_TAG" ]; then
  echo "No tags found. Using all commits."
  COMMIT_RANGE="HEAD"
else
  echo "Latest tag: $LATEST_TAG"
  COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# ── Gather commits ─────────────────────────────────────────────────

# Format: hash|subject
COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%H|%s" 2>/dev/null || true)

if [ -z "$COMMITS" ]; then
  echo "No new commits since $LATEST_TAG."
  exit 0
fi

# ── Categorize ─────────────────────────────────────────────────────

ADDED=""
FIXED=""
CHANGED=""
REMOVED=""

while IFS= read -r line; do
  HASH=$(echo "$line" | cut -d'|' -f1)
  SUBJECT=$(echo "$line" | cut -d'|' -f2-)
  LOWER=$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]')

  # Skip merge commits
  [[ "$LOWER" == merge* ]] && continue

  # Categorize based on keywords / conventional commit prefixes
  if [[ "$LOWER" == feat* ]] || [[ "$LOWER" == add* ]] || [[ "$LOWER" == introduce* ]] || [[ "$LOWER" == implement* ]]; then
    ADDED="${ADDED}- ${SUBJECT}"$'\n'
  elif [[ "$LOWER" == fix* ]] || [[ "$LOWER" == bug* ]] || [[ "$LOWER" == repair* ]] || [[ "$LOWER" == resolve* ]]; then
    FIXED="${FIXED}- ${SUBJECT}"$'\n'
  elif [[ "$LOWER" == remove* ]] || [[ "$LOWER" == delete* ]] || [[ "$LOWER" == drop* ]] || [[ "$LOWER" == deprecate* ]]; then
    REMOVED="${REMOVED}- ${SUBJECT}"$'\n'
  elif [[ "$LOWER" == change* ]] || [[ "$LOWER" == update* ]] || [[ "$LOWER" == refactor* ]] || [[ "$LOWER" == improve* ]] || [[ "$LOWER" == chore* ]] || [[ "$LOWER" == docs* ]] || [[ "$LOWER" == style* ]] || [[ "$LOWER" == test* ]]; then
    CHANGED="${CHANGED}- ${SUBJECT}"$'\n'
  else
    # Default to Changed if no match
    CHANGED="${CHANGED}- ${SUBUBJECT}"$'\n'
  fi
done <<< "$COMMITS"

# ── Build changelog section ──────────────────────────────────────

TODAY=$(date +%Y-%m-%d)

if [ -n "$LATEST_TAG" ]; then
  HEADER="## [Unreleased] — $TODAY"
else
 uin
  HEADER="## [Unreleased] — $TODAY"
fi

SECTION=""
SECTION+="${HEADER}"$'\n\n'

if [ -n "$ADDED" ]; then
  SECTION+="### Added"$'\n\n'"${ADDED}"$'\n'
fi

if [ -n "$FIXED" ]; then
  SECTION+="### Fixed"$'\n\n'"${FIXED}"$'\n'
fi

if [ -n "$CHANGED" ]; then
  SECTION+="### Changed"$'\n\n'"${CHANGED}"$'\n'
fi

if [ -n "$REMOVED" ]; then
  SECTION+="### Removed"$'\n\n'"${REMOVED}"$'\n'
fi

# ── Write / Update CHANGELOG.md ────────────────────────────────────

if [ ! -f CHANGELOG.md ]; then
  echo "# Changelog"$'\n\n'"$SECTION" > CHANGELOG.md
else
  # Insert new section after the header
  {
    head -n 2 CHANGELOG.md
    echo ""
    echo "$SECTION"
    tail -n +3 CHANGELOG.md
  } > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
fi

echo "CHANGELOG.md updated successfully."

--- /dev/null
# Skill: Generate Changelog

## /generate-changelog

Generate a structured `CHANGELOG.md` from the project's git history.

### Description

This skill runs `changelog.sh` to fetch commits since the last git tag,
auto-categorize them, and append a formatted section to `CHANGELOG.md`.

### Usage

