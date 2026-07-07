 ```diff
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,121 @@
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

+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag)
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
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    # Check for keywords in message body
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|patch|resolve|resolved)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert)\b'; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Generate the CHANGELOG.md content
+generate_changelog() {
+    local tag="$1"
+    local commits="$2"
+    local version_date
+    version_date=$(date +%Y-%m-%d)
+
+    # Determine version string
+    local version
+    if [ -n "$tag" ]; then
+        version="$tag"
+    else
+        version="unreleased"
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
+            removed) removed+=("$commit") ;;
+            changed) changed+=("$commit") ;;
+        esac
+    done <<< "$commits"
+
+    # Output CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [$version] - $version_date"
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
+    }
+}
+
+# Main execution
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository.${NC}" >&2
+        exit 1
+    fi
+
+    # Get the latest tag
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+
+    if [ -n "$latest_tag" ]; then
+        echo -e "${GREEN}Found latest tag: $latest_tag${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
+    fi
+
+    # Get commits since tag
+    local commits
+    commits=$(get_commits_since_tag "$latest_tag")
+
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found since last tag.${NC}"
+        # Still generate a changelog with empty sections
+        commits=""
+    fi
+
+    # Generate and write CHANGELOG.md
+    generate_changelog "$latest_tag" "$commits" > CHANGELOG.md
+
+    echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
+    echo ""
+    echo "Preview:"
+    echo "--------"
+    head -50 CHANGELOG.md
+}
+
+main "$@"
+
+--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,47 @@
+# Generate Changelog Skill