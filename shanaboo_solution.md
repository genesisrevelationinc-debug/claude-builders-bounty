 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,163 @@
+#!/usr/bin/env bash
+#
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+#
+# Usage: bash changelog.sh
+#        ./changelog.sh
+#
+# Fetches commits since the last git tag, auto-categorizes them, and
+# appends a new version section to CHANGELOG.md.
+#
+
+set -euo pipefail
+
+# -----------------------------------------------------------------------------
+# Configuration
+# -----------------------------------------------------------------------------
+
+CHANGELOG_FILE="CHANGELOG.md"
+DATE=$(date +%Y-%m-%d)
+
+# -----------------------------------------------------------------------------
+# Helpers
+# -----------------------------------------------------------------------------
+
+error() {
+    echo "Error: $*" >&2
+    exit 1
+}
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    error "Not a git repository. Please run this script from a git repo."
+fi
+
+# Get the latest tag, or empty if none
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || true
+}
+
+# Get commits since a given tag (or all commits if no tag)
+get_commits_since() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" --no-merges 2>/dev/null || true
+    else
+        git log --pretty=format:"%s" --no-merges 2>/dev/null || true
+    fi
+}
+
+# Categorize a single commit message into a section
+categorize_commit() {
+    local msg="$1"
+    local lower_msg
+    lower_msg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')
+
+    # Check for conventional commit prefixes first
+    if [[ "$lower_msg" =~ ^feat(\(.+\))?: ]]; then
+        echo "added"
+        return
+    elif [[ "$lower_msg" =~ ^fix(\(.+\))?: ]]; then
+        echo "fixed"
+        return
+    elif [[ "$lower_msg" =~ ^(chore|refactor|perf|style|docs|test|build|ci|revert)(\(.+\))?: ]]; then
+        echo "changed"
+        return
+    elif [[ "$lower_msg" =~ ^remove(\(.+\))?: ]]; then
+        echo "removed"
+        return
+    fi
+
+    # Fallback: keyword-based categorization
+    if [[ "$lower_msg" =~ (add|new|introduce|implement|create|support|enable) ]]; then
+        echo "added"
+    elif [[ "$lower_msg" =~ (fix|bug|repair|resolve|patch|correct) ]]; then
+        echo "fixed"
+    elif [[ "$lower_msg" =~ (remove|delete|drop|eliminate|deprecat|clean) ]]; then
+        echo "removed"
+    else
+        echo "changed"
+    fi
+}
+
+# -----------------------------------------------------------------------------
+# Main
+# -----------------------------------------------------------------------------
+
+main() {
+    local latest_tag
+    latest_tag=$(get_latest_tag)
+
+    local version_header
+    if [ -n "$latest_tag" ]; then
+        version_header="## [Unreleased] — since ${latest_tag}"
+    else
+        version_header="## [Unreleased]"
+    fi
+
+    # Collect and categorize commits
+    local added=() fixed=() changed=() removed=()
+
+    while IFS= read -r commit; do
+        [ -z "$commit" ] && continue
+
+        local category
+        category=$(categorize_commit "$commit")
+
+        case "$category" in
+            added)   added+=("- $commit") ;;
+            fixed)   fixed+=("- $commit") ;;
+            changed) changed+=("- $commit") ;;
+            removed) removed+=("- $commit") ;;
+        esac
+    done < <(get_commits_since "$latest_tag")
+
+    # Build the new changelog section
+    local new_section=""
+    new_section+="${version_header} — ${DATE}"$'\n'
+
+    if [ ${#added[@]} -gt 0 ]; then
+        new_section+=$'\n'"### Added"$'\n'
+        printf -v tmp '%s\n' "${added[@]}"
+        new_section+="$tmp"
+    fi
+
+    if [ ${#fixed[@]} -gt 0 ]; then
+        new_section+=$'\n'"### Fixed"$'\n'
+        printf -v tmp '%s\n' "${fixed[@]}"
+        new_section+="$tmp"
+    fi
+
+    if [ ${#changed[@]} -gt 0 ]; then
+        new_section+=$'\n'"### Changed"$'\n'
+        printf -v tmp '%s\n' "${changed[@]}"
+        new_section+="$tmp"
+    fi
+
+    if [ ${#removed[@]} -gt 0 ]; then
+        new_section+=$'\n'"### Removed"$'\n'
+        printf -v tmp '%s\n' "${removed[@]}"
+        new_section+="$tmp"
+    fi
+
+    new_section+=$'\n'
+
+    # Prepend to existing CHANGELOG.md or create new one
+    if [ -f "$CHANGELOG_FILE" ]; then
+        local existing
+        existing=$(cat "$CHANGELOG_FILE")
+        {
+            echo "# Changelog"
+            echo ""
+            echo "$new_section"
+            # Remove old header if present and append rest
+            echo "$existing" | sed '1,/^# Changelog/d' | sed '/^$/!b;:a;N;/\n$/!ba;d' | sed '/./,$!d'
+        } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
+    else
+        {
+            echo "# Changelog"
+            echo ""
+            echo "$new_section"
+        } > "$CHANGELOG_FILE"
+    fi
+
+    echo "✅ CHANGELOG.md updated successfully!"
+    echo ""
+    echo "Summary:"
+    echo "  Added:   ${#added[@]}"
+    echo "  Fixed:   ${#fixed[@]}"
+    echo "  Changed: ${#changed[@]}"
+    echo "  Removed: ${#removed[@]}"
+}
+
+main "$@"
+
+--- /dev/null
+++ b/SKILL.md
@@ -0,0 +1,47 @@
+# /generate-changelog
+
+Generate a structured `CHANGELOG.md` from a project's