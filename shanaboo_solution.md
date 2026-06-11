 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,152 @@
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
+CHANGELOG_FILE="CHANGELOG.md"
+OUTPUT_FILE="${CHANGELOG_FILE}"
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
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
+    fi
+}
+
+# Get the date of the latest tag or repo creation
+get_tag_date() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log -1 --format=%ai "${tag}" 2>/dev/null | cut -d' ' -f1 || date +%Y-%m-%d
+    else
+        git log --reverse --format=%ai | head -1 | cut -d' ' -f1 || date +%Y-%m-%d
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
+    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
+        echo "added"
+        return
+    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
+        echo "fixed"
+        return
+    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\(.+\))?: ]]; then
+        echo "changed"
+        return
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
+        echo "removed"
+        return
+    fi
+    
+    # Fallback: keyword-based categorization
+    if [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|support|enable) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bug|repair|resolve|patch|correct) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate|retire) ]]; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    local commits
+    commits=$(get_commits_since_tag "$latest_tag")
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
+    # Categorize each commit
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        # Clean up the commit message (remove conventional commit prefix)
+        local clean_msg
+        clean_msg=$(echo "$commit" | sed -E 's/^(feat|fix|chore|refactor|perf|style|docs|test|remove|delete|drop)(\([^al]*\))?:\s*//i')
+        
+        case "$category" in
+            added)  added+=("- $clean_msg") ;;
+            fixed)  fixed+=("- $clean_msg") ;;
+            changed) changed+=("- $clean_msg") ;;
+            removed) removed+=("- $clean_msg") ;;
+        esac
+    done <<< "$commits"
+    
+    # Get version info
+    local version_name="${latest_tag:-$(git describe --tags --always 2>/dev/null || echo 'unreleased')}"
+    local release_date
+    release_date=$(date +%Y-%m-%d)
+    
+    # Build the changelog content
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [${version_name}] - ${release_date}"
+        echo ""
+        
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            echo ""
+            printf '%s\n' "${added[@]}"
+            echo ""
+        fi
+        
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            echo ""
+            printf '%s\n' "${fixed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            echo ""
+            printf '%s\n' "${changed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            echo ""
+            printf '%s\n' "${removed[@]}"
+            echo ""
+        fi
+    } > "$OUTPUT_FILE"
+    
+    echo -e "${GREEN}✓ Generated $OUTPUT_FILE${NC}"
+    echo -e "${GREEN}  Version: $version_name${NC}"
+    echo -e "${GREEN}  Date: $release_date${NC}"
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
+