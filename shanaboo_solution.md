 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,117 @@
+#!/usr/bin/env bash
+#
+# changelog.sh - Generate a structured CHANGELOG.md from git history
+#
+# Usage: bash changelog.sh
+#       冤c /generate-changelog (when integrated as a Claude Code skill)
+#
+# Fetches commits since the last git tag and auto-categorizes them into:
+#   - Added
+#   - Fixed
+#   - Changed
+#   - Removed
+#
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || echo ""
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || echo ""
+    fi
+}
+
+# Categorize a single commit message
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes and keywords
+    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce|implement)|\b(add|adds|added|adding|create|creates|created|introduce|introduces|introduced|implement|implements|implemented)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch)|\b(fix|fixes|fixed|fixing|bug|bugs|bugfix|patch|patches|patched|resolve|resolves|resolved|close|closes|closed)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)|\b(remove|removes|removed|removing|delete|deletes|deleted|deleting|drop|drops|dropped|revert|reverts|reverted|deprecate|deprecates|deprecated)\b'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)|\b(update|updates|updated|updating|change|changes|changed|changing|modify|modifies|modified|modifying|refactor|refactored|refactoring|improve|improves|improved|improving|enhance|enhances|enhanced|enhancing|upgrade|upgrades|upgraded|upgrading|rework|reworked|reworking|optimize|optimizes|optimized|optimizing)\b'; then
+        echo "changed"
+    else
+        echo "changed"  # Default category
+    fi
+}
+
+# Generate the CHANGELOG.md content
+generate_changelog() {
+    local tag
+    tag=$(get_latest_tag)
+
+    local commits
+    commits=$(get_commits_since_tag "$tag")
+
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found since last tag.${NC}"
+        if [ -n "$tag" ]; then
+            echo "Latest tag: $tag"
+        else
+            echo "No tags found in repository."
+        fi
+        exit 0
+    fi
+
+    # Initialize category arrays
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+
+    # Process each commit
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+
+        local category
+        category=$(categorize_commit "$commit")
+
+        case "$category" in
+            added)   added+=("$commit") ;;
+            fixed)   fixed+=("$commit") ;;
+            changed) changed+=("$commit") ;;
+            removed) removed+=("$commit") ;;
+        esac
+    done <<< "$commits"
+
+    # Generate output
+    {
+        echo "# Changelog"
+        echo ""
+
+        local version_date
+        version_date=$(date +%Y-%m-%d)
+
+        if [ -n "$tag" ]; then
+            echo "## [Unreleased] - $version_date"
+        else
+            echo "## [Unreleased] - $version_date"
+        fi
+        echo ""
+
+        # Added
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            for item in "${added[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        # Changed
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            for item in "${changed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        # Fixed
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            for item in "${fixed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        # Removed
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            for item in "${removed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        # Append existing changelog content if it exists (preserve history)
+        if [ -f CHANGELOG.md ]; then
+            # Extract content after the first header to preserve old entries
+            tail -n +3 CHANGELOG.md 2>/dev/null | grep -v "^# Changelog" || true
+        fi
+    } > CHANGELOG.md.new
+
+    mv CHANGELOG.md.new CHANGELOG.md
+
+    echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
+    if [ -n "$tag" ]; then
+        echo "Commits since tag: $tag"
+   