 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,115 @@
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
+# Get commits since the last tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" --reverse
+    else
+        git log --pretty=format:"%s" --reverse
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
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|modify|change|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    # Check for keywords in the message body
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|bug|patch)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|dropped|eliminate|deprecate)\b'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|modify|modified|modifying|change|changed|changing|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked)\b'; then
+        echo "changed"
+    else
+        echo "changed"  # Default category
+    fi
+}
+
+# Generate the CHANGELOG.md
+generate_changelog() {
+    local last_tag
+    last_tag=$(get_last_tag)
+    
+    local version
+    if [ -n "$last_tag" ]; then
+        version="$last_tag"
+    else
+        version="Unreleased"
+    fi
+    
+    # Temporary files for categories
+    local added_file fixed_file changed_file removed_file
+    added_file=$(mktemp)
+    fixed_file=$(mktemp)
+    changed_file=$(mktemp)
+    removed_file=$(mktemp)
+    
+    # Process commits
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        # Clean up the commit message (remove conventional commit prefix if present)
+        local clean_msg
+        clean_msg=$(echo "$commit" | sed -E 's/^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([^)]+\))?:\s*//')
+        
+        case "$category" in
+            added)   echo "- $clean_msg" >> "$added_file" ;;
+            fixed)   echo "- $clean_msg" >> "$fixed_file" ;;
+            removed) echo "- $clean_msg" >> "$removed_file" ;;
+            changed) echo "- $clean_msg" >> "$changed_file" ;;
+        esac
+    done < <(get_commits_since_tag "$last_tag")
+    
+    # Generate CHANGELOG.md
+    {
+        echo "# Changelog"
+        echo ""
+        echo "## [$version] - $(date +%Y-%m-%d)"
+        echo ""
+        
+        if [ -s "$added_file" ]; then
+            echo "### Added"
+            cat "$added_file"
+            echo ""
+        fi
+        
+        if [ -s "$changed_file" ]; then
+            echo "### Changed"
+            cat "$changed_file"
+            echo ""
+        fi
+        
+        if [ -s "$fixed_file" ]; then
+            echo "### Fixed"
+            cat "$fixed_file"
+            echo ""
+        fi
+        
+        if [ -s "$removed_file" ]; then
+            echo "### Removed"
+            cat "$removed_file"
+            echo ""
+        fi
+    } > CHANGELOG.md
+    
+    # Cleanup temp files
+    rm -f "$added_file" "$fixed_file" "$changed_file" "$removed_file"
+    
+    echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
+    echo -e "${YELLOW}  Version: $version${NC}"
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
+    # Check if there are any commits
+    if ! git log --oneline -1 > /dev/null 2>&1; then
+        echo -e "${RED}Error: No commits found in this repository${NC}" >&2
+        exit 1
+    fi
+    
+    generate_changelog
+}
+
+main "$@"
+
+--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,31 @@
+# Generate Changelog Skill
+
+A Claude Code skill to automatically generate a structured `CHANGELOG.md` from git history.
