 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,3 @@
+#!/bin/bash
+# Wrapper script for the changelog generator
+exec bash "$(dirname "$0")/generate-changelog.sh" "$@"
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,169 @@
+#!/bin/bash
+#
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage:
+#   bash generate-changelog.sh
+#   ./generate-changelog.sh
+#
+# The script will:
+# 1. Find the latest git tag
+# 2. Collect commits since that tag
+# 3. Categorize commits into Added / Fixed / Changed / Removed
+# 4. Generate or update CHANGELOG.md
+#
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+BLUE='\033[0;34m'
+NC='\033[0m' # No Color
+
+# Configuration
+CHANGELOG_FILE="CHANGELOG.md"
+DATE_FORMAT="%Y-%m-%d"
+
+# Function to print colored messages
+print_info() {
+    echo -e "${BLUE}ℹ️  $1${NC}"
+}
+
+print_success() {
+    echo -e "${GREEN}✅ $1${NC}"
+}
+
+print_warning() {
+    echo -e "${YELLOW}⚠️  $1${NC}"
+}
+
+print_error() {
+    echo -e "${RED}❌ $1${NC}"
+}
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    print_error "Not a git repository. Please run this script from within a git repository."
+    exit 1
+fi
+
+# Get the latest tag
+LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+
+if [ -z "$LATEST_TAG" ]; then
+    print_warning "No tags found. Using all commits in the repository."
+    COMMIT_RANGE=""
+else
+    print_info "Latest tag found: $LATEST_TAG"
+    COMMIT_RANGE="${LATEST_TAG}..HEAD"
+fi
+
+# Get commits since the last tag (or all commits if no tag)
+if [ -z "$COMMIT_RANGE" ]; then
+    COMMITS=$(git log --pretty=format:"%s" --no-merges 2>/dev/null || true)
+else
+    COMMITS=$(git log "${COMMIT_RANGE}" --pretty=format:"%s" --no-merges 2>/dev/null || true)
+fi
+
+if [ -z "$COMMITS" ]; then
+    print_warning "No commits found since the last tag."
+    exit 0
+fi
+
+# Categorize commits
+ADDED_COMMITS=""
+FIXED_COMMITS=""
+CHANGED_COMMITS=""
+REMOVED_COMMITS=""
+OTHER_COMMITS=""
+
+while IFS= read -r commit; do
+    # Skip empty lines
+    [ -z "$commit" ] && continue
+    
+    # Normalize to lowercase for matching
+    lower_commit=$(echo "$commit" | tr '[:upper:]' '[:lower:]')
+    
+    if echo "$lower_commit" | grep -qE '^(feat|feature|add|introduce|implement|create|new)'; then
+        ADDED_COMMITS="${ADDED_COMMITS}- ${commit}"$'\n'
+    elif echo "$lower_commit" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|close)'; then
+        FIXED_COMMITS="${FIXED_COMMITS}- ${commit}"$'\n'
+    elif echo "$lower_commit" | grep -qE '^(remove|delete|drop|deprecate|revert)'; then
+        REMOVED_COMMITS="${REMOVED_COMMITS}- ${commit}"$'\n'
+    elif echo "$lower_commit" | grep -qE '^(update|change|modify|refactor|improve|enhance|optimize|upgrade|rework)'; then
+        CHANGED_COMMITS="${CHANGED_COMMITS}- ${commit}"$'\n'
+    else
+        # Try to infer from keywords in the commit message
+        if echo "$lower_commit" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
+            ADDED_COMMITS="${ADDED_COMMITS}- ${commit}"$'\n'
+        elif echo "$lower_commit" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
+            FIXED_COMMITS="${FIXED_COMMITS}- ${commit}"$'\n'
+        elif echo "$lower_commit" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|deprecate|revert)\b'; then
+            REMOVED_COMMITS="${REMOVED_COMMITS}- ${commit}"$'\n'
+        elif echo "$lower_commit" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|optimize|optimized|upgrade|upgraded|rework|reworked)\b'; then
+            CHANGED_COMMITS="${CHANGED_COMMITS}- ${commit}"$'\n'
+        else
+            OTHER_COMMITS="${OTHER_COMMITS}- ${commit}"$'\n'
+        fi
+    fi
+done <<< "$COMMITS"
+
+# Generate the changelog content
+TODAY=$(date +"$DATE_FORMAT")
+VERSION=${LATEST_TAG:-"unreleased"}
+
+# Build the new changelog section
+NEW_SECTION="## [${VERSION}] - ${TODAY}"$'\n\n'
+
+if [ -n "$ADDED_COMMITS" ]; then
+    NEW_SECTION="${NEW_SECTION}### Added"$'\n\n'"${ADDED_COMMITS}"$'\n'
+fi
+
+if [ -n "$CHANGED_COMMITS" ]; then
+    NEW_SECTION="${NEW_SECTION}### Changed"$'\n\n'"${CHANGED_COMMITS}"$'\n'
+fi
+
+if [ -n "$FIXED_COMMITS" ]; then
+    NEW_SECTION="${NEW_SECTION}### Fixed"$'\n\n'"${FIXED_COMMITS}"$'\n'
+fi
+
+if [ -n "$REMOVED_COMMITS" ]; then
+