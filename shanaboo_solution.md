 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,137 @@
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
+DATE=$(date +%Y-%m-%d)
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
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
+    # Fallback: keyword-based categorization
+    if [[ "$lower_msg" =~ (add|new|introduce|implement|create|support|enable) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ (fix|bug|resolve|patch|correct|repair) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ (remove|delete|drop|revert|deprecate|eliminate) ]]; then
+        echo "removed"
+    elif [[ "$lower_msg" =~ (update|change|modify|refactor|improve|enhance|upgrade|optimize) ]]; then
+        echo "changed"
+    else
+        # Default to changed if no clear category
+        echo "changed"
+    fi
+}
+
+# Format a commit message for the changelog
+format_commit() {
+    local msg="$1"
+    # Remove conventional commit prefix if present
+    local formatted
+    formatted=$(echo "$msg" | sed -E 's/^[a-zA-Z]+(\(.+\))?:\s*//')
+    # Capitalize first letter
+    formatted="$(tr '[:lower:]' '[:upper:]' <<< "${formatted:0:1}")${formatted:1}"
+    echo "- $formatted"
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
+    if [ -n "$latest_tag" ]; then
+        echo -e "${YELLOW}Generating changelog since tag: $latest_tag${NC}"
+    else
+        echo -e "${YELLOW}No tags found. Generating changelog from all commits.${NC}"
+    fi
+    
+    # Read commits into arrays by category
+    local added=() fixed=() changed=() removed=()
+    
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        local formatted
+        formatted=$(format_commit "$commit")
+        
+        case "$category" in
+            added)   added+=("$formatted") ;;
+            fixed)   fixed+=("$formatted") ;;
+            changed) changed+=("$formatted") ;;
+            removed) removed+=("$formatted") ;;
+        esac
+    done < <(get_commits_since_tag "$latest_tag")
+    
+    # Generate CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
+        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
+        echo ""
+        
+        # Determine version header
+        if [ -n "$latest_tag" ]; then
+            echo "## [Unreleased] - $DATE"
+        else
+            echo "## [Unreleased] - $DATE"
+        fi
+        echo ""
+        
+        # Output each category if it has entries
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            echo ""
+            printf '%s\n' "${added[@]}"
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
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            echo ""
+            printf '%s\n' "${fixed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            echo ""
+            printf '%s\n' "${removed[@]}"
+            echo ""
+        fi
+        
+        echo "---"
+        echo ""
+        echo "*Generated automatically by changelog.sh*"
+    } > "$OUTPUT_FILE"
+    
+    local total=$(( ${#added[@]} + ${#changed[@]} + ${#fixed[@