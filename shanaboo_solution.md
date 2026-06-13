 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,145 @@
+#!/usr/bin/env bash
+#
+# changelog.sh - Generate a structured CHANGELOG.md from git history
+#
+# Usage: bash changelog.sh
+#        ./changelog.sh
+#
+# This script fetches commits since the last git tag and auto-categorizes
+# them into: Added / Fixed / Changed / Removed
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
+        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
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
+# Categorize a commit message
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|upgrade|deps)'; then
+        echo "changed"
+    # Check for keywords in the message
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|feat|feature|implement|introduce|create)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|patch|correct)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|revert)\b'; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Main function
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository${NC}" >&2
+        exit 1
+    fi
+    
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    local since_text
+    if [ -n "$latest_tag" ]; then
+        since_text="since $latest_tag"
+        echo -e "${GREEN}Generating changelog for commits since $latest_tag...${NC}"
+    else
+        since_text="(all commits)"
+        echo -e "${YELLOW}No tags found. Generating changelog for all commits...${NC}"
+    fi
+    
+    # Get commits
+    local commits
+    commits=$(get_commits_since_tag "$latest_tag")
+    
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found $since_text${NC}"
+        exit 0
+    fi
+    
+    # Generate changelog
+    local version_date
+    version_date=$(date +%Y-%m-%d)
+    
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [Unreleased] - $version_date"
+        echo ""
+        
+        # Process and categorize commits
+        local added_commits fixed_commits changed_commits removed_commits
+        added_commits=$(echo "$commits" | while IFS= read -r line; do [ -n "$line" ] && [ "$(categorize_commit "$line")" = "added" ] && echo "- $line"; done)
+        fixed_commits=$(echo "$commits" | while IFS= read -r line; do [ -n "$line" ] && [ "$(categorize_commit "$line")" = "fixed" ] && echo "- $line"; done)
+        changed_commits=$(echo "$commits" | while IFS= read -r line; do [ -n "$line" ] && [ "$(categorize_commit "$line")" = "changed" ] && echo "- $line"; done)
+        removed_commits=$(echo "$commits" | while IFS= read -r line; do [ -n "$line" ] && [ "$(categorize_commit "$line")" = "removed" ] && echo "- $line"; done)
+        
+        # Output categorized sections
+        [ -n "$added_commits" ] && echo "### Added" && echo "$added_commits" && echo ""
+        [ -n "$changed_commits" ] && echo "### Changed" && echo "$changed_commits" && echo ""
+        [ -n "$fixed_commits" ] && echo "### Fixed" && echo "$fixed_commits" && echo ""
+        [ -n "$removed_commits" ] && echo "### Removed" && echo "$removed_commits" && echo ""
+        
+    } > CHANGELOG.md
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
+}
+
+main "$@"
+
--- /dev/null
+++	SKILL.md
@@ -0,0 +1,45 @@
+# Generate Changelog Skill
+
+A Claude Code skill to automatically generate a structured `CHANGELOG.md` from git history.
+
+## Installation
+
+1.