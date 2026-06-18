Based on the issue, I need to create a PR review agent. Since the repo only has README.md and LICENSE, I'll create the necessary files for the Claude Code sub-agent that reviews PRs and posts structured comments.

```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,176 @@
+#!/usr/bin/env bash
+# Claude Code PR Review Agent
+# Usage: claude-review --pr https://github.com/owner/repo/pull/123
+#        claude-review --diff <file.diff>
+#        claude-review --repo owner/repo --pr 123
+
+set -euo pipefail
+
+# Colors for output
+RED='\033[0;31m'
+GREEN='\033[0;32m'
+YELLOW='\033[1;33m'
+BLUE='\033[0;34m'
+NC='\033[0m' # No Color
+
+print_usage() {
+    cat << EOF
+Claude Code PR Review Agent
+
+Usage:
+  claude-review --pr <PR_URL>              Review a PR from GitHub URL
+  claude-review --repo <owner/repo> --pr <PR_NUMBER>  Review using repo and PR number
+  claude-review --diff <file.diff>         Review a local diff file
+  claude-review --help                     Show this help message
+
+Options:
+  --pr <url>         GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)
+  --repo <owner/repo> Repository in owner/repo format
+  --pr-number <num>  PR number (requires --repo)
+  --diff <file>      Path to a local diff file
+  --output <file>    Write review to file instead of stdout
+  --confidence-only  Output only the confidence score
+  --help             Show this help message
+
+Environment Variables:
+  GITHUB_TOKEN       GitHub personal access token (optional, for private repos)
+EOF
+}
+
+# Parse arguments
+PR_URL=""
+REPO=""
+PR_NUMBER=""
+DIFF_FILE=""
+OUTPUT_FILE=""
+CONFIDENCE_ONLY=false
+
+while [[ $# -gt 0 ]]; do
+    case $1 in
+        --pr)
+            PR_URL="$2"
+            shift 2
+            ;;
+        --repo)
+            REPO="$2"
+            shift 2
+            ;;
+        --pr-number)
+            PR_NUMBER="$2"
+            shift 2
+            ;;
+        --diff)
+            DIFF_FILE="$2"
+            shift 2
+            ;;
+        --output)
+            OUTPUT_FILE="$2"
+            shift 2
+            ;;
+        --confidence-only)
+            CONFIDENCE_ONLY=true
+            shift
+            ;;
+        --help)
+            print_usage
+            exit 0
+            ;;
+        *)
+            echo -e "${RED}Error: Unknown option: $1${NC}"
+            print_usage
+            exit 1
+            ;;
+    esac
+done
+
+# Extract repo and PR number from URL if provided
+if [[ -n "$PR_URL" ]]; then
+    if [[ "$PR_URL" =~ github\.com/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
+        REPO="${BASH_REMATCH[1]}"
+        PR_NUMBER="${BASH_REMATCH[2]}"
+    else
+        echo -e "${RED}Error: Invalid PR URL format. Expected: https://github.com/owner/repo/pull/123${NC}"
+        exit 1
+    fi
+fi
+
+# Validate inputs
+if [[ -z "$DIFF_FILE" ]] && [[ -z "$REPO" || -z "$PR_NUMBER" ]]; then
+    echo -e "${RED}Error: Either --diff or both --repo and --pr-number (or --pr) are required${NC}"
+    print_usage
+    exit 1
+fi
+
+# Create temp directory for diff
+TEMP_DIR=$(mktemp -d)
+trap 'rm -rf "$TEMP_DIR"' EXIT
+
+DIFF_CONTENT=""
+
+if [[ -n "$DIFF_FILE" ]]; then
+    # Read from local diff file
+    if [[ ! -f "$DIFF_FILE" ]]; then
+        echo -e "${RED}Error: Diff file not found: $DIFF_FILE${NC}"
+        exit 1
+    fi
+    DIFF_CONTENT=$(cat "$DIFF_FILE")
+else
+    # Fetch diff from GitHub API
+    echo -e "${BLUE}Fetching PR #${PR_NUMBER} from ${REPO}...${NC}" >&2
+    
+    API_URL="https://api.github.com/repos/${REPO}/pulls/${PR_NUMBER}"
+    AUTH_HEADER=""
+    
+    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
+        AUTH_HEADER="-H Authorization: Bearer ${GITHUB_TOKEN}"
+    fi
+    
+    # Fetch PR details
+    PR_DATA=$(curl -s ${AUTH_HEADER} "$API_URL")
+    
+    if echo "$PR_DATA" | grep -q '"message":"Not Found"'; then
+        echo -e "${RED}Error: PR not found. Check the URL and your permissions.${NC}"
+        exit 1
+    fi
+    
+    PR_TITLE=$(echo "$PR_DATA" | grep -o '"title": *"[^"]*"' | head -1 | sed 's/"title": *"//;s/"$//')
+    PR_BODY=$(echo "$PR_DATA" | grep -o '"body": *"[^"]*"' | head -1 | sed 's/"body": *"//;s/"$//')
+    
+    # Fetch the diff
+    DIFF_URL="${API_URL}.diff"
+    DIFF_CONTENT=$(curl -s ${AUTH_HEADER} -H "Accept: application/vnd.github.v3.diff" "$DIFF_URL")
+    
+    if [[ -z "$DIFF_CONTENT" ]]; then
+        echo -e "${RED}Error: Failed to fetch diff or diff is empty${NC}"
+        exit 1
+    fi
+fi
+
+# Save diff to temp file for Claude
+DIFF_TEMP_FILE="$TEMP_DIR/pr_diff.diff"
+echo "$DIFF_CONTENT" > "$DIFF_TEMP_FILE"
+
+# Build the Claude prompt
