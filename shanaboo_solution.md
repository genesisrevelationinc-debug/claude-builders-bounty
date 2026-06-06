 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,117 @@
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
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
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
+    if echo "$lower_msg" | grep -qE '^(feat|add|create|implement|introduce)'; then
+        echo "Added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
+        echo "Fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
+        echo "Removed"
+    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade)'; then
+        echo "Changed"
+    else
+        # Fallback: keyword-based detection
+        if echo "$lower_msg" | grep -qE '\b(add|added|adding|new|create|implement|introduce|feature)\b'; then
+            echo "Added"
+        elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|solved|correct|repair)\b'; then
+            echo "Fixed"
+        elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|revert)\b'; then
+            echo "Removed"
+        elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|modify|modified|refactor|improve|improved|enhance|enhanced|upgrade| XX upgraded)\b'; then
+            echo "Changed"
+        else
+            echo "Changed"  # Default category
+        fi
+    fi
+}
+
+# Generate the CHANGELOG.md
+generate_changelog() {
+    local last_tag
+    last_tag=$(get_last_tag)
+    
+    local commits
+    commits=$(get_commits_since "$last_tag")
+    
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No commits found since last tag.${NC}"
+        echo "Generating empty CHANGELOG.md template..."
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
+        # Clean up commit message (remove conventional commit prefix if present)
+        local clean_commit
+        clean_commit=$(echo "$commit" | sed -E 's/^[a-zA-Z]+(\([^)]*\))?:\s*//')
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        case "$category" in
+            Added) added+=("$clean_commit") ;;
+            Fixed) fixed+=("$clean_commit") ;;
+            Changed) changed+=("$clean_commit") ;;
+            Removed) removed+=("$clean_commit") ;;
+        esac
+    done <<< "$commits"
+    
+    # Get version and date
+    local version
+    if [ -n "$last_tag" ]; then
+        version="$last_tag"
+    else
+        version="Unreleased"
+    fi
+    local date_str
+    date_str=$(date +%Y-%m-%d)
+    
+    # Generate CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),"
+        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
+        echo ""
+        echo "## [$version] - $date_str"
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
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            echo ""
+            for item in "${changed[@]}"; do
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
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            echo ""
+            for item in "${removed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        # If no commits found, add a placeholder
+        if [ ${#added[@]} -eq 0 ] && [ ${#changed[@]} -eq 0 ] && [ ${#fixed[@]} -eq 0 ] && [ ${#removed[@]} -eq 0 ]; then
+            echo "### Changed"
+            echo ""
+            echo "- No changes since last release"
+            echo ""
+        fi
+