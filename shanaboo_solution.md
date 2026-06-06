 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,131 @@
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
+OUTPUT_FILE="${1:-$CHANGELOG_FILE}"
+
+# Get the latest tag, or use empty if no tags exist
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
+    fi
+}
+
+# Get the date of the latest tag or repo creation
+get_date_since() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log -1 --format=%ai "${tag}" 2>/dev/null | cut -d' ' -f1 || date +%Y-%m-%d
+    else
+        git log --reverse --format=%ai | head -1 | cut -d' ' -f1 2>/dev/null || date +%Y-%m-%d
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
+    elif [[ "$lower_msg" =~ ^(refactor|perf|style|chore|docs|test|build|ci)(\(.+\))?: ]]; then
+        echo "changed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
+        echo "removed"
+    # Fallback to keyword matching
+    elif [[ "$lower_msg" =~ ^(add|create|implement|introduce|new|support|enable) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bug|repair|correct|resolve|patch|hotfix) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|revert|deprecate|disable|clean) ]]; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Main execution
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
+    local commits
+    commits=$(get_commits_since_tag "$latest_tag")
+
+    if [ -z "$commits" ]; then
+        echo -e "${YELLOW}No new commits found since last tag.${NC}"
+        exit 0
+    fi
+
+    local version_date
+    version_date=$(date +%Y-%m-%d)
+
+    # Categorize commits
+    local added=""
+    local fixed=""
+    local changed=""
+    local removed=""
+
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        # Strip conventional commit prefix for cleaner output
+        local clean_commit
+        clean_commit=$(echo "$commit" | sed -E 's/^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?:[[:space:]]*//')
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        case "$category" in
+            added)   added="${added}- ${clean_commit}"$'\n' ;;
+            fixed)   fixed="${fixed}- ${clean_commit}"$'\n' ;;
+            changed) changed="${changed}- ${clean_commit}"$'\n' ;;
+            removed) removed="${removed}- ${clean_commit}"$'\n' ;;
+        esac
+    done <<< "$commits"
+
+    # Generate CHANGELOG content
+    local changelog_content=""
+    
+    # Check if CHANGELOG already exists to preserve history
+    if [ -f "$OUTPUT_FILE" ] && [ "$OUTPUT_FILE" = "$CHANGELOG_FILE" ]; then
+        # Read existing content (skip the header we'll regenerate)
+        local existing_content
+        existing_content=$(tail -n +3 "$OUTPUT_FILE" 2>/dev/null || true)
+        
+        changelog_content="# Changelog"$'\n\n'
+        changelog_content+="## [Unreleased] - ${version_date}"$'\n\n'
+        
+        if [ -n "$added" ]; then
+            changelog_content+="### Added"$'\n\n'"${added}"$'\n'
+        fi
+        if [ -n "$changed" ]; then
+            changelog_content+="### Changed"$'\n\n'"${changed}"$'\n'
+        fi
+        if [ -n "$fixed" ]; then
+            changelog_content+="### Fixed"$'\n\n'"${fixed}"$'\n'
+        fi
+        if [ -n "$removed" ]; then
+            changelog_content+="### Removed"$'\n\n'"${removed}"$'\n'
+        fi
+        
+        changelog_content+="${existing_content}"
+    else
+        changelog_content="# Changelog"$'\n\n'
+        changelog_content+="All notable changes to this project will be documented in this file."$'\n\n'
+        changelog_content+="## [Unreleased] - ${version_date}"$'\n\n'
+        
+        if [ -n "$added" ]; then
+            changelog_content+="### Added"$'\n\n'"${added}"$'\n'
+        fi
+        if [