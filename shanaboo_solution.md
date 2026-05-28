```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,131 @@
+#!/usr/bin/env bash
+
+# changelog.sh - Generate a structured CHANGELOG.md from git history
+# Usage: bash changelog.sh
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+# Get the last git tag
+get_last_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
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
+    if echo "$lower_msg" | grep -qE '^(feat|add|create|introduce|implement)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|deprecate)'; then
+        echo "changed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
+        echo "removed"
+    # Check for keywords in the message
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|new|create|introduce|implement|feature)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|solved|patch)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(change|changed|changing|update|updated|updating|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|deprecate|deprecated)\b'; then
+        echo "changed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted)\b'; then
+        echo "removed"
+    else
+        echo "changed"  # Default category
+    fi
+}
+
+# Generate the CHANGELOG.md
+generate_changelog() {
+    local tag
+    tag=$(get_last_tag)
+    
+    local commits
+    if [ -n "$tag" ]; then
+        commits=$(get_commits_since_tag "$tag")
+        echo -e "${GREEN}Generating changelog since tag: $tag${NC}"
+    else
+        commits=$(get_commits_since_tag "")
+        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
+    fi
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
+    # Categorize each commit
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        case "$category" in
+            added) added+=("$commit") ;;
+            fixed) fixed+=("$commit") ;;
+            changed) changed+=("$commit") ;;
+            removed) removed+=("$commit") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate the changelog
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [Unreleased] - $(date +%Y-%m-%d)"
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
+        echo "---"
+        echo ""
+        echo "*Generated automatically by changelog.sh*"
+    } > CHANGELOG.md
+    
+    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
+}
+
+# Main execution
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository.${NC}"
+        exit 1
+    fi
+    
+    generate_changelog
+}
+
+main "$@"
--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,50 @@
+# Generate Changelog Skill
+
+## Description
+
+Automatically generate a structured `CHANGELOG.md` from a project's git history.
+
+## Setup
+
+1. Save `changelog.sh` to your