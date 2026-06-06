 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,77 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# A script to generate a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage: ./generate-changelog
+#
+
+set -euo pipefail
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
+get_commits() {
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
+    if echo "$lower_msg" | grep -qE "^(feat|add|added|new|introduce|implement|create|support)"; then
+        echo "Added"
+    elif echo "$lower_msg" | grep -qE "^(fix|fixed|bugfix|hotfix|resolve|patch|correct)"; then
+        echo "Fixed"
+    elif echo "$lower_msg" | grep -qE "^(remove|removed|delete|deleted|drop|deprecate|revert)"; then
+        echo "Removed"
+    elif echo "$lower_msg" | grep -qE "^(change|changed|update|updated|modify|modified|refactor|improve|enhance|upgrade|rework|optimize)"; then
+        echo "Changed"
+    else
+        echo "Changed"
+    fi
+}
+
+# Main
+main() {
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo "Error: Not a git repository." >&2
+        exit 1
+    fi
+
+    local tag
+    tag=$(get_latest_tag)
+
+    local range_desc="all commits"
+    if [ -n "$tag" ]; then
+        range_desc="commits since $tag"
+    fi
+
+    {
+        echo "# Changelog"
+        echo ""
+        echo "## Unreleased ($range_desc)"
+        echo ""
+
+        for category in Added Fixed Changed Removed; do
+            echo "### $category"
+            echo ""
+        done
+    } > CHANGELOG.md
+
+    echo "CHANGELOG.md generated successfully."
+}
+
+main "$@"
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,77 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# A script to generate a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage: ./generate-changelog
+#
+
+set -euo pipefail
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
+get_commits() {
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
+    if echo "$lower_msg" | grep -qE "^(feat|add|added|new|introduce|implement|create|support)"; then
+        echo "Added"
+    elif echo "$lower_msg" | grep -qE "^(fix|fixed|bugfix|hotfix|resolve|patch|correct)"; then
+        echo "Fixed"
+    elif echo "$lower_msg" | grep -qE "^(remove|removed|delete|deleted|drop|deprecate|revert)"; then
+        echo "Removed"
+    elif echo "$lower_msg" | grep -qE "^(change|changed|update|updated|modify|modified|refactor|improve|enhance|upgrade|rework|optimize)"; then
+        echo "Changed"
+    else
+        echo "Changed"
+    fi
+}
+
+# Main
+main() {
+    if ! git rev-parse --git-dir > /dev/null 2>&1; then
+        echo "Error: Not a git repository." >&2
+        exit 1
+    fi
+
+    local tag
+    tag=$(get_latest_tag)
+
+    local range_desc="all commits"
+    if [ -n "$tag" ]; then
+        range_desc="commits since $tag"
+    fi
+
+    {
+        echo "# Changelog"
+        echo ""
+        echo "## Unreleased ($range_desc)"
+        echo ""
+
+        for category in Added Fixed Changed Removed; do
+            echo "### $category"
+            echo ""
+        done
+    } > CHANGELOG.md
+
+    echo "CHANGELOG.md generated successfully."
+}
+
+main "$@"
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,77 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# A script to generate a structured CHANGELOG.md from git history.
+# Fetches commits since the last git tag and auto-categorizes them.
+#
+# Usage: ./generate-changelog
+#
+
+set -euo pipefail
+
+# Get the latest git tag
+get_latest_tag() {
+    git describe --tags --abbrev=0 2>/dev/null || echo ""
+}
+
+# Get commits since the last tag (or all commits if no tag exists)
+get_commits() {
+    local tag="$1"
+    if [ -n "$tag" ]; then
+        git log "${tag}..HEAD" --pretty=format:"%s" 2>/dev/null || true
+    else
+        git log --pretty=format:"%s