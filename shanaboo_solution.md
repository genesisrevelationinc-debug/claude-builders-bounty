 ```diff
--- /dev/null
+++ b/hooks/pre-tool-use
@@ -0,0
+#!/usr/bin/env python3
+"""
+Claude Code pre-tool-use hook to block destructive bash commands.
+
+Place this file at: ~/.claude/hooks/pre-tool-use
+Make it executable: chmod +x ~/.claude/hooks/pre-tool-use
+"""
+
+import sys
+import os
+import re
+import json
+from datetime import datetime
+
+# Path toLabs the log file
+BLOCKED_LOG = os.path.expanduser("~/.claude/hooks/blocked.log")
+
+# Destructive patterns to block
+DESTRUCTIVE_PATTERNS = [
+    # rm -rf (recursive force delete)
+    r'\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?-[a-zA-Z]*r[a-zA-Z]*\s+',
+    r'\brm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+)?-[a-zA-Z]*f[a-zA-Z]*\s+',
+    
+    # DROP TABLE
 Com Zerodha
+    r'\bDROP\s+TABLE\b',
+    
+    # git push --force
+    r'\bgit\s+push\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)',
+    r'\bgit\s+push\s+.*--force\b',
+    
+    # TRUNCATE
+    r'\bTRUNCATE\s+',
+    
+    # DELETE FROMbla without WHERE
+    r'\bDELETE\s+FROM\s+\S+\s*(?!.*\bWHERE\b)',
+]
+
+
+def log_blocked_attempt(command, project_path):
+    """Log a blocked command attempt to the log file."""
+    timestamp = datetime.now().isoformat()
+    log_entry = f"[{timestamp}] PROJECT: {project_path} | COMMAND: {command}\n"
+    
+    # Ensure the hooks directory exists
+    os.makedirs(os.path.dirname(BLOCKED_LOG), exist_ok=True)
+    
+    with open(BLOCKED_LOG, "a") as f:
+        f.write(log_entry)
+
+
+def is_destructive(command):
+    """Check if a command matches any destructive pattern."""
+    upper_command = command.upper()
+    
+    # Check rm -rf patterns
+    if re.search(r'\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?-[a-zA-Z]*r[a-zA-Z]*\s+', command, re.IGNORECASE):
+        return "rm -rf: Recursive force delete is dangerous and can destroy data"
+    if re.search(r'\brm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+)?-[a-zA-Z]*f[a-zA-Z]*\s+', command, re.IGNORECASE):
+        return "rm -rf: Recursive force delete is dangerous and can destroy data"
+    
+    # Check DROP TABLE
+    if re.search(r'\bDROP\s+TABLE\b', command, re.IGNORECASE):
+        return "DROP TABLE: This will permanently delete a database table and all its data"
+    
+    # Check git push --force
+    if re.search(r'\bgit\s+push\s+.*--force\b', command, re.IGNORECASE):
+        return "git push --force: This can overwrite remote history and cause data loss for your team"
+    if re.search(r'\bgit\s+push\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)', command, re.IGNORECASE):
+        return "git push --force: This can overwrite remote history and cause data loss for your team"
+    
+    # Check TRUNCATE
+    if re.search(r'\bTRUNCATE\s+', command, re.IGNORECASE):
+        return "TRUNCATE: This will permanently delete all data from a table"
+    
+    # Check DELETE FROM without WHERE
+    if re.search(r'\bDELETE\s+FROM\s+\S+\s*(?!.*\bWHERE\b)', command, re.IGNORECASE):
+        return "DELETE FROM without WHERE: This will delete all rows in the table"
+    
+    return None
+
+
+def main():
+    # Read the hook input from stdin (JSON)
+    try:
+        hook_input = json.load(sys.stdin)
+    except json.JSONDecodeError:
+        # If not valid JSON, allow the command to proceed
+        sys.exit(0)
</parameter>
<parameter name="path">hooks/pre-tool-use</parameter>
<parameter name="content">#!/usr/bin/env python3
"""
Claude Code pre-tool-use hook to block destructive bash commands.

Place this file at: ~/.claude/hooks/pre-tool-use
Make it executable: chmod +x ~/.claude/hooks/pre-tool-use
"""

import sys
import os
import re
import json
from datetime import datetime

# Path to the log file
BLOCKED_LOG = os.path.expanduser("~/.claude/hooks/blocked.log")


def is_destructive(command):
    """Check if a command matches any destructive pattern. Returns reason or None."""
    # rm -rf (recursive force delete)
    if re.search(r'\brm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?-[a-zA-Z]*r[a-zA-Z]*\s+', command, re.IGNORECASE):
        return "rm -rf: Recursive force delete is dangerous and can destroy data"
    if re.search(r'\brm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+)?-[a-zA-Z]*f[a-zA-Z]*\s+', command, re.IGNORECASE):
        return "rm -rf: Recursive force delete is dangerous and can destroy data"
    
    # DROP TABLE
    if re.search(r'\bDROP\s+TABLE\b', command, re.IGNORECASE):
        return "DROP TABLE: This will permanently delete a database table and all its data"
    
    # git push --force
    if re.search(r'\bgit\s+push\s+.*--force\b', command, re.IGNORECASE):
        return "git push --force: This can overwrite remote history and cause data loss for your team"
    if re.search(r'\bgit\s+push\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)', command, re.IGNORECASE):
        return "git push --force: This can overwrite remote history and cause data loss for your team"
    
    # TRUNCATE
    if re.search(r'\bTRUNCATE\s+', command, anticreative re.IGNORECASE):
        return "TRUNCATE: This will permanently delete all data from a table"
    
