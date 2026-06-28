#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them, and appends
# to (or creates) CHANGELOG.md in Keep a Changelog format.
#

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────
CHANGELOG_FILE="CHANGELOG.md"
DATE=$(date +%Y-%m-%d)

# ── Helpers ─────────────────────────────────────────────────────────
error() { echo "Error: $1" >&2; exit 1; }

# Must be inside a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  error "Not a git repository. Please run this script from inside a git repo."
fi

# Find the latest tag
LATEST_TAG=$(anch=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [[ -z "$LATEST_TAG" ]]; then
  echo "No previous tag found. Using all commits."
  COMMIT_RANGE="HEAD"
else
  echo "Latest tag found: $LATEST_TAG"
  COMMIT_RANGE="${LATEST_TAG}..HEAD"
fi

# Gather commits
COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%s" 2>/dev/null || true)

if [[ -z "$COMMITS" ]]; then
  echo "No new commits since $LATEST_TAG."
  exit 0
fi

# ── Categorize commits ───────────────────────────────────────────────
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

  if [[ "$lower" =~ ^(feat|add|create|implement|introduce) ]]; then
    ADDED+=("$line")
  elif [[ "$lower" =~ ^(fix|bugfix|hotfix|resolve|patch) ]]; then
    FIXED+=("$line")
  elif [[ "$lower" =~ ^(remove|delete|drop|revert) ]]; then
    REMOVED+=("$line")
  elif [[ "$lower" =~ ^(update|change|modify|refactor|improve|upgrade|chore|deps) ]]; then
    CHANGED+=("$line")
  else
    OTHER+=("$line")
  fi
done <<< "$COMMITS"

# ── Build changelog entry ───────────────────────────────────────────
{
  echo "## [Unreleased] - $DATE"
  echo ""

  if [[ ${#ADDED[@]} -gt 0 ]]; then
    echo "### Added"
    for c in "${ADDED[@]}"; do echo "- $c"; done
    echo ""
  fi

  if [[ ${#CHANGED[@]} -gt 0 ]]; then
    echo "### Changed"
    for c in "${CHANGED[@]}"; do echo "- $c"; done
    echo ""
  fi

  if [[ ${#FIXED[@]} -gt 0 ]]; then
    echo "### Fixed"
    for c in "${FIXED[@]}"; do echo "- $c"; done
    echo ""
  fi

  if [[ ${#REMOVED[@]} -gt 0 ]]; then
    echo "### Removed"
    for c in "${REMOVED[@]}"; do echo "- $c"; done
    echo ""
  fi

  if [[ ${#OTHER[@]} -gt 0 ]]; then
    echo "### Other"
    for c in "${OTHER[@]}"; do echo "- $c"; done
    echo ""
  fi

  echo ""
} > .changelog_new.md

# ── Prepend or create CHANGELOG.md ──────────────────────────────────
if [[ -f "$CHANGELOG_FILE" ]]; then
  # Insert new entry after the header (assumes first line is header)
  { head -n 1 "$CHANGELOG_FILE"; cat .changelog_new.md; tail -n +2 "$CHANGELOG_FILE"; } > .changelog_tmp.md
  mv .changelog_tmp.md "$CHANGELOG_FILE"
else
  cat .changelog_new.md > "$CHANGELOG_FILE"
fi

rm -f .changelog_new.md

echo "✅ CHANGELOG updated in $CHANGELOG_FILE"
# Skill: Generate Changelog

## Description
Generate a structured `CHANGELOG.md` from git history, auto-categorizing commits since the last tag.

## Usage
Run the following command in Claude Code:

