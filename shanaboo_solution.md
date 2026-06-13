 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,3 @@
+#!/bin/bash
+# Wrapper script for the changelog generator
+exec bash "$(dirname "$0")/changelog.sh" "$@"
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,169 @@
+#!/bin/bash
+
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+# Configuration
+OUTPUT_FILE="${1:-CHANGELOG.md}"
+TEMP_FILE=$(mktemp)
+trap 'rm -f "$TEMP_FILE"' EXIT
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
+        git log "$tag..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
+    fi
+}
+
+# Get the date of the latest tag
+get_tag_date() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1 || echo ""
+    else
+        echo ""
+    fi
+}
+
+# Categorize a commit message
+categorize_commit() {
+    local message="$1"
+    local lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    # Check for keywords in the message
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|eliminate|deprecate)\b'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework)\b'; then
+        echo "changed"
+    else
+        # Default to changed for uncategorized commits
+        echo "changed"
+    fi
+}
+
+# Format a commit message for changelog (remove conventional commit prefix)
+format_commit_message() {
+    local message="$1"
+    # Remove conventional commit prefixes like "feat:", "fix:", etc.
+    echo "$message" | sed -E 's/^[a-z]+(\([^)]*\))?:\s*//'
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
+    LATEST_TAG=$(get_latest_tag)
+    
+    if [ -n "$LATEST_TAG" ]; then
+        echo -e "${GREEN}Generating changelog since tag: $LATEST_TAG${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
+    fi
+
+    # Get commits
+    COMMITS=$(get_commits_since_tag "$LATEST_TAG")
+    
+    if [ -z "$COMMITS" ]; then
+        echo -e "${YELLOW}No commits found since the last tag.${NC}"
+        exit 0
+    fi
+
+    # Initialize category arrays
+    declare -a ADDED=()
+    declare -a FIXED=()
+    declare -a CHANGED=()
+    declare -a REMOVED=()
+
+    # Process each commit
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category=$(categorize_commit "$commit")
+        local formatted=$(format_commit_message "$commit")
+        
+        case "$category" in
+            added)   ADDED+=("$formatted") ;;
+            fixed)   FIXED+=("$formatted") ;;
+            changed) CHANGED+=("$formatted") ;;
+            removed) REMOVED+=("$formatted") ;;
+        esac
+    done <<< "$COMMITS"
+
+    # Generate the changelog
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        
+        # Determine version and date
+        local version_date=$(date +%Y-%m-%d)
+        local version_name="$LATEST_TAG"
+        [ -z "$version_name" ] && version_name="Unreleased"
+        
+        echo "## [$version_name] - $version_date"
+        echo ""
+        
+        # Added
+        if [ ${#ADDED[@]} -gt 0 ]; then
+            echo "### Added"
+            for item in "${ADDED[@]}"; do
+                echo "- $item"
+            done
