#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage:
#   ./changelog.sh                    # generate CHANGELOG.md in current dir
#   ./changelog.sh -o RELEASE.md      # output to a custom file
#   ./changelog.sh -t v1.0.0          # start from a specific tag
#   ./changelog.sh -r                 # include full release (all commits)
#
# Requires: git, bash 4+

set -euo pipefail

# ── defaults ──────────────────────────────────────────────
OUTPUT="CHANGELOG.md"
START_TAG=""
FULL_RELEASE=false

# ── helpers ───────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -o FILE     Output file (default: CHANGELOG.md)
  -t TAG      Start from a specific tag (default: latest tag)
  -r          Include all commits (ignore tags)
  -h          Show this help
EOF
  exit 0
}

die() { echo "ERROR: $*" >&2; exit 1; }

# ── parse args ────────────────────────────────────────────
while getopts "o:t:rh" opt; do
  case $opt in
    o) OUTPUT="$OPTARG" ;;
    t) START_TAG="$OPTARG" ;;
    r) FULL_RELEASE=true ;;
    h) usage ;;
    *) usage ;;
  esac
done

# ── ensure we are in a git repo ───────────────────────────
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "Not inside a git repository."

# ── determine commit range ────────────────────────────────
if $FULL_RELEASE; then
  RANGE=""
  RANGE_DESC="all commits"
elif [[ -n "$START_TAG" ]]; then
  if ! git rev-parse "$START_TAG" >/dev/null 2>&1; then
    die "Tag '$START_TAG' does not exist."
  fi
  RANGE="$START_TAG..HEAD"
  RANGE_DESC="$START_TAG → HEAD"
else
  LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
  if [[ -z "$LATEST_TAG" ]]; then
    RANGE=""
    RANGE_DESC="all commits (no tags found)"
  else
    RANGE="$LATEST_TAG..HEAD"
    RANGE_DESC="$LATEST_TAG → HEAD"
  fi
fi

# ── fetch commits ─────────────────────────────────────────
if [[ -z "$RANGE" ]]; then
  COMMITS=$(git log --oneline --no-merges --format="%s")
else
  COMMITS=$(git log --oneline --no-merges --format="%s" "$RANGE")
fi

if [[ -z "$COMMITS" ]]; then
  echo "No commits found in range ($RANGE_DESC). Nothing to do."
  exit 0
fi

# ── categorize commits ────────────────────────────────────
declare -a ADDED FIXED CHANGED REMOVED OTHER

while IFS= read -r line; do
  # Normalise: strip leading whitespace, lowercase for matching
  msg=$(echo "$line" | sed 's/^[[:space:]]*//')
  lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

  if   [[ "$lower" =~ ^(add|feat|feature|new|implement|introduce) ]]; then
    ADDED+=("$msg")
  elif [[ "$lower" =~ ^(fix|bug|patch|repair|resolve|hotfix) ]]; then
    FIXED+=("$msg")
  elif [[ "$lower" =~ ^(remove|drop|delete|deprecate|retire) ]]; then
    REMOVED+=("$msg")
  elif [[ "$lower" =~ ^(change|update|refactor|improve|tweak|adjust|modify|enhance|upgrade|rework) ]]; then
    CHANGED+=("$msg")
  else
    OTHER+=("$msg")
  fi
done <<< "$COMMITS"

# ── build changelog ───────────────────────────────────────
TODAY=$(date +%Y-%m-%d)
VERSION="${START_TAG:-unreleased}"
[[ -z "$START_TAG" && -z "$FULL_RELEASE" ]] && VERSION="Unreleased"

{
  echo "# Changelog"
  echo ""
  echo "## [$VERSION] — $TODAY"
  echo ""
  echo "_Range: $RANGE_DESC_"
  echo ""

  section() {
    local title="$1"
    shift
    local -a items=("$@")
    if [[ ${#items[@]} -gt 0 ]]; then
      echo "### $title"
      echo ""
      for item in "${items[@]}"; do
        echo "- $item"
      done
      echo ""
    fi
  }

  section "Added"   "${ADDED[@]}"
  section "Fixed"   "${FIXED[@]}"
  section "Changed" "${CHANGED[@]}"
  section "Removed" "${REMOVED[@]}"

  if [[ ${#OTHER[@]} -gt 0 ]]; then
    echo "### Other"
    echo ""
    for item in "${OTHER[@]}"; do
      echo "- $item"
    done
    echo ""
  fi
} > "$OUTPUT"

echo "✅ Changelog written to $OUTPUT ($(wc -l < "$OUTPUT") lines)"