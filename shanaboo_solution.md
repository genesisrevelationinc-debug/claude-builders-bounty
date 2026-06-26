 ```diff
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,175 @@
+#!/usr/bin/env bash
+#
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage: bash generate-changelog.sh
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+# Get the directory where the script is located
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || echo ""
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || echo ""
+    fi
+}
+
+# Get the date of the latest tag (or current date if no tag)
+get_tag_date() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1 || date +%Y-%m-%d
+    else
+        date +%Y-%m-%d
+    fi
+}
+
+# Categorize a commit message into one of the standard categories
+categorize_commit() {
+    local message="$1"
+    local lower_msg
+    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
+
+    # Added: feat, add, create, implement, introduce, new
+    if echo "$lower_msg" | grep -qE '^(feat|add|create|implement|introduce|new)'; then
+        echo "Added"
+        return
+    fi
+
+    # Fixed: fix, bugfix, hotfix, repair, resolve, correct, patch
+    if echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|repair|resolve|correct|patch)'; then
+        echo "Fixed"
+        return
+    fi
+
+    # Removed: remove, delete, drop, clean, revert
+    if echo "$lower_msg" | grep -qE '^(remove|delete|drop|clean|revert)'; then
+        echo "Removed"
+        return
+    fi
+
+    # Changed: update, change, modify, refactor, improve, enhance, upgrade, rename, move
+    if echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rename|move|style|perf|chore)'; then
+        echo "Changed"
+        return
+    fi
+
+    # Default to Changed for anything else
+    echo "Changed"
+}
+
+# Clean up commit message for changelog (remove conventional commit prefix)
+clean_message() {
+    local message="$1"
+    # Remove conventional commit prefixes like "feat:", "fix:", "chore:", etc.
+    echo "$message" | sed -E 's/^[a-z]+(\([^)]*\))?:[[:space:]]*//'
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+
+    local commits
+    commits=$(get_commits_since_tag "$latest_tag")
+
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found since the last tag.${NC}"
+        echo "Generating empty changelog template..."
+    fi
+
+    local tag_date
+    tag_date=$(get_tag_date "$latest_tag")
+
+    local version="unreleased"
+    if [ -n "$latest_tag" ]; then
+        version="$latest_tag"
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
+        local clean_msg
+        clean_msg=$(clean_message "$commit")
+
+        case "$category" in
+            "Added") added+=("$clean_msg") ;;
+            "Fixed") fixed+=("$clean_msg") ;;
+            "Changed") changed+=("$clean_msg") ;;
+            "Removed") removed+=("$clean_msg") ;;
+        esac
+    done <<< "$commits"
+
+    # Generate the CHANGELOG.md content
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [${version}] - ${tag_date}"
+        echo ""
+
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            for item in "${added[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            for item in "${changed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            for item in "${fixed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            for item in "${removed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+
+        echo "---"
+        echo ""
+        echo "*Generated automatically by [generate-changelog.sh](generate-changelog.sh)*"
+    } > "$CHANGELOG_FILE"
+
+    echo -e "${GREEN}✅ CHANGELOG.md generated successfully at:${NC} $CHANGELOG_FILE"
