 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,120 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+# changelog.sh — Generate a structured CHANGELOG.md from git history
+# Usage: bash changelog.sh
+
+CHANGELOG_FILE="CHANGELOG.md"
+REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
+if [[ -n "$REPO_URL" ]]; then
+    REPO_URL="${REPO_URL%.git}"
+fi
+
+# Get the latest tag, or empty if no tags exist
+LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+
+# Get commits since the last tag, or all commits if no tag
+if [[ -n "$LATEST_TAG" ]]; then
+    COMMITS=$(git log "$LATEST_TAG"..HEAD --pretty=format:"%H %s" 2>/dev/null || true)
+    VERSION_DATE=$(git log -1 --format=%cd --date=short "$LATEST_TAG" 2>/dev/null || date +%Y-%m-%d)
+else
+    COMMITS=$(git log --pretty=format:"%H %s" 2>/dev/null || true)
+    VERSION_DATE=$(date +%Y-%m-%d)
+fi
+
+# If no commits found, exit
+if [[ -z "$COMMITS" ]]; then
+    echo "No new commits found since last tag."
+    exit 0
+fi
+
+# Categorize commits
+ADDED=()
+FIXED=()
+CHANGED=()
+REMOVED=()
+OTHER=()
+
+while IFS= read -r line; do
+    [[ -z "$line" ]] && continue
+    HASH=$(echo "$line" | awk '{print $1}')
+    MESSAGE=$(echo "$line" | cut -d' ' -f2-)
+    SHORT_HASH="${HASH:0:7}"
+    
+    # Determine category based on conventional commit patterns
+    LOWER_MSG=$(echo "$MESSAGE" | tr '[:upper:]' '[:lower:]')
+    
+    if [[ "$LOWER_MSG" =~ ^(feat|add|create|implement|introduce) ]] || \
+       [[ "$LOWER_MSG" =~ (add|added|adding|new|introduce|implement).*: ]] || \
+       [[ "$LOWER_MSG" =~ ^[a-z]+\(.*\):.*add ]]; then
+        ADDED+=("- $MESSAGE — [\`$SHORT_HASH\`]($REPO_URL/commit/$HASH)")
+    elif [[ "$LOWER_MSG" =~ ^(fix|bugfix|hotfix|patch|resolve) ]] || \
+         [[ "$LOWER_MSG" =~ (fix|fixed|fixing|bug|patch|resolve|resolves).*: ]] || \
+         [[ "$LOWER_MSG" =~ ^[a-z]+\(.*\):.*fix ]]; then
+        FIXED+=("- $MESSAGE — [\`$SHORT_HASH\`]($REPO_URL/commit/$HASH)")
+    elif [[ "$LOWER_MSG" =~ ^(remove|delete|drop|revert|clean) ]] || \
+         [[ "$LOWER_MSG" =~ (remove|removed|removing|delete|deleted|drop|dropped|revert|reverted).*: ]] || \
+         [[ "$LOWER_MSG" =~ ^[a-z]+\(.*\):.*(remove|delete|drop) ]]; then
+        REMOVED+=("- $MESSAGE — [\`$SHORT_HASH\`]($REPO_URL/commit/$HASH)")
+    elif [[ "$LOWER_MSG" =~ ^(change|update|modify|refactor|improve|enhance|upgrade|bump) ]] || \
+         [[ "$LOWER_MSG" =~ (update|updated|updating|change|changed|changing|modify|modified|refactor|refactored|improve|improved|enhance|enhanced|upgrade|upgraded).*: ]] || \
+         [[ "$LOWER_MSG" =~ ^[a-z]+\(.*\):.*(update|change|modify|refactor|improve|enhance|upgrade) ]]; then
+        CHANGED+=("- $MESSAGE — [\`$SHORT_HASH\`]($REPO_URL/commit/$HASH)")
+    else
+        OTHER+=("- $MESSAGE — [\`$SHORT_HASH\`]($REPO_URL/commit/$HASH)")
+    fi
+done <<< "$COMMITS"
+
+# Build new changelog content
+NEW_ENTRY=""
+
+if [[ ${#ADDED[@]} -gt 0 ]]; then
+    NEW_ENTRY+=$'### Added\n\n'
+    for item in "${ADDED[@]}"; do
+        NEW_ENTRY+="$item"$'\n'
+    done
+    NEW_ENTRY+=$'\n'
+fi
+
+if [[ ${#CHANGED[@]} -gt 0 ]]; then
+    NEW_ENTRY+=$'### Changed\n\n'
+    for item in "${CHANGED[@]}"; do
+        NEW_ENTRY+="$item"$'\n'
+    done
+    NEW_ENTRY+=$'\n'
+fi
+
+if [[ ${#FIXED[@]} -gt 0 ]]; then
+    NEW_ENTRY+=$'### Fixed\n\n'
+    for item in "${FIXED[@]}"; do
+        NEW_ENTRY+="$item"$'\n'
+    done
+    NEW_ENTRY+=$'\n'
+fi
+
+if [[ ${#REMOVED[@]} -gt 0 ]]; then
+    NEW_ENTRY+=$'### Removed\n\n'
+    for item in "${REMOVED[@]}"; do
+        NEW_ENTRY+="$item"$'\n'
+    done
+    NEW_ENTRY+=$'\n'
+fi
+
+if [[ ${#OTHER[@]} -gt 0 ]]; then
+    NEW_ENTRY+=$'### Other\n\n'
+    for item in "${OTHER[@]}"; do
+        NEW_ENTRY+="$item"$'\n'
+    done
+    NEW_ENTRY+=$'\n'
+fi
+
+# Generate version header
+if [[ -n "$LATEST_TAG" ]]; then
+    NEXT_VERSION="$LATEST_TAG"
+else
+    NEXT_VERSION="v0.0.0"
+fi
+
+VERSION_HEADER="## [$NEXT_VERSION] - $VERSION_DATE"
+
+# Check if CHANGELOG.md exists
+if [[ -f "$CHANGELOG_FILE" ]]; then
+    # Prepend new entry after the header
+    EXISTING=$(cat "$CHANGELOG_FILE")
+    # Extract the title/header (everything before first ##)
+    HEADER=$(echo "$EXISTING" | sed -n '1,/^## /p' | sed '$d')
+    if [[ -z "$HEADER" ]]; then
+        HEADER="# Changelog"$'\n\n'"All notable changes to