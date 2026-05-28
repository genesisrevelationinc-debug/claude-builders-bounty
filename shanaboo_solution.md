```diff
--- /dev/null
+++ b/n8n-claude-weekly-summary.json
@@ -0,0 +1,1002 @@
+{
+  "meta": {
+    "instanceId": "1411b378-19d2-4235-8941-66adb72008a6"
+  },
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": 5,
+          "type": "cron"
+        }
+      },
+      "id": "Schedule",
+      "name": "Weekly Summary",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        200,
+        800
+      ]
+    },
+    {
+      "parameters": {
+        "httpMethod": "GET",
+        "url": "https://api.github.com/repos/{{$parameter[\"repo\"]}}/commits",
+        "options": {
+          "queryParameters": {
+            "since": "={{$now}}"
+          }
+        }
+      },
+      "id": "Get Commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        400,
+        600
+      ]
+    },
+    {
+      "parameters": {
+        "httpMethod": "GET",
+        "url": "https://api.github.com/repos/{{$parameter[\"repo\"]}}/issues",
+        "options": {
+          "queryParameters": {
+            "state": "closed",
+            "since": "={{$now}}"
+          }
+        }
+      },
+      "id": "Get Closed Issues",
+      "name": "GitHub Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "type,,
+      "position": [
+        400,
+        800
+      ]
+    },
+    {
+      "parameters": {
+        "httpMethod": "GET",
+        "url": "https://api.github.com/repos/{{$parameter[\"repo\"]}}/pulls",
+        "options": {
+          "queryParameters": {
+            "state": "all",
+            "sort": "updated",
+            "direction": "desc"
+          }
+        }
+      },
+      "id": "Get PRs",
+      "name": "GitHub Pull Requests",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        400,
+        1000
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "maxTokens": 1000,
+        "temperature": 0.7,
+        "prompt": "Generate a narrative summary of the following GitHub activity for the past week:\n\nCommits:\n{{ $json[\"commits\"] }}\n\nClosed Issues:\n{{ $json[\"issues\"] }}\n\nMerged PRs:\n{{ $json[\"prs\"] }}\n\nPlease provide a concise, well-structured summary of the key changes and activity in the repository for the week. Include:\n\n1. A brief overview of the week's activity\n2. Key features or fixes\n3. Notable commits or PRs\n4. Summary of closed issues\n\nWrite in {{ $parameter[\"language\"] }} language.\n",
+        "systemPrompt": "You are a technical project manager writing a weekly development summary."
+      },
+      "id": "Generate Summary",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        600,
+        800
+      ]
+    },
+    {
+      "parameters": {
+        "updateMethod": "create",
+        "fields": {
+          "name": "summary_report",
+          "value": "={{ $json[\"text\"] }}",
+          "type": "text"
+        }
+      },
+      "id": "Save Summary",
+      "name": "Write Binary File",
+      "type": "n8n-nodes-base.writeBinaryFile",
+      "typeVersion": 1,
+      "position": [
+        800,
+        800
+      ]
+    },
+    {
+      "parameters": {
+        "sendTo": "={{ $parameter[\"destination\"] }}",
+        "sendData": "={{ $json[\"summary\"] }}",
+        "options": {
+          "subject": "Weekly Dev Summary - {{ $now }}",
+          "text": "={{ $json[\"summary\"] }}"
+        }
+      },
+      "id": "Send Summary",
+      "name": "Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1000,
+        800
+      ]
+    }
+  ],
+  "connections": {
+    "Weekly Summary": {
+      "main": [
+        [
+          {
+            "node": "GitHub Commits",
+            "type": "main",
+            "key": "main"
+          }
+        ]
+      ]
+    },
+    "GitHub Commits": {
+      "main": [
+        [
+          {
+            "node": "GitHub Issues",
+            "type": "main",
+            "key": "main"
+          }
+        ]
+      ]
+    },
+    "GitHub Issues": {
+      "main": [
+        [
+          {
+            "node": "GitHub Pull Requests",
+            "type": "main",
+            "key": "main"
+          }
+        ]
+      ]
+    },
+    "GitHub Pull Requests": {
+      "main": [
+        [
+          {
+            "node": "Generate Summary",
+            "type": "main",
+            "key": "main"
+          }
+        ]
+      ]
+    },
+    "Claude API": {
+      "main": [
+        [
+          {
+            "node": "Save Summary",
+          "type": "main",
+          "key": "main"
+