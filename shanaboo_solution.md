Based on the issue, I need to create a Claude Code agent that reviews PRs and posts structured Markdown comments. Since the repo only shows README.md and LICENSE, I'll create the necessary files for the agent.

```diff
--- /dev/null
+++ b/claude-review
@@ -0,0 +1,186 @@
+#!/usr/bin/env bash
+# Claude Code PR Review Agent
+# Usage: claude-review --pr https://github.com/owner/repo/pull/123
+#        claude-review --diff <file.diff>
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
+Usage: claude-review [OPTIONS]
+
+Options:
+  --pr <URL>         GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)
+  --diff <FILE>      Path to a local diff file
+  --output <FILE>    Write review to file (default: stdout)
+  --post-comment     Post review as PR comment (requires GITHUB_TOKEN)
+  --help             Show this help message
+
+Examples:
+  claude-review --pr https://github.com/owner/repo/pull/123
+  claude-review --diff changes.diff --output review.md
+  claude-review --pr https://github.com/owner/repo/pull/123 --post-comment
+EOF
+}
+
+# Parse arguments
+PR_URL=""
+DIFF_FILE=""
+OUTPUT_FILE=""
+POST_COMMENT=false
+
+while [[ $# -gt 0 ]]; do
+    case "$1" in
+        --pr)
+            PR_URL="$2"
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
+        --post-comment)
+            POST_COMMENT=true
+            shift
+            ;;
+        --help)
+            print_usage
+            exit 0
+            ;;
+        *)
+            echo -e "${RED}Unknown option: $1${NC}"
+            print_usage
+            exit 1
+            ;;
+    esac
+done
+
+# Validate input
+if [[ -z "$PR_URL" && -z "$DIFF_FILE" ]]; then
+    echo -e "${RED}Error: Must provide either --pr or --diff${NC}"
+    print_usage
+    exit 1
+fi
+
+# Fetch diff from PR URL
+if [[ -n "$PR_URL" ]]; then
+    echo -e "${BLUE}Fetching diff from $PR_URL...${NC}" >&2
+    
+    # Extract owner/repo/pull/number from URL
+    if [[ "$PR_URL" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
+        OWNER="${BASH_REMATCH[1]}"
+        REPO="${BASH_REMATCH[2]}"
+        PR_NUMBER="${BASH_REMATCH[3]}"
+    else
+        echo -e "${RED}Error: Invalid GitHub PR URL format${NC}"
+        exit 1
+    fi
+    
+    DIFF_CONTENT=$(curl -sL "https://github.com/${OWNER}/${REPO}/pull/${PR_NUMBER}.diff" || true)
+    
+    if [[ -z "$DIFF_CONTENT" ]]; then
+        echo -e "${RED}Error: Failed to fetch diff from GitHub${NC}"
+        exit 1
+    fi
+    
+    # Save to temp file for Claude
+    TEMP_DIFF=$(mktemp)
+    echo "$DIFF_CONTENT" > "$TEMP_DIFF"
+    DIFF_FILE="$TEMP_DIFF"
+    trap "rm -f $TEMP_DIFF" EXIT
+fi
+
+# Verify diff file exists
+if [[ ! -f "$DIFF_FILE" ]]; then
+    echo -e "${RED}Error: Diff file not found: $DIFF_FILE${NC}"
+    exit 1
+fi
+
+DIFF_CONTENT=$(cat "$DIFF_FILE")
+
+echo -e "${GREEN}Analyzing diff with Claude Code...${NC}" >&2
+
+# Build the prompt for Claude
+PROMPT=$(cat << 'CLAUDE_PROMPT'
+You are an expert code reviewer. Analyze the following git diff and produce a structured Markdown review.
+
+Your review MUST follow this exact format:
+
+## 📋 PR Review
+
+### Summary
+[2-3 sentences summarizing what this PR changes, the scope, and the overall approach]
+
+### Identified Risks
+- [Risk 1: specific concern with file/line reference if possible]
+- [Risk 2: ...]
+- [Risk 3: ...]
+[List at least 2-3 risks. If no risks found, state "No significant risks identified."]
+
+### Improvement Suggestions
+- [Suggestion 1: actionable improvement]
+- [Suggestion 2: ...]
+- [Suggestion 3: ...]
+[List at least 2-3 suggestions. Be constructive and specific.]
+
+### Confidence Score
+**Confidence: [Low / Medium / High]**
+[One sentence explaining the confidence level]
+
+Rules:
+- Be concise but thorough
+- Reference specific files and line numbers when possible
+- Focus on logic, security, performance, and maintainability
+- Do NOT comment on formatting/style unless it's a real problem
+- If the diff is empty or trivial, state that clearly
+
+Here is the diff to review:
+
+CLAUDE_PROMPT
+)
+
+# Combine prompt with diff
+FULL_PROMPT="${PROMPT}\n\n\`\`\`diff\n${DIFF_CONTENT}\n\`\`\`"
+
+# Check if Claude CLI is available
+if command -v claude &> /dev/null; then
+    REVIEW=$(echo -e "$FULL_PROMPT" | claude --print 2>/dev/null || true)
+elif command -v claude-code &> /dev/null; then
+    REVIEW=$(echo -e "$FULL_PROMPT" | claude-code --print 2>/dev/null || true)
+else
+    echo -e "${Y