 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,155 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+# Usage: bash changelog.sh
+
+REPO_URL=""
+OUTPUT_FILE="CHANGELOG.md"
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
+    fi
+}
+
+# Get the date of the latest tag or use current date
+get_tag_date() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log -1 --format=%ai "${tag}" 2>/dev/null | cut -d' ' -f1 || date +%Y-%m-%d
+    else
+        date +%Y-%m-%d
+    fi
+}
+
+# Categorize a commit message
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    else
+        # Fallback: keyword-based detection
+        if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new|support|enable)\b'; then
+            echo "added"
+        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|correct|repair|patch)\b'; then
+            echo "fixed"
+        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|deprecate)\b'; then
+            echo "removed"
+        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked)\b'; then
+            echo "changed"
+        else
+            # Default to changed if no match
+            echo "changed"
+        fi
+    fi
+}
+
+# Clean commit message for changelog
+clean_message() {
+    local msg="$1"
+    # Remove conventional commit prefix
+    echo "$msg" | sed -E 's/^[a-z]+(\([^)]*\))?!?:\s*//i' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+
+    local since_tag=""
+    if [ -n "$latest_tag" ]; then
+        since_tag="$latest_tag"
+    fi
+
+    local tag_date
+    tag_date=$(get_tag_date "$latest_tag")
+
+    # Collect commits by category
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+
+        local category
+        category=$(categorize_commit "$commit")
+        local clean_msg
+        clean_msg=$(clean_message "$commit")
+
+        case "$category" in
+            added) added+=("$clean_msg") ;;
+            fixed) fixed+=("$clean_msg") ;;
+            changed) changed+=("$clean_msg") ;;
+            removed) removed+=("$clean_msg") ;;
+        esac
+    done < <(get_commits_since_tag "$since_tag")
+
+    # Generate output
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [Unreleased] - ${tag_date}"
+        echo ""
+
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            printf '%s\n' "${added[@]}" | sed 's/^/- /'
+            echo ""
+        fi
+
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            printf '%s\n' "${changed[@]}" | sed 's/^/- /'
+            echo ""
+        fi
+
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            printf '%s\n' "${fixed[@]}" | sed 's/^/- /'
+            echo ""
+        fi
+
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            printf '%s\n' "${removed[@]}" | sed 's/^/- /'
+            echo ""
+        fi
+    } > "$OUTPUT_FILE"
+
+    echo "✅ Generated $OUTPUT_FILE"
+    if [ -n "$since_tag" ]; then
+        echo "   Commits since tag: $since_tag"
+    else
+        echo "   No previous tag found — included all commits"
+    fi
+    echo "   Added:   ${#added[@]}"
+    echo "   Changed: ${#changed[@]}"
+    echo "   Fixed:   ${#fixed[@]}"
+    echo "   Removed: ${#removed[@]}"
+}
+
+# Main
+main() {
+    if ! git rev