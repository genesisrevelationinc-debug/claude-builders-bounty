Based on the issue, I need to create a bash script (`changelog.sh`) and update the `README.md` with setup instructions. Let me create both files.

```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,145 @@
+#!/usr/bin/env bash
+#
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+#
+# Usage:
+#   ./changelog.sh                    # writes CHANGELOG.md in current directory
+#   ./changelog.sh -o RELEASE.md      # custom output filename
+#   ./changelog.sh -t v1.0.0          # start from a specific tag
+#   ./changelog.sh -r                 # include release date in header
+#
+# Requirements: git, bash 4+
+
+set -euo pipefail
+
+# ── defaults ──────────────────────────────────────────────────────────
+OUTPUT="CHANGELOG.md"
+SINCE_TAG=""
+INCLUDE_DATE=false
+
+# ── parse flags ───────────────────────────────────────────────────────
+while [[ $# -gt 0 ]]; do
+  case "$1" in
+    -o|--output) OUTPUT="$2"; shift 2 ;;
+    -t|--since-tag) SINCE_TAG="$2"; shift 2 ;;
+    -r|--with-date) INCLUDE_DATE=true; shift ;;
+    -h|--help)
+      echo "Usage: changelog.sh [-o FILE] [-t TAG] [-r]"
+      echo ""
+      echo "  -o, --output FILE     Write changelog to FILE (default: CHANGELOG.md)"
+      echo "  -t, --since-tag TAG   Start from TAG instead of latest tag"
+      echo "  -r, --with-date       Include the release date in the header"
+      echo "  -h, --help            Show this help"
+      exit 0
+      ;;
+    *) echo "Unknown option: $1"; exit 1 ;;
+  esac
+done
+
+# ── determine starting point ──────────────────────────────────────────
+if [[ -n "$SINCE_TAG" ]]; then
+  RANGE="$SINCE_TAG..HEAD"
+  TAG_NAME="$SINCE_TAG"
+else
+  LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
+  if [[ -z "$LATEST_TAG" ]]; then
+    # No tags exist — use the first commit
+    FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
+    RANGE="$FIRST_COMMIT..HEAD"
+    TAG_NAME="initial"
+  else
+    RANGE="$LATEST_TAG..HEAD"
+    TAG_NAME="$LATEST_TAG"
+  fi
+fi
+
+# ── collect commits ───────────────────────────────────────────────────
+COMMITS=$(git log "$RANGE" --pretty=format:"%s" --no-merges 2>/dev/null || true)
+
+if [[ -z "$COMMITS" ]]; then
+  echo "No commits found in range $RANGE. Nothing to do."
+  exit 0
+fi
+
+# ── categorise commits ────────────────────────────────────────────────
+declare -a ADDED=()
+declare -a FIXED=()
+declare -a CHANGED=()
+declare -a REMOVED=()
+declare -a OTHER=()
+
+while IFS= read -r line; do
+  [[ -z "$line" ]] && continue
+
+  # Normalise: strip leading/trailing whitespace, collapse spaces
+  msg=$(echo "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+/ /g')
+
+  # Categorise by conventional-commit prefix or keyword
+  if echo "$msg" | grep -qiE '^(feat|add|added|implement|create|introduce|new)[^a-z]'; then
+    ADDED+=("- $msg")
+  elif echo "$msg" | grep -qiE '^(fix|fixed|bug|patch|resolve|repair|hotfix)[^a-z]'; then
+    FIXED+=("- $msg")
+  elif echo "$msg" | grep -qiE '^(remove|removed|delete|drop|deprecate|retire)[^a-z]'; then
+    REMOVED+=("- $msg")
+  elif echo "$msg" | grep -qiE '^(change|changed|update|refactor|tweak|adjust|improve|enhance|modify|rework|revamp)[^a-z]'; then
+    CHANGED+=("- $msg")
+  else
+    # Fallback: keyword scanning inside the message
+    if echo "$msg" | grep -qiE '\b(add|added|implement|create|introduce|new)\b'; then
+      ADDED+=("- $msg")
+    elif echo "$msg" | grep -qiE '\b(fix|fixed|bug|patch|resolve|repair|hotfix)\b'; then
+      FIXED+=("- $msg")
+    elif echo "$msg" | grep -qiE '\b(remove|removed|delete|drop|deprecate|retire)\b'; then
+      REMOVED+=("- $msg")
+    elif echo "$msg" | grep -qiE '\b(change|changed|update|refactor|tweak|adjust|improve|enhance|modify|rework|revamp)\b'; then
+      CHANGED+=("- $msg")
+    else
+      OTHER+=("- $msg")
+    fi
+  fi
+done <<< "$COMMITS"
+
+# ── build changelog ───────────────────────────────────────────────────
+{
+  echo "# Changelog"
+  echo ""
+
+  # Header
+  if $INCLUDE_DATE; then
+    echo "## $(date +%Y-%m-%d) — since \`$TAG_NAME\`"
+  else
+    echo "## Unreleased — since \`$TAG_NAME\`"
+  fi
+  echo ""
+
+  # Added
+  if [[ ${#ADDED[@]} -gt 0 ]]; then
+    echo "### Added"
+    printf '%s\n' "${ADDED[@]}"
+    echo ""
+  fi
+
+  # Fixed
+  if [[ ${#FIXED[@]} -gt 0 ]]; then