 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+set -euo pipefail
+exec "$(dirname "$0")/changelog.sh" "$@"
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,163 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# Automatically generates a structured CHANGELOG.md from git history.
+#
+# Usage:
+#   bash changelog.sh              # Generate CHANGELOG.md
+#   bash changelog.sh --dry-run    # Preview without writing
+#   bash changelog.sh --since-tag  # Use specific tag instead of latest
+#
+
+set -euo pipefail
+
+# ── Configuration ───────────────────────────────────────────────────────────
+
+OUTPUT_FILE="CHANGELOG.md"
+DRY_RUN=false
+CUSTOM_TAG=""
+
+# ── Parse arguments ─────────────────────────────────────────────────────────
+
+while [[ $# -gt 0 ]]; do
+    case "$1" in
+        --dry-run)
+            DRY_RUN=true
+            shift
+            ;;
+        --since-tag)
+            CUSTOM_TAG="$2"
+            shift 2
+            ;;
+        --help|-h)
+            echo "Usage: bash changelog.sh [--dry-run] [--since-tag <tag>]"
+            exit 0
+            ;;
+        *)
+            echo "Unknown option: $1" >&2
+            exit 1
+            ;;
+    esac
+done
+
+# ── Helpers ─────────────────────────────────────────────────────────────────
+
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+get_commits_since_tag() {
+    local tag="$1"
+    if [[ -n "$tag" ]]; then
+        git log "$tag"..HEAD --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+get_commit_date() {
+    local tag="$1"
+    if [[ -n "$tag" ]]; then
+        git log -1 --format="%ad" --date=short "$tag" 2>/dev/null || date +%Y-%m-%d
+    else
+        date +%Y-%m-%d
+    fi
+}
+
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes first
+    if [[ "$lower_msg" =~ ^(feat|add|introduce|implement|create|new): ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve|correct): ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|deprecate): ]]; then
+        echo "removed"
+    elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework): ]]; then
+        echo "changed"
+    # Fallback to keyword matching
+    elif [[ "$lower_msg" =~ (fix|bug|patch|resolve|correct|repair) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ (add|introduce|implement|create|new|feature|support) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ (remove|delete|drop|revert|deprecate|eliminate) ]]; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+format_commit() {
+    local msg="$1"
+    # Strip conventional commit prefix for cleaner output
+    local clean_msg
+    clean_msg=$(echo "$msg" | sed -E 's/^[a-z]+(\([^)]*\))?:\s*//i')
+    echo "- ${clean_msg}"
+}
+
+# ── Main ────────────────────────────────────────────────────────────────────
+
+# Verify we're in a git repo
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    echo "Error: Not a git repository." >&2
+    exit 1
+fi
+
+LATEST_TAG="${CUSTOM_TAG:-$(get_latest_tag)}"
+COMMITS=$(get_commits_since_tag "$LATEST_TAG")
+
+if [[ -z "$COMMITS" ]]; then
+    echo "No commits found since ${LATEST_TAG:-'repository start'}."
+    exit 0
+fi
+
+# Categorize commits
+ADDED=$(echo "$COMMITS" | while IFS= read -r line; do [[ "$(categorize_commit "$line")" == "added" ]] && format_commit "$line"; done)
+FIXED=$(echo "$COMMITS" | while IFS= read -r line; do [[ "$(categorize_commit "$line")" == "fixed" ]] && format_commit "$line"; done)
+CHANGED=$(echo "$COMMITS" | while IFS= read -r line; do [[ "$(categorize_commit "$line")" == "changed" ]] && format_commit "$line"; done)
+REMOVED=$(echo "$COMMITS" | while IFS= read -r line; do [[ "$(categorize_commit "$line")" == "removed" ]] && format_commit "$line"; done)
+
+# Build changelog content
+CHANGELOG="# Changelog\n\n"
+CHANGELOG+="## [Unreleased] - $(date +%Y-%m-%d)\n\n"
+
+if [[ -n "$LATEST_TAG" ]]; then
+    CHANGELOG+="> Changes since tag: \`$LATEST_TAG\`\n\n"
+fi
+
+if [[ -n "$ADDED" ]]; then
+    CHANGELOG+="### Added\n\n$ADDED\n\n"
+fi
+
+if [[ -n "$FIXED" ]]; then
+    CHANGELOG+="### Fixed\n\n$FIXED\n\n"
+fi
+
+if [[ -n "$CHANGED" ]]; then
+    CHANGELOG+="### Changed\n\n$CHANGED\n\n"
+fi
+
+if [[ -n "$REMOVED" ]]; then
+    CHANGELOG+="### Removed\n\n$REMOVED\n\n"
+fi
+
+# Output
+if $DRY_RUN; then
+    echo -e "$CHANGELOG"
+else
+    echo -e "$CHANGELOG" > "$OUTPUT_FILE"
+    echo "✅ CHANGELOG.md generated successfully."
+    if [[ -n "$LATEST_TAG" ]]; then
+        echo "   Based on commits since tag: