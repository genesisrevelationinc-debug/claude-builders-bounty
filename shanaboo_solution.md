 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,130 @@
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
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag..HEAD" --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
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
+    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style)(\(.+\))?: ]]; then
+        echo "changed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\(.+\))?: ]]; then
+        echo "removed"
+    # Fallback to keyword matching
+    elif [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|support|enable) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bugfix|resolve|patch|hotfix|correct|repair) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|deprecate|eliminate) ]]; then
+        echo "removed"
+    elif [[ "$lower_msg" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize) ]]; then
+        echo "changed"
+    else
+        echo "changed"  # Default category
+    fi
+}
+
+# Clean commit message for changelog (remove conventional commit prefix)
+clean_message() {
+    local msg="$1"
+    # Remove conventional commit prefix like "feat:", "fix(scope):", etc.
+    echo "$msg" | sed -E 's/^[a-z]+(\([^)]+\))?:[[:space:]]*//'
+}
+
+# Main function
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository.${NC}"
+        exit 1
+    fi
+
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+
+    if [ -n "$latest_tag" ]; then
+        echo -e "${GREEN}Generating changelog for commits since tag: $latest_tag${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
+    fi
+
+    local commits
+    commits=$(get_commits_since "$latest_tag")
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
+        local clean_msg
+        clean_msg=$(clean_message "$commit")
+        
+        case "$category" in
+            added)   added+=("$clean_msg") ;;
+            fixed)   fixed+=("$clean_msg") ;;
+            removed) removed+=("$clean_msg") ;;
+            changed) changed+=("$clean_msg") ;;
+        esac
+    done <<< "$commits"
+
+    # Generate CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        
+        local version_date
+        version_date=$(date +%Y-%m-%d)
+        
+        if [ -n "$latest_tag" ]; then
+            echo "## [Unreleased] - $version_date"
+        else
+            echo "## [Unreleased] - $version_date"
+        fi
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
+        # Append existing changelog content if it exists
+        if [ -f CHANGELOG.md ]; then
+            # Extract content after the first header
+            tail -n +3 CHANGELOG.md 2>/dev/null | grep -v "^# Changelog" || true
+        fi
+        
+    } > CHANGELOG.md.new
+    
+    mv CHANGELOG.md.new CHANGELOG.md
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully!${NC}"
+}
+
+main "$@"
