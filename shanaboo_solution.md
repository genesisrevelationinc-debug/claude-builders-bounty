 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,130 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+# Usage: bash changelog.sh
+
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"
+
+# Get the latest git tag, or empty if no tags exist
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || true
+}
+
+# Get commits since the last tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag
+    tag=$(get_latest_tag)
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
+    fi
+}
+
+# Get the date of the latest tag or use today's date
+get_release_date() {
+    local tag
+    tag=$(get_latest_tag)
+    if [ -n "$tag" ]; then
+        git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1 || date +%Y-%m-%d
+    else
+        date +%Y-%m-%d
+    fi
+}
+
+# Categorize a commit message into a changelog category
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
+        echo "Added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
+        echo "Fixed"
+    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|optimize)'; then
+        echo "Changed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|deprecate|revert)'; then
+        echo "Removed"
+    # Check for keywords in the message body
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
+        echo "Added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|correct|patch)\b'; then
+        echo "Fixed"
+    elif echo "$lower_msg" | grep -qE '\b(change|changed|changing|update|updated|updating|modify|modified|refactor|improve|improved|enhance|enhanced|upgrade|upgraded|optimize|optimized)\b'; then
+        echo "Changed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|deprecate|deprecated|revert|reverted)\b'; then
+        echo "Removed"
+    else
+        echo "Changed"  # Default category
+    fi
+}
+
+# Clean commit message for changelog (remove conventional commit prefix)
+clean_message() {
+    local msg="$1"
+    # Remove conventional commit prefixes like feat:, fix:, chore:, etc.
+    echo "$msg" | sed -E 's/^[a-z]+(\([^)]*\))?:[[:space:]]*//'
+}
+
+# Generate the changelog
+generate_changelog() {
+    local commits
+    local release_date
+    local latest_tag
+    local version
+
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo "Error: Not a git repository." >&2
+        exit 1
+    fi
+
+    commits=$(get_commits_since_tag)
+
+    if [ -z "$commits" ]; then
+        echo "No commits found since last tag." >&2
+        exit 0
+    fi
+
+    release_date=$(get_release_date)
+    latest_tag=$(get_latest_tag)
+    version="${latest_tag:-$(git rev-parse --short HEAD)}"
+
+    # Initialize category arrays
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+
+    # Process each commit
+    while IFS= read -r commit_msg; do
+        [ -z "$commit_msg" ] && continue
+
+        local category
+        local clean_msg
+        category=$(categorize_commit "$commit_msg")
+        clean_msg=$(clean_message "$commit_msg")
+
+        # Capitalize first letter
+        clean_msg="$(echo "$clean_msg" | sed 's/^[a-z]/\u&/')"
+
+        case "$category" in
+            Added)  added+=("$clean_msg") ;;
+            Fixed)  fixed+=("$clean_msg") ;;
+            Changed) changed+=("$clean_msg") ;;
+            Removed) removed+=("$clean_msg") ;;
+        esac
+    done <<< "$commits"
+
+    # Generate the CHANGELOG.md content
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [Unreleased] — $release_date"
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
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            for item in "${fixed[@]}"; do
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
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            for item in "${removed[@]}"; do
+                echo "- $item"
+           