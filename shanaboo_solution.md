 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,115 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+# Usage: bash changelog.sh
+
+CHANGELOG_FILE="CHANGELOG.md"
+TEMP_FILE=$(mktemp)
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the latest tag (or all commits if no tag)
+get_commits_since_tag() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag"..HEAD --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" 2>/dev/null || true
+    fi
+}
+
+# Categorize a single commit message
+categorize_commit() {
+    local msg="$1"
+    local lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|create|implement|introduce)'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|rework)'; then
+        echo "changed"
+    # Fallback: keyword matching
+    elif echo "$lower_msg" | grep -qE '\b(add|added|adding|new|create|implement|introduce|feature)\b'; then
+        echo "added"
+    elif echo "$lower_msg" | grep -qE '\b(fix|fixed|fixing|bug|resolve|solved|patch|correct|repair)\b'; then
+        echo "fixed"
+    elif echo "$lower_msg" | grep -qE '\b(remove|removed|removing|delete|deleted|deleting|drop|dropped|revert|deprecate)\b'; then
+        echo "removed"
+    elif echo "$lower_msg" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|modifying|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded|rework|reworked|optimize|optimized)\b'; then
+        echo "changed"
+    else
+        echo "changed"  # Default category
+    fi
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
+        echo "No commits found since the last tag."
+        exit 0
+    fi
+    
+    local version_date
+    version_date=$(date +%Y-%m-%d)
+    
+    local version_label
+    if [ -n "$latest_tag" ]; then
+        version_label="$latest_tag"
+    else
+        version_label="unreleased"
+    fi
+    
+    # Initialize category arrays
+    local added=()
+    local fixed=()
+    local changed=()
+    local removed=()
+    
+    # Process each commit
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+        
+        local category
+        category=$(categorize_commit "$commit")
+        
+        case "$category" in
+            added) added+=("$commit") ;;
+            fixed) fixed+=("$commit") ;;
+            changed) changed+=("$commit") ;;
+            removed) removed+=("$commit") ;;
+        esac
+    done <<< "$commits"
+    
+    # Build the changelog content
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [$version_label] - $version_date"
+        echo ""
+        
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            for item in "${added[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            for item in "${changed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        if [ ${#fixed[@]} -gt 0 ]; then
+            echo "### Fixed"
+            for item in "${fixed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        if [ ${#removed[@]} -gt 0 ]; then
+            echo "### Removed"
+            for item in "${removed[@]}"; do
+                echo "- $item"
+            done
+            echo ""
+        fi
+        
+        # Append existing changelog content if it exists (skip the header)
+        if [ -f "$CHANGELOG_FILE" ]; then
+            tail -n +5 "$CHANGELOG_FILE" 2>/dev/null || true
+        fi
+    } > "$TEMP_FILE"
+    
+    mv "$TEMP_FILE" "$CHANGELOG_FILE"
+    echo "CHANGELOG.md generated successfully!"
+}
+
+# Main execution
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    echo "Error: Not a git repository."
+    exit 1
+fi
+
+generate_changelog
--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,47 @@
+# Generate Changelog Skill
+
+A Claude Code skill to automatically generate a structured `CHANGELOG.md` from git history.
+
+## Installation
+
+1. Copy `changelog.sh` to your project root
+2. Make it executable: `chmod +x changelog.sh`
+3. Run: `bash changelog.sh`
+
+## Usage
+
+### As a Claude Code command
+
+Add to your Claude Code configuration to enable `/generate-changelog`:
+
+