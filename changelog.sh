#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# changelog.sh — Generate a structured CHANGELOG.md from git history
# ──────────────────────────────────────────────

OUTPUT_FILE="${1:-CHANGELOG.md}"

# Ensure we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not inside a git repository." >&2
  exit 1
fi

# ── Determine the range of commits ─────────────────
# Get the latest tag; if none exists, use the first commit
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)

if [[ -n "$LATEST_TAG" ]]; then
  RANGE="${LATEST_TAG}..HEAD"
  VERSION_INFO="since \`${LATEST_TAG}\`"
else
  # No tags at all — use the entire history
  FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
  RANGE="${FIRST_COMMIT}..HEAD"
  VERSION_INFO="all commits"
fi

# ── Collect commits ───────────────────────────────
COMMITS=$(git log "${RANGE}" --pretty=format:"%s" 2>/dev/null || true)

if [[ -z "$COMMITS" ]]; then
  echo "No new commits found ${VERSION_INFO}." >&2
  # Still write a minimal changelog
  cat > "$OUTPUT_FILE" <<EOF
# Changelog

## [Unreleased]

No new commits ${VERSION_INFO}.

---
*Generated on $(date -u +"%Y-%m-%d")*
EOF
  echo "Wrote empty changelog to $OUTPUT_FILE"
  exit 0
fi

# ── Categorisation helpers ────────────────────────
declare -a ADDED=()
declare -a FIXED=()
declare -a CHANGED=()
declare -a REMOVED=()
declare -a OTHER=()

# Normalise and categorise each commit subject
while IFS= read -r line; do
  # Skip empty lines
  [[ -z "$line" ]] && continue

  # Lowercase for matching
  lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')

  if   [[ "$lower" =~ ^(add|feat|feature|new|implement|introduce) ]]; then
    ADDED+=("$line")
  elif [[ "$lower" =~ ^(fix|bug|hotfix|patch|resolve|correct) ]]; then
    FIXED+=("$line")
  elif [[ "$lower" =~ ^(remove|drop|delete|deprecate|retire) ]]; then
    REMOVED+=("$line")
  elif [[ "$lower" =~ ^(change|update|refactor|improve|tweak|adjust|modify|enhance|upgrade|rework|reorganize|reorganise) ]]; then
    CHANGED+=("$line")
  else
    OTHER+=("$line")
  fi
done <<< "$COMMITS"

# ── Build the changelog ───────────────────────────
{
  echo "# Changelog"
  echo ""
  echo "## [Unreleased]"
  echo ""
  echo "> Commits ${VERSION_INFO}"
  echo ""

  # Helper to print a section if the array is non-empty
  print_section() {
    local title="$1"
    shift
    local lines=("$@")
    if [[ ${#lines[@]} -gt 0 ]]; then
      echo "### ${title}"
      echo ""
      for item in "${lines[@]}"; do
        echo "- ${item}"
      done
      echo ""
    fi
  }

  print_section "Added"   "${ADDED[@]}"
  print_section "Fixed"   "${FIXED[@]}"
  print_section "Changed" "${CHANGED[@]}"
  print_section "Removed" "${REMOVED[@]}"

  # Any commits that didn't match a category go into "Other"
  if [[ ${#OTHER[@]} -gt 0 ]]; then
    echo "### Other"
    echo ""
    for item in "${OTHER[@]}"; do
      echo "- ${item}"
    done
    echo ""
  fi

  echo "---"
  echo "*Generated on $(date -u +"%Y-%m-%d")*"
} > "$OUTPUT_FILE"

echo "✅ Changelog written to $OUTPUT_FILE"
echo "   $((${#ADDED[@]} + ${#FIXED[@]} + ${#CHANGED[@]} + ${#REMOVED[@]} + ${#OTHER[@]})) commits processed."
echo "   Added: ${#ADDED[@]} | Fixed: ${#FIXED[@]} | Changed: ${#CHANGED[@]} | Removed: ${#REMOVED[@]} | Other: ${#OTHER[@]}"