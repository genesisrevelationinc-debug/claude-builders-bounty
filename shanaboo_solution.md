```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,141 @@
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
+# Get commits since a specific tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
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
+    if echo "$lower_msg" | grep -qE '^(feat|add|new|introduce|implement)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|migrate)'; then
+        echo "changed"
+    # Check for keywords in the message body
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|feature)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|resolves|resolved|patch)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|reverted)\b'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '\b(change|changed|changing|update|updated|updating|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|migrate|migrated)\b'; then
+        echo "changed"
+    else
+        # Default to changed if no clear category
+        echo "changed"
+    fi
+}
+
+# Clean commit message (remove conventional commit prefix)
+clean_message() {
+    local message="$1"
+    # Remove conventional commit prefixes like "feat:", "fix:", "chore:", etc.
+    echo "$message" | sed -E 's/^[a-z]+(\([^)]*\))?:[[:space:]]*//i'
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
+        echo "Generating changelog with all commits instead..."
+        commits=$(git log --pretty=format:"%s")
+    fi
+    
+    if [ -z "$commits" ]; then
+        echo -e "${RED}No commits found in repository.${NC}"
+        exit 1
+    fi
+    
+    # Categorize commits
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+    
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        local clean_msg
+        clean_msg=$(clean_message "$commit")
+        
+        case "$category" in
+            added)   added+=("- $clean_msg") ;;
+            fixed)   fixed+=("- $clean_msg") ;;
+            changed) changed+=("- $clean_msg") ;;
+            removed) removed+=("- $clean_msg") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate output
+    local version_date
+    version_date=$(date +"$DATE_FORMAT")
+    local version_name="${latest_tag:-"Unreleased"}"
+    
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [$version_name] - $version_date"
+        echo ""
+        
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            printf '%s\n' "${added[@]}"
+            echo ""
+        fi
+        
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            printf '%s\n' "${fixed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            printf '%s\n' "${changed[@]}"
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
+    echo "  Version: $version_name"
+    echo "  Date: $version_date"
+    echo "  Categories: Added(${#added[@]}), Fixed(${#fixed[@]}), Changed(${#changed[@]}), Removed(${#removed[@]})"
+}
+
+# Main execution
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev