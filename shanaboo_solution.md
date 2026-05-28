```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,3 @@
+#!/usr/bin/env bash
+set -euo pipefail
+exec bash "$(dirname "$0")/generate-changelog.sh" "$@"
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,163 @@
+#!/usr/bin/env bash
+#
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage:
+#   ./generate-changelog.sh [output_file]
+#
+# Categories (based on conventional commit prefixes):
+#   - Added:     feat, add, introduce
+#   - Fixed:     fix, bugfix, hotfix
+#   - Changed:   refactor, perf, update, improve, style, chore(deps)
+#   - Removed:   remove, delete, revert, deprecate
+#
+
+set -euo pipefail
+
+# Configuration
+OUTPUT_FILE="${1:-CHANGELOG.md}"
+TEMP_FILE=$(mktemp)
+trap 'rm -f "$TEMP_FILE"' EXIT
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+log_info() {
+    echo -e "${GREEN}[INFO]${NC} $1"
+}
+
+log_warn() {
+    echo -e "${YELLOW}[WARN]${NC} $1"
+}
+
+log_error() {
+    echo -e "${RED}[ERROR]${NC} $1"
+}
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    log_error "Not a git repository. Please run this script from within a git repo."
+    exit 1
+fi
+
+# Get the latest tag
+LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+
+if [ -z "$LATEST_TAG" ]; then
+    log_warn "No tags found. Using all commits in the repository."
+    COMMIT_RANGE=""
+else
+    log_info "Latest tag found: $LATEST_TAG"
+    COMMIT_RANGE="${LATEST_TAG}..HEAD"
+fi
+
+# Get commits since the last tag (or all commits if no tag)
+# Format: hash|subject|author|date
+if [ -z "$COMMIT_RANGE" ]; then
+    COMMITS=$(git log --pretty=format:"%h|%s|%an|%ad" --date=short)
+else
+    COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%h|%s|%an|%ad" --date=short)
+fi
+
+if [ -z "$COMMITS" ]; then
+    log_warn "No commits found since the last tag."
+    exit 0
+fi
+
+# Categorize commits
+declare -a ADDED=()
+declare -a FIXED=()
+declare -a CHANGED=()
+declare -a REMOVED=()
+
+while IFS= read -r line; do
+    # Parse commit fields
+    HASH=$(echo "$line" | cut -d'|' -f1)
+    SUBJECT=$(echo "$line" | cut -d'|' -f2)
+    AUTHOR=$(echo "$line" | cut -d'|' -f3)
+    DATE=$(echo "$line" | cut -d'|' -f4)
+
+    # Clean up the subject (remove conventional commit prefix for display)
+    CLEAN_SUBJECT="$SUBJECT"
+
+    # Categorize based on conventional commit prefixes
+    if echo "$SUBJECT" | grep -qiE '^(feat|add|introduce)(\([^)]*\))?:'; then
+        ADDED+=("- $CLEAN_SUBJECT ([\`$HASH\`]($(git remote get-url origin 2>/dev/null | sed 's/\.git$//' || echo '#'))/commit/$HASH))")
+    elif echo "$SUBJECT" | grep -qiE '^(fix|bugfix|hotfix)(\([^)]*\))?:'; then
+        FIXED+=("- $CLEAN_SUBJECT ([\`$HASH\`]($(git remote get-url origin 2>/dev/null | sed 's/\.git$//' || echo '#'))/commit/$HASH))")
+    elif echo "$SUBJECT" | grep -qiE '^(refactor|perf|update|improve|style|chore\(deps\))(\([^)]*\))?:'; then
+        CHANGED+=("- $CLEAN_SUBJECT ([\`$HASH\`]($(git remote get-url origin 2>/dev/null | sed 's/\.git$//' || echo '#'))/commit/$HASH))")
+    elif echo "$SUBJECT" | grep -qiE '^(remove|delete|revert|deprecate)(\([^)]*\))?:'; then
+        REMOVED+=("- $CLEAN_SUBJECT ([\`$HASH\`]($(git remote get-url origin 2>/dev/null | sed 's/\.git$//' || echo '#'))/commit/$HASH))")
+    else
+        # Default to Changed for uncategorized commits
+        CHANGED+=("- $CLEAN_SUBJECT ([\`$HASH\`]($(git remote get-url origin 2>/dev/null | sed 's/\.git$//' || echo '#'))/commit/$HASH))")
+    fi
+done <<< "$COMMITS"
+
+# Generate the CHANGELOG
+{
+    echo "# Changelog"
+    echo ""
+    echo "All notable changes to this project will be documented in this file."
+    echo ""
+    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
+    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
+    echo ""
+    echo "## [Unreleased] ($(date +%Y-%m-%d))"
+    echo ""
+
+    if [ ${#ADDED[@]} -gt 0 ]; then
+        echo "### Added"
+        printf '%s\n' "${ADDED[@]}"
+        echo ""
+    fi
+
+    if [ ${#FIXED[@]} -gt 0 ]; then
+        echo "### Fixed"
+        printf '%s\n' "${FIXED[@]}"
+        echo ""
+    fi
+
+    if [ ${#CHANGED[@]} -gt 0 ]; then
+        echo "### Changed"
+        printf '%s\n' "${CHANGED[@]}"
+        echo ""
+    fi
+
+   