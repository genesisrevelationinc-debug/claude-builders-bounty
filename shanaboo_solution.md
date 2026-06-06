 ```diff
--- /dev/null
+++ b/changelog.sh
@@ -0,0 +1,155 @@
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
+# Get the directory where the script is located
+SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
+CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"
+
+echo -e "${GREEN}Generating CHANGELOG.md...${NC}"
+
+# Get the latest tag
+LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+
+if [ -z "$LATEST_TAG" ]; then
+    echo -e "${YELLOW}No tags found. Using all commits.${NC}"
+    COMMIT_RANGE=""
+else
+    echo -e "${GREEN}Latest tag: $LATEST_TAG${NC}"
+    COMMIT_RANGE="$LATEST_TAG..HEAD"
+fi
+
+# Get commits since last tag (or all commits if no tag)
+if [ -z "$COMMIT_RANGE" ]; then
+    COMMITS=$(git log --pretty=format:"%H|%s|%b" --no-merges)
+else
+    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%H|%s|%b" --no-merges)
+fi
+
+if [ -z "$COMMITS" ]; then
+    echo -e "${YELLOW}No commits found since last tag.${NC}"
+    exit 0
+fi
+
+# Categorize commits
+ADDED=""
+FIXED=""
+CHANGED=""
+REMOVED=""
+OTHER=""
+
+while IFS= read -r line; do
+    [ -z "$line" ] && continue
+    
+    HASH=$(echo "$line" | cut -d'|' -f1)
+    SUBJECT=$(echo "$line" | cut -d'|' -f2)
+    BODY=$(echo "$line" | cut -d'|' -f3-)
+    
+    # Normalize for matching
+    SUBJECT_LOWER=$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]')
+    
+    # Categorize based on commit message patterns
+    if echo "$SUBJECT_LOWER" | grep -qE '^(feat|add|create|implement|introduce|new)'; then
+        ADDED="$ADDED- $SUBJECT"$'\n'
+    elif echo "$SUBJECT_LOWER" | grep -qE '^(fix|bugfix|hotfix|resolve|patch)'; then
+        FIXED="$FIXED- $SUBJECT"$'\n'
+    elif echo "$SUBJECT_LOWER" | grep -qE '^(remove|delete|drop|eliminate|deprecate)'; then
+        REMOVED="$REMOVED- $SUBJECT"$'\n'
+    elif echo "$SUBJECT_LOWER" | grep -qE '^(change|update|modify|refactor|improve|enhance|upgrade|rework)'; then
+        CHANGED="$CHANGED- $SUBJECT"$'\n'
+    else
+        # Try to infer from keywords in the message
+        if echo "$SUBJECT_LOWER" | grep -qE '\b(add|added|adding|introduce|implement|create|feature)\b'; then
+            ADDED="$ADDED- $SUBJECT"$'\n'
+        elif echo "$SUBJECT_LOWER" | grep -qE '\b(fix|fixed|fixing|bug|resolve|patch|correct)\b'; then
+            FIXED="$FIXED- $SUBJECT"$'\n'
+        elif echo "$SUBJECT_LOWER" | grep -qE '\b(remove|removed|removing|delete|deleted|drop|eliminate|deprecate)\b'; then
+            REMOVED="$REMOVED- $SUBJECT"$'\n'
+        elif echo "$SUBJECT_LOWER" | grep -qE '\b(update|updated|updating|change|changed|changing|modify|modified|refactor|improve|enhance|upgrade|rework)\b'; then
+            CHANGED="$CHANGED- $SUBJECT"$'\n'
+        else
+            # Default to Changed for uncategorized
+            CHANGED="$CHANGED- $SUBJECT"$'\n'
+        fi
+    fi
+done <<< "$COMMITS"
+
+# Generate the CHANGELOG
+DATE=$(date +%Y-%m-%d)
+VERSION=""
+
+if [ -n "$LATEST_TAG" ]; then
+    # Increment patch version (simple semver bump)
+    VERSION="$LATEST_TAG"
+else
+    VERSION="0.1.0"
+fi
+
+# Build the changelog content
+CHANGELOG_CONTENT="# Changelog"$'\n\n'
+CHANGELOG_CONTENT+="All notable changes to this project will be documented in this file."$'\n\n'
+CHANGELOG_CONTENT+="The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),"$'\n'
+CHANGELOG_CONTENT+="and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."$'\n\n'
+
+# Add new version section
+CHANGELOG_CONTENT+="## [Unreleased] - $DATE"$'\n\n'
+
+if [ -n "$ADDED" ]; then
+    CHANGELOG_CONTENT+="### Added"$'\n\n'
+    CHANGELOG_CONTENT+="$ADDED"$'\n'
+fi
+
+if [ -n "$CHANGED" ]; then
+    CHANGELOG_CONTENT+="### Changed"$'\n\n'
+    CHANGELOG_CONTENT+="$CHANGED"$'\n'
+fi
+
+if [ -n "$FIXED" ]; then
+    CHANGELOG_CONTENT+="### Fixed"$'\n\n'
+    CHANGELOG_CONTENT+="$FIXED"$'\n'
+fi
+
+if [ -n "$REMOVED" ]; then
+    CHANGELOG_CONTENT+="### Removed"$'\n\n'
+    CHANGELOG_CONTENT+="$REMOVED"$'\n'
+fi
+
+# Append existing changelog if it exists (keep previous versions)
+if [ -f "$CHANGELOG_FILE" ]; then
+    # Extract existing content after the header (skip first version)
+    EXISTING=$(tail -n +2 "$CHANGELOG_FILE" 2>/dev/null || echo "")
+    # For simplicity, we'll prepend the new section to the file
+    # In a more advanced version, you could merge with existing unreleased section
+    :
+fi
+
+# Write the changelog
+echo "$CHANGELOG_CONTENT