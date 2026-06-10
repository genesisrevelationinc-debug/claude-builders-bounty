 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,141 @@
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
+# Get commits since the last tag (or all commits if no tag)
+get_commits() {
+    local last_tag="$1"
+    if [ -n "$last_tag" ]; then
+        git log "$last_tag"..HEAD --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+# Categorize a single commit
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement)'; then
+        echo "added"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch)'; then
+        echo "fixed"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
+        echo "removed"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|bump)'; then
+        echo "changed"
+        return
+    fi
+    
+    # Keyword-based categorization
+    if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new|support|enable)\b'; then
+        echo "added"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch|correct|repair)\b'; then
+        echo "fixed"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted|deprecate|deprecated)\b'; then
+        echo "removed"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|bump|bumped|optimize|optimized|restructure|restructured)\b'; then
+        echo "changed"
+        return
+    fi
+    
+    # Default to changed
+    echo "changed"
+}
+
+# Generate the changelog
+generate_changelog() {
+    local last_tag
+    last_tag=$(get_last_tag)
+    
+    local commits
+    commits=$(get_commits "$last_tag")
+    
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found since last tag.${NC}"
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
+        # Clean up commit message (remove conventional commit prefix)
+        local clean_msg
+        clean_msg=$(echo "$commit" | sed -E 's/^[a-z]+(\([a-z]+\))?:\s*//i')
+        
+        case "$category" in
+            added) added+=("$clean_msg") ;;
+            fixed) fixed+=("$clean_msg") ;;
+            changed) changed+=("$clean_msg") ;;
+            removed) removed+=("$clean_msg") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate output
+    {
+        echo "# Changelog"
+        echo ""
+        
+        if [ -n "$last_tag" ]; then
+            echo "## Changes since $last_tag"
+        else
+            echo "## All Changes"
+        fi
+        echo ""
+        
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            echo ""
+            for item in "${added[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            echo ""
+            for item in "${fixed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            echo ""
+            for item in "${changed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            echo ""
+            for item in "${removed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+    } > CHANGELOG.md
+    
+    echo -e "${GREEN}CHANGELOG.md generated successfully!${NC}"
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
+    generate_changelog
+}
+
+main "$@"
--- /dev/null
+++ SKILL.md
@@ -0,0 +1,