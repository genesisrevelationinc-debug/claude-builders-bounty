```diff
--- /dev/null
+++ b/hooks/pre-tool-use
@@ -0,0 +1,148 @@
+#!/usr/bin/env python3
+"""
+Claude Code pre-tool-use hook that intercepts dangerous bash commands.
+
+Blocks destructive patterns like rm -rf, DROP TABLE, git push --force,
+TRUNCATE, and DELETE FROM without a WHERE clause.
+
+Installation:
+    mkdir -p ~/.claude/hooks
+    cp hooks/pre-tool-use ~/.claude/hooks/pre-tool-use
+    chmod +x ~/.claude/hooks/pre-tool-use
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
+DANGEROUS_PATTERNS = [
+    # rm -rf variations
+    (re.compile(r'\brm\s+.*-rf\b', re.IGNORECASE),
+     "Destructive deletion: 'rm -rf' can permanently delete files without confirmation"),
+    (re.compile(r'\brm\s+.*--recursive\s+.*--force\b', re.IGNORECASE),
+     "Destructive deletion: 'rm --recursive --force' can permanently delete files without confirmation"),
+    (re.compile(r'\brm\s+.*-r\s+.*-f\b', re.IGNORECASE),
+     "Destructive deletion: 'rm -r -f' can permanently delete files without confirmation"),
+
+    # DROP TABLE / DROP DATABASE
+    (re.compile(r'\bDROP\s+(TABLE|DATABASE|SCHEMA)\b', re.IGNORECASE),
+     "Destructive SQL: 'DROP TABLE/DATABASE/SCHEMA' permanently removes data structures"),
+
+    # TRUNCATE
+    (re.compile(r'\bTRUNCATE\s+(TABLE\s+)?\w+', re.IGNORECASE),
+     "Destructive SQL: 'TRUNCATE' removes all rows from a table without logging individual deletions"),
+
+    # DELETE FROM without WHERE
+    (re.compile(r'\bDELETE\s+FROM\s+\w+(?!.*\bWHERE\b)', re.IGNORECASE),
+     "Destructive SQL: 'DELETE FROM' without a WHERE clause will delete all rows in the table"),
+
+    # git push --force variations
+    (re.compile(r'\bgit\s+push\s+.*(--force|-f)\b', re.IGNORECASE),
+     "Destructive git operation: 'git push --force' can overwrite remote history and cause data loss for collaborators"),
+    (re.compile(r'\bgit\s+push\s+.*--force-with-lease\b', re.IGNORECASE),
+     "Potentially destructive git operation: 'git push --force-with-lease' can still overwrite remote history"),
+
+    # Dangerous chmod
+    (re.compile(r'\bchmod\s+.*777\b', re.IGNORECASE),
+     "Security risk: 'chmod 777' grants full permissions to everyone"),
+
+    # Dangerous chown to root or recursive
+    (re.compile(r'\bchown\s+.*-R\s+root\b', re.IGNORECASE),
+     "Destructive ownership change: recursive chown to root can break system permissions"),
+
+    # Fork bomb pattern
+    (re.compile(r':\(\)\s*\{.*:\|:.*\}', re.IGNORECASE),
+     "Fork bomb detected: this pattern can crash the system by exhausting resources"),
+
+    # dd with destructive output
+    (re.compile(r'\bdd\s+.*of=/dev/(sd[a-z]|hd[a-z]|nvme\d+n\d+)', re.IGNORECASE),
+     "Destructive disk operation: 'dd' writing directly to a block device can destroy data"),
+
+    # mkfs commands
+    (re.compile(r'\bmkfs\.\w+\s+/dev/', re.IGNORECASE),
+     "Destructive disk operation: 'mkfs' creates a filesystem and destroys existing data"),
+]
+
+
+def log_blocked_attempt(command, project_path, reason):
+    """Log a blocked command attempt to the log file."""
+    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
+
+    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
+
+    log_entry = {
+        "timestamp": timestamp,
+        "attempted_command": command,
+        "project_path": project_path,
+        "reason": reason,
+    }
+
+    with open(LOG_FILE, "a") as f:
+        f.write(json.dumps(log_entry) + "\n")
+
+
+def check_command(command):
+    """Check if a command matches any dangerous patterns.
+
+    Returns (is_dangerous, reason) tuple.
+    """
+    for pattern, reason in DANGEROUS_PATTERNS:
+        if pattern.search(command):
+            return True, reason
+    return False, None
+
+
+def main():
+    """Main hook entry point."""
+    try:
+        input_data = json.loads(sys.stdin.read())
+    except (json.JSONDecodeError, EOFError):
+        # If we can't parse input, allow the command through
+        sys.exit(0)
+
+    tool_name = input_data.get("tool_name", "")
+    tool_input = input_data.get("tool_input", {})
+
+    # Only intercept bash commands
+    if tool_name != "bash" and tool_name != "Bash":
+        sys.exit(0)
+
+    command = tool_input.get("command", "")
+    if not command:
+        sys.exit(0)
+
+    project_path = os.getcwd()
+
+    is_dangerous, reason = check_command(command)
+
+    if is_dangerous:
+        log_blocked_attempt(command, project_path, reason)
+
+        # Output a clear message to Claude explaining why the command was blocked
+        response = {
+            "decision": "block",
+            "reason": (
+                f"🚫 BLOCKED: {reason}\n\n"
+                f"Attempted command: {command}\n"
+                f"Project path: {project_path}\n\n"
+                f"This command was blocked by the pre-tool-use security hook to prevent "
+                f"accidental data loss