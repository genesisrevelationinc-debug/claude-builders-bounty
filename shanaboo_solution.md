 ```diff
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,131 @@
+#!/usr/bin/env bash
+
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history
+# Fetches commits since the last git tag and auto-categorizes them
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+NC='\033[0m' # No Color
+
+# Get the directory where the script is located
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+CHANGELOG_FILE="${SCRIPT_DIR}/CHANGELOG.md"
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
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+# Categorize a commit message into one of the changelog categories
+categorize_commit() {
+    local message="$1"
+    local lower_msg
+    lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if [[ "$lower_msg" =~ ^feat(\(.*\))?: ]]; then
+        echo "added"
+        return
+    elif [[ "$lower_msg" =~ ^fix(\(.*\))?: ]]; then
+        echo "fixed"
+        return
+    elif [[ "$lower_msg" =~ ^(chore|docs|style|refactor|perf|test|build|ci|revert)(\(.*\))?: ]]; then
+        echo "changed"
+        return
+    fi
+    
+    # Fallback to keyword matching
+    case "$lower_msg" in
+        *add*|*implement*|*introduce*|*create*|*new*)
+            echo "added"
+            ;;
+        *fix*|*bugfix*|*resolve*|*patch*|*hotfix*|*correct*)
+            echo "fixed"
+            ;;
+        *remove*|*delete*|*drop*|*deprecate*|*clean*)
+            echo "removed"
+            ;;
+        *update*|*change*|*modify*|*refactor*|*improve*|*optimize*|*enhance*)
+            echo "changed"
+            ;;
+        *)
+            echo "changed"
+            ;;
+    esac
+}
+
+# Generate the changelog
+generate_changelog() {
+    echo -e "${YELLOW}🔍 Checking for git repository...${NC}"
+    
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository${NC}"
+        exit 1
+    fi
+    
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    if [ -n "$latest_tag" ]; then
+        echo -e "${GREEN}📌 Latest tag: $latest_tag${NC}"
+    else
+        echo -e "${YELLOW}⚠️  No tags found. Using all commits.${NC}"
+    fi
+    
+    echo -e "${YELLOW}📝 Generating CHANGELOG.md...${NC}"
+    
+    # Collect commits by category
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+    
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        # Clean up the commit message (remove conventional commit prefix)
+        local clean_commit
+        clean_commit=$(echo "$commit" | sed -E 's/^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([^)]*\))?:[[:space:]]*//')
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        case "$category" in
+            added) added+=("$clean_commit") ;;
+            fixed) fixed+=("$clean_commit") ;;
+            removed) removed+=("$clean_commit") ;;
+            changed) changed+=("$clean_commit") ;;
+        esac
+    done < <(get_commits_since_tag "$latest_tag")
+    
+    # Generate the changelog file
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
+        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
+        echo ""
+        
+        if [ -n "$latest_tag" ]; then
+            echo "## [Unreleased] - since $latest_tag"
+        else
+            echo "## [Unreleased]"
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
+        # If no commits found
+        if [ ${#added[@]} -eq 0 ] && [ ${#fixed[@]} -eq 0 ] && [ ${#changed[@]} -eq 0 ] && [ ${#removed[@]} -eq 0