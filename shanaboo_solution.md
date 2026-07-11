```diff
--- /dev/null
+++ b/hooks/pre-tool-use
@@ -0,0 +1,131 @@
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
+LOG_DIR = os.path.expanduser("~/.claude/hooks")
+LOG_FILE = os.path.join(LOG_DIR, "blocked.log")
+
+DANGEROUS_PATTERNS = [
+    # rm -rf variants
+    (re.compile(r'\brm\s+.*-rf\b', re.IGNORECASE),
+     "rm -rf is destructive and can permanently delete files/directories"),
+    (re.compile(r'\brm\s+.*--recursive\s+.*--force\b', re.IGNORECASE),
+     "rm --recursive --force is destructive and can permanently delete files/directories"),
+    (re.compile(r'\brm\s+.*-r\s+.*-f\b', re.IGNORECASE),
+     "rm -r -f is destructive and can permanently delete files/directories"),
+
+    # DROP TABLE / TRUNCATE
+    (re.compile(r'\bDROP\s+TABLE\b', re.IGNORECASE),
+     "DROP TABLE permanently deletes a database table and all its data"),
+    (re.compile(r'\bTRUNCATE\s+(TABLE\s+)?\b', re.IGNORECASE),
+     "TRUNCATE permanently removes all rows from a database table"),
+
+    # DELETE FROM without WHERE
+    (re.compile(r'\bDELETE\s+FROM\s+\w+', re.IGNORECASE),
+     "DELETE FROM without a WHERE clause will delete all rows in the table"),
+
+    # git push --force variants
+    (re.compile(r'\bgit\s+push\s+.*--force\b', re.IGNORECASE),
+     "git push --force can overwrite remote history and cause data loss for collaborators"),
+    (re.compile(r'\bgit\s+push\s+.*-f\b', re.IGNORECASE),
+     "git push -f can overwrite remote history and cause data loss for collaborators"),
+    (re.compile(r'\bgit\s+push\s+.*--force-with-lease\b', re.IGNORECASE),
+     "git push --force-with-lease can still overwrite remote history; use with caution"),
+    (re.compile(r'\bgit\s+push\s+.*--delete\b', re.IGNORECASE),
+     "git push --delete permanently removes a remote branch"),
+]
+
+
+def is_delete_without_where(command: str) -> bool:
+    """Check if a DELETE FROM statement lacks a WHERE clause."""
+    match = re.search(r'\bDELETE\s+FROM\s+\w+', command, re.IGNORECASE)
+    if not match:
+        return False
+    # Get the portion of the command after DELETE FROM <table>
+    after_delete = command[match.end():]
+    # Check if WHERE appears anywhere after (case-insensitive)
+    if re.search(r'\bWHERE\b', after_delete, re.IGNORECASE):
+        return False
+    return True
+
+
+def get_project_path() -> str:
+    """Get the current working directory as the project path."""
+    try:
+        return os.getcwd()
+    except Exception:
+        return "unknown"
+
+
+def log_blocked(command: str, reason: str, project_path: str) -> None:
+    """Log a blocked command attempt to the log file."""
+    os.makedirs(LOG_DIR, exist_ok=True)
+    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
+    log_entry = {
+        "timestamp": timestamp,
+        "attempted_command": command,
+        "reason": reason,
+        "project_path": project_path,
+    }
+    try:
+        with open(LOG_FILE, "a") as f:
+            f.write(json.dumps(log_entry) + "\n")
+    except Exception as e:
+        print(f"Warning: Could not write to log file: {e}", file=sys.stderr)
+
+
+def main():
+    # Read the hook input from stdin
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
+        # Allow all other tools to proceed
+        print(json.dumps({"continue": True}))
+        sys.exit(0)
+
+    command = tool_input.get("command", "")
+    if not command:
+        print(json.dumps({"continue": True}))
+        sys.exit(0)
+
+    project_path = get_project_path()
+
+    # Check against dangerous patterns
+    for pattern, reason in DANGEROUS_PATTERNS:
+        if pattern.search(command):
+            # Special handling for DELETE FROM — must lack WHERE
+            if "DELETE FROM" in reason:
+                if not is_delete_without_where(command):
+                    continue
+
+            log_blocked(command, reason, project_path)
+            print(json.dumps({
+                "continue": False,
+                "reason": f"BLOCKED: {reason}\nCommand: {command}\nThis attempt has been logged."
+            }))
+            sys.exit(0)
+
+    # Command is safe — allow it
+    print(json.dumps({"continue": True}))
+    sys.exit(0)
+
+
+if __name__ == "__main__":
+    main()
--- a/README.md
+++ b/README.md
@@ -1,3 +1,5 @@
+<!-- BEGIN_OPIRE_BOUNTY -->
+
 # Claude Builders Bounty 🤖
 
 > A community bounty board for Claude Code builders.
@@ -48,3 +50,35 @@
 ---
 
 *Started by the Claude builder community · March 2026 · MIT License*
+
+<!-- END_OPIRE_BO