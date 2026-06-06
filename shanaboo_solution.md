```diff
--- /dev/null
+++ b/n8n-claude-weekly-summary.json
@@ -0,0 +1,1 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "cronExpression",
+              "value": "0 17 * * 5"
+            }
+          ]
+        }
+      },
+      "id": "2",
+      "name": "Schedule Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+      "options": {
+        "repo": "={{ $json.repo }}",
+        "sort": "updated",
+        "direction": "desc",
+        "perPage": "100",
+        "state": "all"
+      }
+      },
+      "id": "3",
+      "name": "GitHub",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "repo": "={{ $json.repo }}",
+          "sort": "updated",
+          "direction": "desc",
+          "perPage": "100",
+          "state": "all"
+        }
+      },
+      "id": "4",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "repo": "={{ $json.repo }}",
+          "sort": "updated",
+          "direction": "desc",
+          "perPage": "100",
+          "state": "all"
+        }
+      },
+      "id": "5",
+      "name": "Get Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "repo": "={{ $json.repo }}",
+          "sort": "updated",
+          "direction": "desc",
+          "perPage": "100",
+          "state": "all"
+        }
+      },
+      "id": "6",
+      "name": "Get Pull Requests",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "system": "You are a helpful assistant that summarizes GitHub activity.",
+        "messages": [
+          {
+            "role": "user",
+            "content": "Please summarize the following GitHub activity for the week:\n\nCommits:\n{{ $json.commits }}\n\nIssues:\n{{ $json.issues }}\n\nPull Requests:\n{{ $json.prs }}"
+          }
+        ],
+        "max_tokens": 1000
+      },
+      "id": "7",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{ $json.fromEmail }}",
+        "toEmail": "={{ $json.toEmail }}",
+        "subject": "Weekly Development Summary",
+        "text": "={{ $json.summary }}"
+      },
+      "id": "8",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "url": "={{ $json.webhookUrl }}",
+        "text": "={{ $json.summary }}"
+      },
+      "id": "9",
+      "name": "Send to Webhook",
+      "type": "n8n-nodes-base.webhook",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    }
+  ],
+  "connections": {
+    "Schedule Trigger": {
+      "main": [
+        [
+          {
+            "node": "Get Commits",
+            "type": "n8n-nodes-base.github",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Get Commits": {
+      "main": [
+        [
+          {
+            "node": "Get Issues",
+            "type": "n8n-nodes-base.github",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Get Issues": {
+      "main": [
+        [
+          {
+            "node": "Get Pull Requests",
+            "type": "n8n-nodes-base.github",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Get Pull Requests": {
+      "main": [
+        [
+          {
+            "node": "Claude API",
+            "type": "n8n-nodes-base.anthropic",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Claude API": {
+      "main": [
+        [
+          {
+            "node": "Send Email",
+            "type": "n8