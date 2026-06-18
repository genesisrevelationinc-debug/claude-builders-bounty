 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,135 @@
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
+# Configuration
+OUTPUT_FILE="CHANGELOG.md"
+DATE_FORMAT="%Y-%m-%d"
+
+# Get the latest tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
+    fi
+}
+
+# Categorize a commit message
+categorize_commit() {
+    local message="$1"
+    local lower_msg
+    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|new|introduce)'; then
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
+    if echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade)'; then
+        echo "changed"
+        return
+    fi
+    
+    # Fallback: keyword matching
+    if echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|introduces|feature)\b'; then
+        echo "added"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '\b(fix|fixed|fixes|fixing|bug|resolve|resolves|patch)\b'; then
+        echo "fixed"
+        return
+    fi
+    
+    if echo "$lower_msg" | grep -qE '\b(remove|removed|removes|removing|delete|deleted|deletes|drop|dropped|revert|reverts)\b'; then
+        echo "removed"
+        return
+    fi
+    
+    # Default to changed
+    echo "changed"
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    local version_info
+    if [ -n "$latest_tag" ]; then
+        version_info="since ${latest_tag}"
+    else
+        version_info="(all commits)"
+    fi
+    
+    echo -e "${GREEN}Generating CHANGELOG.md ${version_info}...${NC}"
+    
+    local commits
+    commits=$(get_commits_since "$latest_tag")
+    
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found ${version_info}.${NC}"
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
+        # Clean up the commit message (remove conventional commit prefix)
+        local clean_msg
+        clean_msg=$(echo "$commit" | sed -E 's/^[a-z]+(\([^)]+\))?:\s*//i')
+        
+        case "$category" in
+            added)   added+=("$clean_msg") ;;
+            fixed)   fixed+=("$clean_msg") ;;
+            changed) changed+=("$clean_msg") ;;
+            removed) removed+=("$clean_msg") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate the CHANGELOG.md content
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [Unreleased] - $(date +"$DATE_FORMAT")"
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
+        # Fixed
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            for item in "${fixed[@]}"; do
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
+    } > "$OUTPUT_FILE"
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
+    echo -e "${GREEN}  Location: $(pwd)/${OUTPUT_FILE}${NC}"
+}
+
+# Main execution
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not