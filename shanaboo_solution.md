Based on the issue, I need to create a bash script (`changelog.sh`) that generates a structured CHANGELOG from git history. Since the repo only shows `LICENSE` and `README.md`, I'll create the script and update the README with setup instructions.

```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,147 @@
+#!/usr/bin/env bash
+#
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+#
+# Usage:
+#   ./changelog.sh                    # writes CHANGELOG.md in current dir
+#   ./changelog.sh -o RELEASE.md      # custom output filename
+#   ./changelog.sh -t v1.0.0          # start from a specific tag
+#   ./changelog.sh -r                 # include full release header
+#
+# Requirements: git, bash 4+
+
+set -euo pipefail
+
+# ── defaults ────────────────────────────────────────────────────────────────
+OUTPUT="CHANGELOG.md"
+FROM_TAG=""
+INCLUDE_HEADER=false
+
+# ── helpers ─────────────────────────────────────────────────────────────────
+usage() {
+  cat <<EOF
+Usage: $0 [OPTIONS]
+
+Options:
+  -o FILE    Output file (default: CHANGELOG.md)
+  -t TAG     Start from this tag instead of the latest tag
+  -r         Include a release header with date and version
+  -h         Show this help
+
+Examples:
+  $0                        # latest tag → HEAD → CHANGELOG.md
+  $0 -o RELEASE_NOTES.md    # custom output file
+  $0 -t v1.0.0 -r           # from v1.0.0 with release header
+EOF
+  exit 0
+}
+
+die() { echo "ERROR: $*" >&2; exit 1; }
+
+# ── parse args ──────────────────────────────────────────────────────────────
+while getopts "o:t:rh" opt; do
+  case "$opt" in
+    o) OUTPUT="$OPTARG" ;;
+    t) FROM_TAG="$OPTARG" ;;
+    r) INCLUDE_HEADER=true ;;
+    h) usage ;;
+    *) usage ;;
+  esac
+done
+
+# ── prerequisites ───────────────────────────────────────────────────────────
+command -v git >/dev/null 2>&1 || die "git is required but not installed"
+git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not inside a git repository"
+
+# ── determine range ─────────────────────────────────────────────────────────
+if [[ -z "$FROM_TAG" ]]; then
+  FROM_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
+  if [[ -z "$FROM_TAG" ]]; then
+    # No tags exist — use the first commit
+    FROM_TAG=$(git rev-list --max-parents=0 HEAD)
+    echo "ℹ️  No tags found — using first commit as baseline"
+  fi
+fi
+
+RANGE="${FROM_TAG}..HEAD"
+
+# Verify the range has commits
+COMMIT_COUNT=$(git rev-list --count "$RANGE" 2>/dev/null || echo 0)
+if [[ "$COMMIT_COUNT" -eq 0 ]]; then
+  echo "ℹ️  No new commits since $FROM_TAG — writing empty changelog"
+fi
+
+# ── collect commits ─────────────────────────────────────────────────────────
+# Format: hash | author | date | subject
+COMMITS=$(git log "$RANGE" --pretty=format:"%h|%an|%ad|%s" --date=short 2>/dev/null || true)
+
+# ── categorize ──────────────────────────────────────────────────────────────
+declare -A CATEGORIES
+CATEGORIES=(
+  ["Added"]=""
+  ["Fixed"]=""
+  ["Changed"]=""
+  ["Removed"]=""
+)
+
+while IFS='|' read -r hash author date subject; do
+  [[ -z "$subject" ]] && continue
+
+  # Normalize subject for matching
+  lower_sub=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
+
+  if   [[ "$lower_sub" =~ ^(add|feat|new|introduce|implement|create) ]]; then
+    CATEGORIES["Added"]+="  - ${subject} (${hash}, ${author}, ${date})\n"
+  elif [[ "$lower_sub" =~ ^(fix|bug|patch|resolve|correct|repair) ]]; then
+    CATEGORIES["Fixed"]+="  - ${subject} (${hash}, ${author}, ${date})\n"
+  elif [[ "$lower_sub" =~ ^(remove|drop|delete|deprecate|retire) ]]; then
+    CATEGORIES["Removed"]+="  - ${subject} (${hash}, ${author}, ${date})\n"
+  else
+    CATEGORIES["Changed"]+="  - ${subject} (${hash}, ${author}, ${date})\n"
+  fi
+done <<< "$COMMITS"
+
+# ── generate output ─────────────────────────────────────────────────────────
+{
+  if $INCLUDE_HEADER; then
+    VERSION="${FROM_TAG#v}"
+    DATE=$(date +%Y-%m-%d)
+    echo "# Changelog"
+    echo ""
+    echo "## [${VERSION}] — ${DATE}"
+    echo ""
+  else
+    echo "# Changelog"
+    echo ""
+  fi
+
+  echo "> Auto-generated from ${FROM_TAG}..HEAD — $(date +%Y-%m-%d)"
+  echo ""
+
+  for category in Added Fixed Changed Removed; do
+    entries="${CATEGORIES[$category]}"
+    if [[ -n "$entries" ]]; then
+      echo "### ${category}"
+      echo ""
+      echo -e "$entries"
+      echo ""
+    fi
+  done
+
+  # Fallback if nothing matched
+  if [[ -z "${CATEGORIES[Added]}${CATEGORIES[Fixed]}${CATEGORIES[Changed]}${CATEGORIES[Removed]}" ]]; then
+    echo "### Changed"
+    echo ""
+    while IFS='|' read -r hash author date subject; do
+      [[ -z "$subject" ]] && continue
+      echo "  - ${subject