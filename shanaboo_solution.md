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
+# Get the latest git tag, or empty if no tags exist
+get_latest_tag() {
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
+# Categorize a single commit message
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+    
+    # Skip merge commits and empty messages
+    if [[ "$lower_msg" =~ ^merge[[:space:]] ]]; then
+        echo ""
+        return
+    fi
+    
+    # Determine category based on commit message patterns
+    if [[ "$lower_msg" =~ ^(feat|add|create|introduce|implement|new)[:\(\ ] ]] || \
+       [[ "$lower_msg" =~ (add|added|adding)[:\ ] ]] || \
+       [[ "$lower_msg" =~ ^(feat|feature)[:\(\ ] ]]; then
+        echo "Added"
+    elif [[ "$lower_msg" =~ ^(fix|bugfix|hotfix|patch|resolve)[:\(\ ] ]] || \
+         [[ "$lower_msg" =~ (fix|fixed|fixes|fixing)[:\ ] ]] || \
+         [[ "$lower_msg" =~ ^(fix|bugfix)[:\(\ ] ]]; then
+        echo "Fixed"
+    elif [[ "$lower_msg" =~ ^(remove|delete|drop|eliminate|deprecate)[:\(\ ] ]] || \
+         [[ "$lower_msg" =~ (remove|removed|removing|delete|deleted|deleting)[:\ ] ]]; then
+        echo "Removed"
+    elif [[ "$lower_msg" =~ ^(change|update|modify|refactor|improve|enhance|upgrade|rework)[:\(\ ] ]] || \
+         [[ "$lower_msg" =~ (change|changed|update|updated|modify|modified|refactor|refactored)[:\ ] ]] || \
+         [[ "$lower_msg" =~ ^(chore|style|perf|performance|docs|doc)[:\(\ ] ]]; then
+        echo "Changed"
+    else
+        # Default to Changed for anything else
+        echo "Changed"
+    fi
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    local commits
+    commits=$(get_commits_since "$latest_tag")
+    
+    if [ -z "$commits" ]; then
+        echo "No commits found since the last tag."
+        exit 0
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
+            "Added") added+=("$commit") ;;
+            "Fixed") fixed+=("$commit") ;;
+            "Changed") changed+=("$commit") ;;
+            "Removed") removed+=("$commit") ;;
+        esac
+    done <<< "$commits"
+    
+    # Generate output
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        
+        # Determine version/date header
+        local version_date
+        version_date=$(date +%Y-%m-%d)
+        local version_header
+        if [ -n "$latest_tag" ]; then
+            version_header="## [Unreleased] — $version_date"
+        else
+            version_header="## [Unreleased] — $version_date"
+        fi
+        
+        echo "$version_header"
+        echo ""
+        
+        # Output categories
+        if [ ${#added[@]} -gt 0 ]; then
+            echo "### Added"
+            for item in "${added[@]}"; do
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
+        if [ ${#changed[@]} -gt 0 ]; then
+            echo "### Changed"
+            for item in "${changed[@]}"; do
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
+        # Append existing changelog content if it exists
+        if [ -f "$CHANGELOG_FILE" ]; then
+            # Skip the header of the existing changelog
+            tail -n +4 "$CHANGELOG_FILE" 2>/dev/null || true
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
+++	SKILL.md
@@ -0,0 +1,31 @@
+# Generate Changelog Skill
+
+A Claude Code skill to automatically generate a structured `CHANGELOG.md` from a project's git history.
+
+## Commands
+
+### `/generate-changelog`
+
+Generates a `CHANGELOG.md` file by:
+1. Fetching commits since the last git