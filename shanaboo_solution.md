```diff
--- /dev/null
+++ b/generate-changelog.sh
@@ -0,0 +1,163 @@
+#!/usr/bin/env bash
+#
+# generate-changelog.sh
+# Automatically generates a structured CHANGELOG.md from git history.
+#
+# Usage:
+#   bash generate-changelog.sh
+#   ./generate-changelog.sh
+#
+# This script fetches commits since the last git tag, auto-categorizes them,
+# and outputs a properly formatted CHANGELOG.md.
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
+# Configuration
+OUTPUT_FILE="CHANGELOG.md"
+DATE_FORMAT="%Y-%m-%d"
+
+# Function to print colored messages
+info() {
+    echo -e "${GREEN}[INFO]${NC} $1"
+}
+
+warn() {
+    echo -e "${YELLOW}[WARN]${NC} $1"
+}
+
+error() {
+    echo -e "${RED}[ERROR]${NC} $1"
+}
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    error "Not a git repository. Please run this script from a git repository."
+    exit 1
+fi
+
+# Get the latest tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
+get_commits() {
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
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|dep|bump)'; then
+        echo "changed"
+    # Check for keywords in the message
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create|new)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|revert|reverted)\b'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded)\b'; then
+        echo "changed"
+    else
+        # Default to changed if no clear category
+        echo "changed"
+    fi
+}
+
+# Main execution
+main() {
+    info "Generating changelog..."
+    
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    if [ -n "$latest_tag" ]; then
+        info "Found latest tag: $latest_tag"
+    else
+        warn "No tags found. Using all commits."
+    fi
+    
+    local commits
+    commits=$(get_commits "$latest_tag")
+    
+    if [ -z "$commits" ]; then
+        warn "No commits found since last tag."
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
+            added)   added+=("$commit") ;;
+            fixed)   fixed+=("$commit") ;;
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
+        # Footer
+