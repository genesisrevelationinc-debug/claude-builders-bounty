 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,133 @@
+#!/usr/bin/env bash
+#
+# changelog.sh - Generate a structured CHANGELOG.md from git history
+#
+# Usage: bash changelog.sh
+#
+# This script fetches commits since the last git tag and auto-categorizes
+# them into: Added / Fixed / Changed / Removed
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
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -z "$tag" ]; then
+        # No tags exist, get all commits
+        git log --pretty=format:"%s" --no-merges
+    else
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges
+    fi
+}
+
+# Categorize a single commit message
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
+    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test)(\()?.*\)??: ]]; then
+        echo "changed"
+        return
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop)(\()?.*\)??: ]]; then
+        echo "removed"
+        return
+    fi
+    
+    # Fallback: keyword-based categorization
+    if [[ "$lower_msg" =~ ^(add|create|introduce|implement|new|support) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ ^(fix|bugfix|resolve|patch|correct|repair) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|purge|clean) ]]; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# Generate the changelog
+generate_changelog() {
+    local tag
+    tag=$(get_latest_tag)
+    local version
+    local date_str
+    date_str=$(date +%Y-%m-%d)
+    
+    if [ -z "$tag" ]; then
+        version="Unreleased"
+        echo -e "${YELLOW}No existing tags found. Generating changelog for all commits.${NC}"
+    else
+        version="$tag"
+        echo -e "${GREEN}Found latest tag: $tag${NC}"
+    fi
+    
+    # Read commits into array
+    local commits
+    mapfile -t commits < <(get_commits_since_tag "$tag")
+    
+    if [ ${#commits[@]} -eq 0 ]; then
+        echo -e "${YELLOW}No commits found since $version.${NC}"
+        return
+    fi
+    
+    echo -e "${GREEN}Found ${#commits[@]} commits to process.${NC}"
+    
+    # Categorize commits
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+    
+    for commit in "${commits[@]}"; do
+        # Skip empty lines
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        # Clean up conventional commit prefix for display
+        local clean_msg
+        clean_msg=$(echo "$commit" | sed -E 's/^(feat|fix|chore|refactor|perf|style|docs|test|remove|delete|drop)(\([^)]*\))?:\s*//i')
+        
+        case "$category" in
+            added)   added+=("- $clean_msg") ;;
+            fixed)   fixed+=("- $clean_msg") ;;
+            changed) changed+=("- $clean_msg") ;;
+            removed) removed+=("- $clean_msg") ;;
+        esac
+    done
+    
+    # Build changelog content
+    local changelog=""
+    changelog="## [$version] - $date_str"$'\n\n'
+    
+    if [ ${#added[@]} -gt 0 ]; then
+        changelog+="### Added"$'\n\n'
+        for item in "${added[@]}"; do
+            changelog+="$item"$'\n'
+        done
+        changelog+=$'\n'
+    fi
+    
+    if [ ${#fixed[@]} -gt 0 ]; then
+        changelog+="### Fixed"$'\n\n'
+        for item in "${fixed[@]}"; do
+            changelog+="$item"$'\n'
+        done
+        changelog+=$'\n'
+    fi
+    
+    if [ ${#changed[@]} -gt 0 ]; then
+        changelog+="### Changed"$'\n\n'
+        for item in "${changed[@]}"; do
+            changelog+="$item"$'\n'
+        done
+        changelog+=$'\n'
+    fi
+    
+    if [ ${#removed[@]} -gt 0 ]; then
+        changelog+="### Removed"$'\n\n'
+        for item in "${removed[@]}"; do
+            changelog+="$item"$'\n'
+        done
+        changelog+=$'\n'
+    fi
+    
+    # Write or prepend to CHANGELOG.md
+    if [ -f "CHANGELOG.md" ]; then
+        # Prepend new section to existing changelog
+        local existing
+        existing=$(cat CHANGELOG.md)
+        echo -e "# Changelog\n\n$changelog$existing" > CHANGELOG.md
+    else
+        echo -e "# Changelog\n\n$changelog" > CHANGELOG.md
+    fi
+    
+    echo -e "${GREEN}✅ CHANGELOG.md generated successfully!${NC}"
+}
+
+# Main execution
+main() {
+    # Check if we're in a git