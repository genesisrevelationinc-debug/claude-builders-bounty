```diff
--- /dev/null
+++ b/weekly-dev-summary-workflow.json
@@ -0,0 +1,1000 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Start",
+      "type": "n8n-nodes-base.start",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "repeatInterval": 1,
+          "triggerAt": {
+            "day": 5,
+            "hour": 17,
+            "minute": 0
+          }
+        }
+      },
+      "id": "2",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "owner": "={{ $json.owner }}",
+        "repository": "={{ $json.repository }}",
+        "operation": "getAll",
+        "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+        "until": "={{ new Date().toISOString() }}",
+        "perPage": 100
+      },
+      "id": "3",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+      "  owner": "={{ $json.owner }}",
+        "repository": "={{ $json.repository }}",
+        "operation": "getAll",
+        "state": "closed",
+        "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+        "until": "={{ new Date().toISOString() }}",
+        "perPage": 100
+      },
+      "id": "4",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "owner": "={{ $json.owner }}",
+        "repository": "={{ $json.repository }}",
+        "operation": "getAll",
+        "state": "closed",
+        "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+        "until": "={{ new Date().toISOString() }}",
+        "perPage": 100
+      },
+      "id": "5",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json.prompt }}",
+        "maxTokens": 1024,
+        "temperature": 0.7
+      },
+      "id": "6",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "subject": "={{ 'Weekly Dev Summary - ' + new Date().toDateString() }}",
+        "toEmail": "={{ $json.toEmail }}",
+        "text": "={{ $json.summary }}",
+        "html": "={{ $json.summary }}"
+      },
+      "id": "7",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "prompt",
+              "value": "={{ $json.commits + $json.issues + $json.prs }}"
+            }
+          ]
+        }
+      },
+      "id": "8",
+      "name": "Set Prompt",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "summary",
+              "value": "={{ $json.response }}"
+            }
+          ]
+        }
+      },
+      "id": "9",
+      "name": "Set Summary",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        300
+      ]
+    }
+  ],
+  "connections": {
+    "Start": {
+      "main": [
+        [
+          {
+            "node": "Cron",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Cron": {
+      "main": [
+        [
+          {
+            "node": "Get Commits",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Get