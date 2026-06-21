 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,168 @@
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
+# Function to print colored messages
+print_info() {
+    echo -e "${GREEN}[INFO]${NC} $1"
+}
+
+print_warn() {
+    echo -e "${YELLOW[WARN]${NC} $1"
+}
+
+print_error() {
+    echo -e "${RED}[ERROR]${NC} $1"
+}
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    print_error "Not a git repository. Please run this script from a git repository."
+    exit 1
+fi
+
+# Get the latest tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a specific tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag..HEAD" --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+# Get the date of the latest tag
+get_tag_date() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log -1 --format=%ai "$tag" | cut -d' ' -f1
+    else
+        echo ""
+    fi
+}
+
+# Get the current version (latest tag or "Unreleased")
+get_version() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        echo "$tag"
+    else
+        echo "Unreleased"
+    fi
+}
+
+# Categorize a commit message
+categorize_commit() {
+    local message="$1"
+    local lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
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
+    elif [[ "$lower_msg" =~ ^(add|new|create|introduce|implement) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|resolve|patch) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|deprecate|revert) ]]; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Main execution
+main() {
+    print_info "Generating CHANGELOG.md..."
+    
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    local since_date
+    since_date=$(get_tag_date "$latest_tag")
+    
+    local version
 version=$(get_version "$latest_tag")
+    
+    local today
+    today=$(date +"$DATE_FORMAT")
+    
+    print_info "Version: $version"
+    print_info "Date: $today"
+    if [ -n "$latest_tag" ]; then
+        print_info "Changes since tag: $latest_tag"
+    else
+        print_info "No previous tag found — including all commits"
+    fi
+    
+    # Collect commits by category
+    local added_commits=""
+    local fixed_commits=""
+    local changed_commits=""
+    local removed_commits=""
+    
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        # Clean up the commit message (remove conventional commit prefix)
+        local clean_commit="$commit"
+        clean_commit=$(echo "$clean_commit" | sed -E 's/^(feat|fix|chore|refactor|perf|style|remove|delete|drop|add|new|create|bugfix|hotfix|resolve|patch|introduce|implement|deprecate|revert)(\([^)]+\))?:[[:space:]]*//')
+        
+        case "$category" in
+            added)
+                added_commits="${added_commits}- ${clean_commit}"$'\n'
+                ;;
+            fixed)
+                fixed_commits="${fixed_commits}- ${clean_commit}"$'\n'
+                ;;
+            removed)
+                removed_commits="${removed_commits}- ${clean_commit}"$'\n'
+                ;;
+            changed)
+                changed_commits="${changed_commits}- ${clean_commit}"$'\n'
+                ;;
+        esac
+    done < <(get_commits_since_tag "$latest_tag")
+    
+    # Generate CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [$version] - $today"
+        echo ""
+        
+        if [ -n "$added_commits" ]; then
+            echo "### Added"
+            echo ""
+            echo -n "$added_commits"
+            echo ""
+        fi
+        
+        if [ -n "$changed_commits" ]; then
+            echo "### Changed"
+            echo ""
+            echo -n "$changed_commits"
+            echo ""
+        fi
+        
+        if [ -n "$fixed_commits" ]; then
+            echo "### Fixed"
+            echo ""
+            echo -n "$fixed_commits"
+            echo ""
+        fi
+        
+        if [ -n "$removed_commits" ]; then