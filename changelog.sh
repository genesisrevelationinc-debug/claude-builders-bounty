#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#        ./changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

error() { echo "❌ $*" >&2; exit 1; }
info()  { echo "ℹ️  $*"; }

# ── Detect last tag ────────────────────────────────────────────────────────

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [[ -z "$LAST_TAG" ]]; then
  info "No tags found. Using all commits."
  COMMIT_RANGE=""
else
  info "Last tag: $LAST_TAG"
  COMMIT_RANGE="${LAST_TAG}..HEAD"
fi

# ── Fetch commits ──────────────────────────────────────────────────────────

if [[ -z "$COMMIT_RANGE" ]]; then
  COMMITS=$(git log --pretty=format:"%s" --no-merges 2>/dev/null || true)
else
  COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%s" --no-merges 2>/dev/null || true)
fi

if [[ -z "$COMMITS" ]]; then
  error "No commits found since last tag."
fi

# ── Categorize commits ─────────────────────────────────────────────────────

declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

while IFS= read -r line; do
  # Skip empty lines
  [[ -z "$line" ]] && continue

  lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

  if [[ "$lower" =~ ^(feat|add|new|introduce|implement|create|support|enable) ]] ||
     [[ "$lower" =~ (add|added|adding|introduce|implement|create|support|enable) ]]; then
    ADDED+=("$line")
  elif [[ "$lower" =~ ^(fix|bugfix|hotfix|patch|resolve|correct|repair) ]] ||
       [[ "$lower" =~ (fix|fixed|fixing|resolve|resolved|correct|repair) ]]; then
    FIXED+=("$line")
  elif [[ "$lower" =~ ^(remove|delete|drop|eliminate|deprecate|clean|cleanup) ]] ||
       [[ "$lower" =~ (remove|removed|removing|delete|deleted|deleting|drop|dropped|eliminate|deprecate|clean|cleanup) ]]; then
    REMOVED+=("$line")
  elif [[ "$lower" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize) ]] ||
       [[ "$lower" =~ (update|updated|change|changed|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|optimize) ]]; then
    CHANGED+=("$line")
  else
    OTHER+=("$line")
  fi
done <<< "$COMMITS"

# ── Build changelog entry ──────────────────────────────────────────────────

TODAY=$(date +%Y-%m-%d)
NEW_VERSION="unreleased"

if [[ -n "$LAST_TAG" ]]; then
  # Try to infer next version (simple semver bump)
  NEW_VERSION="${LAST_TAG}-next"
fi

OUTPUT=""
OUTPUT+="\n## [${NEW_VERSION}] - ${TODAY}\n"

if [[ ${#ADDED[@]} -gt 0 ]]; then
  OUTPUT+="\n### Added\n"
  for c in "${ADDED[@]}"; do
    OUTPUT+="- $c\n"
  done
fi

if [[ ${#FIXED[@]} -gt 0 ]]; then
  OUTPUT+="\n### Fixed\n"
  for c in "${FIXED[@]}"; do
    OUTPUT+="- $c\n"
  done
fi

if [[ ${#CHANGED[@]} -gt 0 ]]; then
  OUTPUT+="\n### Changed\n"
  for c in "${CHANGED[@]}"; do
    OUTPUT+="- $c\n"
  done
fi

if [[ ${#REMOVED[@]} -gt 0 ]]; then
  OUTPUT+="\n### Removed\n"
  for c in "${REMOVED[@]}"; do
    OUTPUT+="- $c\n"
  done
fi

if [[ ${#OTHER[@]} -gt 0 ]]; then
  OUTPUT+="\n### Other\n"
  for c in "${OTHER[@]}"; do
    OUTPUT+="- $c\n"
  done
fi

# ── Write to CHANGELOG.md ──────────────────────────────────────────────────

if [[ -f CHANGELOG.md ]]; then
  # Prepend new entry after the header
  if head -n 1 CHANGELOG.md | grep -q "^# "; then
    # Has a title/header line
    {
      head -n 1 CHANGELOG.md
      echo -e "$OUTPUT"
      tail -n +2 CHANGELOG.md
    } > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
  else
    echo -e "$OUTPUT" > CHANGELOG.md.tmp
    cat CHANGELOG.md >> CHANGELOG.md.tmp
    mv CHANGELOG.md.tmp CHANGELOG.md
  fi
else
  echo -e "# Changelog\n$OUTPUT" > CHANGELOG.md
fi

info "CHANGELOG.md updated with version $NEW_VERSION"
