```diff
--- /dev/null
+++ b/hooks/pre-tool-use
@@ -0,0 +1,0 @@
+#!/usr/bin/env python3
+"""
+Claude Code pre-tool-use hook that intercepts dangerous bash commands.
+Blocks destructive patterns like rm -rf, DROP TABLE, git push --force, etc.
+Logs blocked attempts to ~/.claude/hooks/blocked.log
+"""
+
+import json
+import os
+import re
+import sys
+from datetime import datetime, timezone
+
+LOG_FILE = os.path.expanduser("~/.claude/hooks/blocked.log")
+
+# Patterns that will be blocked (case-insensitive)
+DANGEROUS_PATTERNS = [
+    # rm -rf variations
+    (r'\brm\s+.*-rf\b', 'rm -rf (recursive force remove)'),
+    (r'\brm\s+.*-r\s+.*-f\b', 'rm -r -f (recursive force remove)'),
+    (r'\brm\s+.*--recursive\s+.*--force\b', 'rm --recursive --force'),
+    # DROP TABLE
+    (r'\bDROP\s+TABLE\b', 'DROP TABLE (destroys database table)'),
+    # git push --force variations
+    (r'\bgit\s+push\s+.*--force\b', 'git push --force (force push)'),
+    (r'\bgit\s+push\s+.*-f\b', 'git push -f (force push)'),
+    # TRUNCATE
+    (r'\bTRUNCATE\s+(TABLE\s+)?', 'TRUNCATE (removes all rows from table)'),
+    # DELETE FROM without WHERE clause
+    (r'\bDELETE\s+FROM\s+\S+(?!.*\bWHERE\b)', 'DELETE FROM without WHERE (deletes all rows)'),
+]
+
+
+def log_blocked(tool_name, command, project_path):
+    """Log a blocked command attempt to the log file."""
+    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
+    timestamp = datetime.now(timezone.utc).isoformat()
+    entry = {
+        "timestamp": timestamp,
+        "tool": tool_name,
+        "attempted_command": command,
+        "project_path": project_path,
+    }
+    with open(LOG_FILE, "a") as f:
+        f.write(json.dumps(entry) + "\n")
+
+
+def check_command(command):
+    """Check a command against dangerous patterns. Returns (is_dangerous, reason)."""
+    if not command:
+        return False, None
+    for pattern, reason in DANGEROUS_PATTERNS:
+        if re.search(pattern, command, re.IGNORECASE):
+            return True, reason
+    return False, None
+
+
+def main():
+    # Read the hook input from stdin (JSON)
+    try:
+        hook_input = json.load(sys.stdin)
+    except json.JSONDecodeError:
+        # If we can't parse input, allow the tool to proceed
+        sys.exit(0)
+
+    tool_name = hook_input.get("tool_name", "")
+    tool_input = hook_input.get("tool_input", {})
+
+    # Only intercept Bash commands
+    if tool_name != "Bash":
+        sys.exit(0)
+
+    command = tool_input.get("command", "")
+    project_path = hook_input.get("cwd", os.getcwd())
+
+    is_dangerous, reason = check_command(command)
+
+    if is_dangerous:
+        log_blocked(tool_name, command, project_path)
+
+        # Output a clear message to Claude explaining why the command was blocked
+        output = {
+            "decision": "block",
+            "reason": f"Blocked dangerous command: {reason}",
+            "message": (
+                f"⚠️  This command was blocked by the pre-tool-use security hook.\n"
+                f"Pattern matched: {reason}\n"
+                f"Attempted command: {command}\n"
+                f"If you believe this is a false positive, review the command and try a safer alternative."
+            ),
+        }
+        print(json.dumps(output))
+        sys.exit(2)  # Non-zero exit blocks the tool
+
+    # Allow the command to proceed
+    sys.exit(0)
+
+
+if __name__ == "__main__":
+    main()
+
--- a/README.md
+++ b/README.md
@@ -1,0 +1,0 @@
 # Claude Builders Bounty 🤖
 
 > A community bounty board for Claude Code builders.
 
 Building with Claude Code? Have tasks to delegate?
 Want to get paid for contributing to AI projects?
 You're in the right place.
 
 ---
 
 ## How it works
 
 **To post a bounty**
 1. Open a GitHub issue with a clear description and acceptance criteria
 2. Comment `/opire create $XXX` in the issue to set the reward
 3. Share the link — contributors will find it
 
 **To claim a bounty**
 1. Browse the open issues below
 2. Comment `/opire try` in the issue you want to work on
 3. Submit a PR — payment is automatic on merge ✅
 
 ---
 
 ## Active Bounties
 
 | # | Task | Amount | Status |
 |---|------|--------|--------|
 | [#1](../../issues/1) | SKILL: Generate a CHANGELOG from git history | $50 | 🟢 Open |
 | [#2](../../issues/2) | TEMPLATE: CLAUDE.md for a Next.js + SQLite project | $75 | 🟢 Open |
 | [#3](../../issues/3) | HOOK: Block destructive bash commands in Claude Code | $100 | 🟢 Open |
 | [#4](../../issues/4) | AGENT: PR reviewer with structured Markdown output | $150 | 🟢 Open |
 | [#5](../../issues/5) | WORKFLOW: n8n + Claude API — automated weekly dev summary | $200 | 🟢 Open |
 
 ---
 
 ## Rules
 
 - Tasks must be related to Claude Code or AI tooling
 - Every issue must have clear acceptance criteria before a bounty is activated
 - Payment is handled by [Opire](https://opire.dev) (Stripe)
 - Quality over speed — a solid PR beats a fast one
 
 ---
 
 ## Community
 
 - 🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
 - 📧 Contact: claudeb