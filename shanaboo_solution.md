 ```diff
--- /dev/null
+++ b/hooks/pre-tool-use
@@ -0,0 +1,98 @@
+#!/usr/bin/env python3
+"""
+Claude Code pre-tool-use hook to block destructive bash commands.
+
+This hook intercepts dangerous bash commands before they are executed
+in Claude Code, preventing accidental data loss.
+"""
+
+import json
+import os
+import re
+import sys
+from datetime import datetime
+from pathlib弃用弃用弃用弃用弃用弃用