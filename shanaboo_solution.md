 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,131 @@
+#!/usr/bin/env bash
+#
+# changelog.sh - Generate a structured CHANGELOG.md from git history
+#
+# Usage: bash changelog.sh
+#
+# Fetches commits since the last git tag, auto-categorizes them,
+# and outputs a properly formatted CHANGELOG.md.
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
+CHANGELOG_FILE="CHANGELOG.md"
+DATE_FORMAT="%Y-%m-%d"
+
+# Get the latest tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag)
+get_commits() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+# Categorize a commit message into a type
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
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    # Check for keywords in the message body
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|eliminate)\b'; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Clean commit message for changelog
+clean_message() {
+    local msg="$1"
+    # Remove conventional commit prefix (e.g., "feat:", "fix:", "chore:")
+    echo "$msg" | sed -E 's/^[a-z]+(\([^)]*\))?:[[:space:]]*//' | sed -E 's/^[[:space:]]*//'
+}
+
+# Generate the changelog
+generate_changelog() {
+    local tag
+    tag=$(get_latest_tag)
+    
+    echo -e "${YELLOW}Generating changelog...${NC}"
+    
+    if [ -n "$tag" ]; then
+        echo -e "${GREEN}Found latest tag: $tag${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
+    fi
+    
+    local commits
+    commits=$(get_commits "$tag")
+    
+    if [ -z "$commits" ]; then
+        echo -e "${RED}No commits found since last tag.${NC}"
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
+        local clean_msg
+        clean_msg=$(clean_message "$commit")
+        
+        case "$category" in
+            added) added+=("$clean_msg") ;;
+            fixed) fixed+=("$clean_msg") ;;
+            removed) removed+=("$clean_msg") ;;
+            changed) changed+=("$clean_msg") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate the changelog content
+    local version_date
+    version_date=$(date +"$DATE_FORMAT")
+    
+    local version_label
+    if [ -n "$tag" ]; then
+        version_label="$tag"
+    else
+        version_label="Unreleased"
+    fi
+    
+    # Build changelog
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [$version_label] - $version_date"
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
+    } > "$CHANGELOG_FILE"
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
+    echo -e "${GREEN}Location: $(pwd)/$CHANGELOG_FILE${NC}"
+}
+
+# Main execution
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 