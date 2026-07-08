 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,152 @@
+#!/usr/bin/env bash
+
+# changelog.sh — Generate a structured CHANGELOG.md from git history
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
+get_commits() {
+    local tag
+    tag=$(get_latest_tag)
+    
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
+    fi
+}
+
+# Get the version for the changelog header
+get_version() {
+    local tag
+    tag=$(get_latest_tag)
+    
+    if [ -n "$tag" ]; then
+        # Increment patch version or append -next
+        if echo "$tag" | grep -qE '^v?[0-9]+\.[0-9]+\.[0-9]+'; then
+            local version
+            version=$(echo "$tag" | sed 's/^v//')
+            local major minor patch
+            major=$(echo "$version" | cut -d. -f1)
+            minor=$(echo "$version" | cut -d. -f2)
+            patch=$(echo "$version" | cut -d. -f3)
+            echo "${major}.${minor}.$((patch + 1))"
+        else
+            echo "${tag}-next"
+        fi
+    else
+        echo "0.0.1"
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
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement|create|new)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve|correct)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|eliminate|deprecate|revert)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(update|change|modify|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    # Check for keywords in the message body
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|introduce|implement|create)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|resolve|resolved|correct|corrected|patch|patched)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|deprecate|deprecated)\b'; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Generate the changelog
+generate_changelog() {
+    local version
+    version=$(get_version)
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
+        local category
+        category=$(categorize_commit "$commit")
+        
+        case "$category" in
+            added)   added+=("$commit") ;;
+            fixed)   fixed+=("$commit") ;;
+            removed) removed+=("$commit") ;;
+            changed) changed+=("$commit") ;;
+        esac
+    done < <(get_commits)
+    
+    # Write changelog
+    {
+        echo "# Changelog"
+        echo ""
+        echo "## [${version}] - ${DATE}"
+        echo ""
+        
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            printf -- "- %s\n" "${added[@]}"
+            echo ""
+        fi
+        
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            printf -- "- %s\n" "${changed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            printf -- "- %s\n" "${fixed[@]}"
+            echo ""
+        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            printf -- "- %s\n" "${removed[@]}"
+            echo ""
+        fi
+    } > "$OUTPUT_FILE"
+}
+
+# Main
+main() {
+    # Check if we're in a git repository
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo -e "${RED}Error: Not a git repository${NC}" >&2
+        exit 1
+    fi
+    
+    echo -e "${YELLOW}Generating CHANGELOG.md...${NC}"
+    
+    generate_changelog
+    
+    if [ -s "$OUTPUT_FILE" ]; then
+        echo -e "${GREEN}✓ CHANGELOG.md generated successfully${NC}"
+        echo ""
+        cat "$OUTPUT_FILE"
+    else
+        echo -e "${YELLOW}No commits found since last tag${NC}"
+    fi
+}
+
+main "$@"
+
+--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,52 @@
+# Generate Changelog Skill
+
+Generate a structured `CHANGELOG.md` from a project's git history.
