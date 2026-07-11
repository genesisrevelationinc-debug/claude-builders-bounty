```diff
--- /dev/null
+++ b/hooks/pre-tool-use
@@ -0,0 +1,149 @@
+#!/usr/bin/env python3
+"""
+Claude Code pre-tool-use hook that intercepts and blocks destructive bash commands.
+
+Blocks patterns:
+  - rm -rf (and variants like rm -r, rm -rf --no-preserve-root, etc.)
+  - DROP TABLE / DROP DATABASE
+  - git push --force / git push -f / git push --force-with-lease (to main/master)
+  - TRUNCATE TABLE
+  - DELETE FROM without a WHERE clause
+
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
+# Patterns that will be blocked
+DESTRUCTIVE_PATTERNS = [
+    # rm -rf and variants
+    (re.compile(r'\brm\s+.*(-r\b|-rf\b|--recursive\b)', re.IGNORECASE),
+     "rm with recursive flag — can delete entire directory trees"),
+
+    # DROP TABLE / DROP DATABASE
+    (re.compile(r'\bDROP\s+(TABLE|DATABASE|SCHEMA)\b', re.IGNORECASE),
+     "DROP TABLE/DATABASE/SCHEMA — irreversible data destruction"),
+
+    # git push --force / -f to main or master
+    (re.compile(r'\bgit\s+push\s+.*(--force\b|-f\b|--force-with-lease\b)', re.IGNORECASE),
+     "git push --force — can overwrite remote history"),
+
+    # TRUNCATE TABLE
+    (re.compile(r'\bTRUNCATE\s+(TABLE\s+)?\S+', re.IGNORECASE),
+     "TRUNCATE TABLE — removes all rows without possibility of rollback in some engines"),
+
+    # DELETE FROM without WHERE clause
+    (re.compile(r'\bDELETE\s+FROM\s+\S+', re.IGNORECASE),
+     "DELETE FROM — check for missing WHERE clause"),
+]
+
+# DELETE FROM is only blocked if there is no WHERE clause
+DELETE_FROM_PATTERN = re.compile(r'\bDELETE\s+FROM\s+\S+', re.IGNORECASE)
+WHERE_PATTERN = re.compile(r'\bWHERE\b', re.IGNORECASE)
+
+
+def log_blocked(command: str, project_path: str, reason: str) -> None:
+    """Log a blocked command attempt to the log file."""
+    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
+    timestamp = datetime.now(timezone.utc).isoformat()
+    entry = {
+        "timestamp": timestamp,
+        "attempted_command": command,
+        "project_path": project_path,
+        "reason": reason,
+    }
+    with open(LOG_FILE, "a") as f:
+        f.write(json.dumps(entry) + "\n")
+
+
+def is_destructive(command: str) -> tuple[bool, str]:
+    """
+    Check if a command matches any destructive pattern.
+    Returns (is_destructive, reason_string).
+    """
+    # Special handling for DELETE FROM — only block if no WHERE clause
+    if DELETE_FROM_PATTERN.search(command):
+        if not WHERE_PATTERN.search(command):
+            return True, "DELETE FROM without WHERE clause — would delete all rows"
+        # Has WHERE clause, allow it
+        return False, ""
+
+    for pattern, reason in DESTRUCTIVE_PATTERNS:
+        if pattern.search(command):
+            return True, reason
+
+    return False, ""
+
+
+def main():
+    # Claude Code passes hook input as JSON on stdin
+    try:
+        hook_input = json.load(sys.stdin)
+    except json.JSONDecodeError:
+        # If no valid JSON, exit cleanly (don't block)
+        sys.exit(0)
+
+    # Extract the command and project path
+    # Claude Code hook format: {"tool_name": "Bash", "tool_input": {"command": "..."}, "cwd": "..."}
+    tool_name = hook_input.get("tool_name", "")
+    if tool_name != "Bash":
+        # Not a bash command — allow
+        sys.exit(0)
+
+    tool_input = hook_input.get("tool_input", {})
+    command = tool_input.get("command", "")
+    project_path = hook_input.get("cwd", os.getcwd())
+
+    if not command:
+        sys.exit(0)
+
+    destructive, reason = is_destructive(command)
+
+    if destructive:
+        # Log the blocked attempt
+        log_blocked(command, project_path, reason)
+
+        # Output a clear message to Claude (goes to stderr so Claude sees it)
+        message = (
+            f"\n"
+            f"╔══════════════════════════════════════════════════════════════╗\n"
+            f"║  ⛔ DESTRUCTIVE COMMAND BLOCKED                              ║\n"
+            f"╠══════════════════════════════════════════════════════════════╣\n"
+            f"║  Command: {command[:50]}...\n"
+            f"║  Reason:  {reason}\n"
+            f"║                                                              ║\n"
+            f"║  This command could cause irreversible damage.               ║\n"
+            f"║  If you are absolutely sure you need to run this,            ║\n"
+            f"║  please review the command manually and run it outside       ║\n"
+            f"║  of Claude Code, or modify the hook configuration.           ║\n"
+            f"╚══════════════════════════════════════════════════════════════╝\n"
+        )
+        print(message, file=sys.stderr)
+
+        # Exit with non-zero to block the tool call
+        sys.exit(1)
+
+    # Allow the command
+    sys.exit(0)
+
+
+if __name__ == "__main__":
+    main()
+
--- /dev/null
+++ b/hooks/README.md
@@ -0,0 +1