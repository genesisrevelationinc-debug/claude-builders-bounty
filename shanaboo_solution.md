 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,166 @@
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
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get the repository URL for linking
+get_repo_url() {
+    git remote get-url origin 2>/dev/null | sed 's/\.git$//' | sed 's/git@github.com:/https:\/\/github.com\//' || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag)
+get_commits() {
+    local since_tag="$1"
+    if [ -n "$since_tag" ]; then
+        git log "${since_tag}..HEAD" --pretty=format:"%H|%s|%b" --reverse
+    else
+        git log --pretty=format:"%H|%s|%b" --reverse
+    fi
+}
+
+# Categorize a commit based on its message
+categorize_commit() {
+    local message="$1"
+    local lower_msg
+    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
+        echo "added"
+        return
+    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
+        echo "fixed"
+        return
+    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
+        echo "changed"
+        return
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
+        echo "removed"
+        return
+    fi
+    
+    # Fallback to keyword matching
+    if [[ "$lower_msg" =~ (add|new|introduce|implement|create|support|enable) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ (fix|bug|patch|resolve|correct|repair) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ (remove|delete|drop|revert|deprecate|eliminate) ]]; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Clean commit message for display
+clean_message() {
+    local message="$1"
+    # Remove conventional commit prefix
+    echo "$message" | sed -E 's/^(feat|fix|chore|refactor|perf|style|docs|test|remove|delete|drop|revert)(\([^)]+\))?:\s*//'
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    local repo_url
+    repo_url=$(get_repo_url)
+    local version="Unreleased"
+    local date_str
+    date_str=$(date +"$DATE_FORMAT")
+    
+    if [ -n "$latest_tag" ]; then
+        version="${latest_tag}..HEAD"
+    fi
+    
+    echo -e "${GREEN}Generating CHANGELOG...${NC}"
+    if [ -n "$latest_tag" ]; then
+        echo -e "${YELLOW}Fetching commits since tag: $latest_tag${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Fetching all commits.${NC}"
+    fi
+    
+    # Collect commits by category
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+    
+    while IFS='|' read -r hash subject body; do
+        [ -z "$hash" ] && continue
+        
+        local category
+        category=$(categorize_commit "$subject")
+        local clean_msg
+        clean_msg=$(clean_message "$subject")
+        
+        # Build commit link if repo URL is available
+        local commit_link=""
+        if [ -n "$repo_url" ]; then
+            commit_link=" ([${hash:0:7}](${repo_url}/commit/${hash}))"
+        fi
+        
+        case "$category" in
+            added)   added+=("- ${clean_msg}${commit_link}") ;;
+            fixed)   fixed+=("- ${clean_msg}${commit_link}") ;;
+            changed) changed+=("- ${clean_msg}${commit_link}") ;;
+            removed) removed+=("- ${clean_msg}${commit_link}") ;;
+        esac
+    done < <(get_commits "$latest_tag")
+    
+    # Write CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [${version}] - ${date_str}"
+        echo ""
+        
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            printf '%s\n' "${added[@]}"
+            echo ""
+        fi
+        
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            printf '%s\n' "${changed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            printf '%s\n' "${fixed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            printf '%s\n' "${removed[@]}"
+            echo ""
+        fi
+    } > "$OUTPUT_FILE"
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
+    echo -e "${YELLOW}Categories found:${NC}"
+    echo "  - Added:   ${#added[@]}"
+    echo "  - Changed: ${#changed[@]}"
+    echo "  - Fixed:   ${#fixed[@]}"
+    echo "  - Removed: ${#removed[@]}"
+}
+
+# Main
+main() {
