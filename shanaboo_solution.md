 ```diff
--- /dev/null
+++ b/generate-changelog
@@ -0,0 +1,152 @@
+#!/usr/bin/env bash
+#
+# generate-changelog
+# Automatically generates a structured CHANGELOG.md from git history.
+#
+# Usage:
+#   ./generate-changelog              # Generates CHANGELOG.md from commits since last tag
+#   ./generate-changelog --help       # Shows usage information
+#
+# Features:
+# - Fetches commits since the last git tag
+# - Auto-categorizes into: Added / Fixed / Changed / Removed
+# - Outputs a properly formatted CHANGELOG.md
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
+# Show usage information
+usage() {
+    cat << 'EOF'
+Usage: ./generate-changelog [OPTIONS]
+
+Generate a structured CHANGELOG.md from git history.
+
+OPTIONS:
+    -h, --help          Show this help message and exit
+    -o, --output FILE   Output file (default: CHANGELOG.md)
+    -t, --tag TAG       Generate changelog from a specific tag
+    -a, --all           Include all commits (not just since last tag)
+
+EXAMPLES:
+    ./generate-changelog                    # Generate from last tag
+    ./generate-changelog -o HISTORY.md      # Output to HISTORY.md
+    ./generate-changelog -t v1.0.0         # Generate from v1.0.0
+    ./generate-changelog -a                # Include all commits
+
+EOF
+}
+
+# Parse arguments
+OUTPUT_FILE="CHANGELOG.md"
+SINCE_TAG=""
+ALL_COMMITS=false
+
+while [[ $# -gt 0 ]]; do
+    case $1 in
+        -h|--help)
+            usage
+            exit 0
+            ;;
+        -o|--output)
+            OUTPUT_FILE="$2"
+            shift 2
+            ;;
+        -t|--tag)
+            SINCE_TAG="$2"
+            shift 2
+            ;;
+        -a|--all)
+            ALL_COMMITS=true
+            shift
+            ;;
+        *)
+            echo -e "${RED}Error: Unknown option $1${NC}" >&2
+            usage
+            exit 1
+            ;;
+    esac
+done
+
+# Check if we're in a git repository
+if ! git rev-parse --git-dir > /dev/null 2>&1; then
+    echo -e "${RED}Error: Not a git repository${NC}" >&2
+    exit 1
+fi
+
+# Determine the range of commits
+if [ "$ALL_COMMITS" = true ]; then
+    COMMIT_RANGE="HEAD"
+    echo -e "${YELLOW}Generating changelog from all commits...${NC}"
+elif [ -n "$SINCE_TAG" ]; then
+    if ! git rev-parse "$ Kuz "$SINCE_TAG" > /dev/null 2>&1; then
+        echo -e "${RED}Error: Tag '$SINCE_TAG' not found${NC}" >&2
+        exit 1
+    fi
+    COMMIT_RANGE="${SINCE_TAG}..HEAD"
+    echo -e "${YELLOW}Generating changelog from $SINCE_TAG to HEAD...${NC}"
+else
+    # Get the latest tag
+    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
+    if [ -z "$LATEST_TAG" ]; then
+        echo -e "${YELLOW}No tags found. Using all commits.${NC}"
+        COMMIT_RANGE="HEAD"
+    else
+        COMMIT="$LATEST_TAG"
+        echo -e "${YELLOW}Generating changelog from $LATEST_TAG to HEAD...${NC}"
+        COMMIT_RANGE="${LATEST_TAG}..HEAD"
+    fi
+fi
+
+# Get commits with their messages
+if [ "$COMMIT_RANGE" = "HEAD" ] && [ "$ALL_COMMITS" = false ] && [ -z "$SINCE_TAG" ]; then
+    # No tags case - get all commits
+    COMMITS=$(git log --pretty=format:"%H|%s|%ad" --date=short)
+else
+    COMMITS=$(git log "$COMMIT_RANGE" --pretty=format:"%H|%s|%ad" --date=short)
+fi
+
+if [ -z "$COMMITS" ]; then
+    echo -e "${YELLOW}No commits found in the specified range.${NC}"
+    exit 0
+fi
+
+# Categorize commits
+ADDED=()
+FIXED=()
+CHANGED=()
+REMOVED=()
+
+while IFS='|' read -r HASH MESSAGE DATE; do
+    # Skip merge commits
+    [[ "$MESSAGE" == Merge* ]] && continue
+    
+    # Clean up the message
+    CLEAN_MESSAGE=$(echo "$MESSAGE" | sed 's/^[a-z]*(\([^)]*\)): //; s/^[a-z]*: //')
+    
+    # Categorize based on conventional commit prefixes or keywords
+    if [[ "$MESSAGE" =~ ^(feat|feature|add|create|implement|introduce)[:\(] ]] || \
+       [[ "$MESSAGE" =~ [Aa]dd ]] || \
+       [[ "$MESSAGE" =~ [Cc]reate ]] || \
+       [[ "$MESSAGE" =~ [Ii]mplement ]] || \
+       [[ "$MESSAGE" =~ [Ss]upport ]]; then
+        ADDED+=("$DATE - $CLEAN_MESSAGE")
+    elif [[ "$MESSAGE" =~ ^(fix|bugfix|hotfix|resolve)[:\(] ]] || \
+         [[ "$MESSAGE" =~ [Ff]ix ]] || \
+         [[ "$MESSAGE" =~ [Bb]ug ]] || \
+         [[ "$MESSAGE" =~ [Rr]esolve ]] || \
+         [[ "$MESSAGE" =~ [Cc]orrect ]]; then
+        FIXED+=("$DATE - $CLEAN_MESSAGE")
+    elif [[ "$MESSAGE" =~ ^(remove|delete|drop|eliminate)[:\(] ]] || \
+         [[ "$MESSAGE" =~ [Rr]emove ]] || \
+         [[ "$MESSAGE" =~ [Dd]elete ]] || \
+         [[ "$MESSAGE" =~ [Dd]rop ]] || \
+         [[ "$MESSAGE" =~ [Rr]emove ]]; then
+        REMOVED+=("$DATE - $CLEAN_MESSAGE")
+    elif [[ "$MESSAGE" =~ ^(change|update|modify|refactor|improve|enhance)[:\(] ]] || \
+         [[ "$MESSAGE"