 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,95 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# Automatically generates a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage:
+#   ./generate-changelog [output_file]
+#
+#   Or as a Claude Code skill command:
+#   /generate-changelog
+
+set -euo pipefail
+
+OUTPUT_FILE="${1:-CHANGELOG.md}"
+
+# ── helpers ─────────────────────────────────────────────────────────
+die() { printf '%s\n' "$*" >&2; exit 1; }
+
+has_git() { command -v git &>/dev/null; }
+
+get_last_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+get_commits_since() {
+    local since="$1"
+    if [[ -n "$since" ]]; then
+        git log "${since}..HEAD" --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+categorize() {
+    local msg="$1"
+    # normalize: lowercase first word
+    local first
+    first=$(echo "$msg" | awk '{print tolower($1)}')
+
+    case "$first" in
+        add|added|feat|feature|implement|introduce|create|new)
+            echo "Added" ;;
+        fix|fixed|bugfix|hotfix|resolve|patch|correct|repair)
+            echo "Fixed" ;;
+        change|changed|update|updated|modify|modified|refactor|rework|improve|enhance|upgrade|migrate|bump)
+            echo "Changed" ;;
+        remove|removed|delete|deleted|drop|dropped|deprecate|deprecate|clean|cleanup)
+            echo "Removed" ;;
+        *)
+            echo "Changed" ;;  # default bucket
+    esac
+}
+
+# ── main ────────────────────────────────────────────────────────────
+main() {
+    has_git || die "Error: git is not installed."
+
+    [[ -d ".git" ]] || die "Error: not inside a git repository."
+
+    local last_tag
+    last_tag=$(get_last_tag)
+
+    local commits
+    commits=$(get_commits_since "$last_tag")
+
+    [[ -n "$commits" ]] || die "No commits found since last tag."
+
+    local added="" fixed="" changed="" removed=""
+
+    while IFS= read -r line; do
+        [[ -z "$line" ]] && continue
+        local cat
+        cat=$(categorize "$line")
+        case "$cat" in
+            Added)   added+="- $line"$'\n' ;;
+            Fixed)   fixed+="- $line"$'\n' ;;
+            Changed) changed+="- $line"$'\n' ;;
+            Removed) removed+="- $line"$'\n' ;;
+        esac
+    done <<< "$commits"
+
+    {
+        echo "# Changelog"
+        echo ""
+        echo "All notable changes to this project will be documented in this file."
+        echo ""
+        echo "## [Unreleased] ($(date +%Y-%m-%d))"
+        echo ""
+        [[ -n "$added" ]]   && { echo "### Added";   echo ""; echo -n "$added";   echo ""; }
+        [[ -n "$fixed" ]]   && { echo "### Fixed";   echo ""; echo -n "$fixed";   echo ""; }
+        [[ -n "$changed" ]] && { echo "### Changed"; echo ""; echo -n "$changed"; echo ""; }
+        [[ -n "$removed" ]] && { echo "### Removed"; echo ""; echo -n "$removed"; echo ""; }
+    } > "$OUTPUT_FILE"
+
+    echo "✅  CHANGELOG written to $OUTPUT_FILE"
+}
+
+main "$@"
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,95 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# Automatically generates a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage:
+#   ./generate-changelog [output_file]
+#
+#   Or as a Claude Code skill command:
+#   /generate-changelog
+
+set -euo pipefail
+
+OUTPUT_FILE="${1:-CHANGELOG.md}"
+
+# ── helpers ─────────────────────────────────────────────────────────
+die() { printf '%s\n' "$*" >&2; exit 1; }
+
+has_git() { command -v git &>/dev/null; }
+
+get_last_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+get_commits_since() {
+    local since="$1"
+    if [[ -n "$since" ]]; then
+        git log "${since}..HEAD" --pretty=format:"%s" --no-merges
+    else
+        git log --pretty=format:"%s" --no-merges
+    fi
+}
+
+categorize() {
+    local msg="$1"
+    # normalize: lowercase first word
+    local first
+    first=$(echo "$msg" | awk '{print tolower($1)}')
+
+    case "$first" in
+        add|added|feat|feature|implement|introduce|create|new)
+            echo "Added" ;;
+        fix|fixed|bugfix|hotfix|resolve|patch|correct|repair)
+            echo "Fixed" ;;
+        change|changed|update|updated|modify|modified|refactor|rework|improve|enhance|upgrade|migrate|bump)
+            echo "Changed" ;;
+        remove|removed|delete|deleted|drop|dropped|deprecate|deprecate|clean|cleanup)
+            echo "Removed" ;;
+        *)
+            echo "Changed" ;;  # default bucket
+    esac
+}
+
+# ── main ────────────────────────────────────────────────────────────
+main() {
+    has_git || die "Error: git is not installed."
+
+    [[ -d ".git" ]] || die "Error: not inside a git repository."
+
+    local last_tag
+    last_tag=$(get_last_tag)
+
+    local commits
+    commits=$(get_commits_since "$last_tag")
+
+    [[ -n "$commits" ]] || die "No commits found since last tag."
+
+    local added="" fixed="" changed