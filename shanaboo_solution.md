```diff
--- a/generate-changelog.sh
+++ b/generate-changelog.sh
@@ -0,0 +1,177 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+# generate-changelog.sh
+# Generates a structured CHANGELOG.md from git history
+# Usage: ./generate-changelog.sh [output_file]
+
+OUTPUT_FILE="${1:-CHANGELOG.md}"
+TEMP_DIR=$(mktemp -d)
+trap 'rm -rf "$TEMP_DIR"' EXIT
+
+# Get the latest git tag, or use empty if no tags exist
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "$tag..HEAD" --pretty=format:"%H|%s|%b" --reverse
+    else
+        git log --pretty=format:"%H|%s|%b" --reverse
+    fi
+}
+
+# Categorize a commit based on its message
+categorize_commit() {
+    local message="$1"
+    local lower_msg=$(echo "$message" | tr '[:upper:]' '[:lower:]')
+    
+    # Check for conventional commit prefixes first
+    if echo "$lower_msg" | grep -qE '^(feat|add|introduce|implement)'; then
+        echo "Added"
+    elif echo "$lower_msg" | grep -qE '^(fix|bugfix|hotfix|patch|resolve)'; then
+        echo "Fixed"
+    elif echo "$lower_msg" | grep -qE '^(remove|delete|drop|revert|deprecate)'; then
+        echo "Removed"
+    elif echo "$lower_msg" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade)'; then
+        echo "Changed"
+    else
+        # Default to Changed for anything else
+        echo "Changed"
+    fi
+}
+
+# Extract issue/PR references from commit message
+extract_references() {
+    local message="$1"
+    # Extract #123 or GH-123 patterns
+    echo "$message" | grep -oE '#[0-9]+|GH-[0-9]+' | sort -u | tr '\n' ' ' | sed 's/ $//'
+}
+
+# Format a single commit into markdown
+format_commit() {
+    local hash="$1"
+    local subject="$2"
+    local body="$3"
+    local short_hash=$(echo "$hash" | cut -c1-7)
+    local references=$(extract_references "$subject $body")
+    
+    # Clean up the subject line (remove conventional commit prefix if present)
+    local clean_subject=$(echo "$subject" | sed -E 's/^[a-z]+(\([^)]*\))?:\s*//i')
+    
+    local line="- $clean_subject"
+    
+    # Add references if found
+    if [ -n "$references" ]; then
+        line="$line ($references)"
+    fi
+    
+    # Add short hash link
+    line="$line — [\`$short_hash\`]($(git remote get-url origin 2>/dev/null | sed 's/\.git$//' || echo "#")/commit/$hash)"
+    
+    echo "$line"
+}
+
+# Generate the changelog
+generate_changelog() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+    
+    local tag_info=""
+    if [ -n "$latest_tag" ]; then
+        tag_info=" since $latest_tag"
+    fi
+    
+    # Collect commits by category
+    local added_commits=""
+    local fixed_commits=""
+    local changed_commits=""
+    local removed_commits=""
+    
+    while IFS='|' read -r hash subject body; do
+        [ -z "$hash" ] && continue
+        
+        local category
+        category=$(categorize_commit "$subject")
+        local formatted
+        formatted=$(format_commit "$hash" "$subject" "$body")
+        
+        case "$category" in
+            Added) added_commits="$added_commits"$'\n'"$formatted" ;;
+            Fixed) fixed_commits="$fixed_commits"$'\n'"$formatted" ;;
+            Removed) removed_commits="$removed_commits"$'\n'"$formatted" ;;
+            Changed) changed_commits="$changed_commits"$'\n'"$formatted" ;;
+        esac
+    done < <(get_commits_since "$latest_tag")
+    
+    # Generate the markdown output
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
+        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
+        echo ""
+        echo "## [Unreleased]$(date +%Y-%m-%d)"
+        echo ""
+        
+        if [ -n "$added_commits" ]; then
+            echo "### Added"
+            echo "$added_commits" | sed '/^$/d'
+            echo ""
+        fi
+        
+        if [ -n "$changed_commits" ]; then
+            echo "### Changed"
+            echo "$changed_commits" | sed '/^$/d'
+            echo ""
+        fi
+        
+        if [ -n "$fixed_commits" ]; then
+            echo "### Fixed"
+            echo "$fixed_commits" | sed '/^$/d'
+            echo ""
+        fi
+        
+        if [ -n "$removed_commits" ]; then
+            echo "### Removed"
+            echo "$removed_commits" | sed '/^$/d'
+            echo ""
+        fi
+        
+        echo "---"
+        echo ""
+        echo "Generated automatically from git history$tag_info."
+    } > "$OUTPUT_FILE"
+}
+
+# Main execution
+main() {
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo "Error: Not a git repository" >&2
+        exit 1
+    fi
+    
+    generate_changelog
+    echo "CHANGELOG generated at $OUTPUT_FILE"
+}
+
+main "$@"
--- a/README.md
+++ b/README.md
@@ -0,0 +1,45 @@
+#