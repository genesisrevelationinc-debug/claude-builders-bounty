```diff
--- /dev/null
+++ b/Claude_Weekly_Dev_Summary.json
@@ -0,0 +1,1000 @@
+{
+  "meta": {
+    "instanceId": "06a177a3-4d0d-4193-b27c-1e71c8b8d1e7"
+  },
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "mode": "everyWeekOn",
+          "weekdays": [
+            {
+              "weekdays": [
+                "5"
+              ],
+              "time": "17:00"
+            }
+          ]
+        }
+      },
+      "id": "Schedule Trigger",
+      "name": "Weekly Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "operation": "get",
+        "returnAll": true,
+        "filters": {
+          "since": "={{ $parameter[\"sinceDate\"] }}",
+          "until": "={{ $parameter[\"untilDate\"] }}"
+        }
+      },
+      "id": "GitHub1",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "operation": "getAll",
+        "returnAll": true,
+        "filters": {
+          "state": "closed",
+          "since": "={{ $parameter[\"sinceDate\"] }}",
+          "until": "={{ $parameter[\"untilDate\"] }}"
+        }
+      },
+      "id": "GitHub2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "operation": "getAll",
+        "returnAll": true,
+        "filters": {
+          "state": "closed",
+          "base": "",
+          "sort": "updated",
+          "direction": "desc"
+        }
+      },
+      "id": "GitHub3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        600
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json[\"prompt\"] }}",
+        "options": {
+          "temperature": 0.7,
+          "maxTokens": 1000
+        }
+      },
+      "id": "Claude API",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        900,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{ $parameter[\"fromEmail\"] }}",
+        "to": "={{ $parameter[\"toEmail\"] }}",
+        "subject": "={{ $parameter[\"emailSubject\"] }}",
+        "body": "={{ $parameter[\"emailBody\"] }}",
+        "attachments": "={{ $parameter[\"attachments\"] }}"
+      },
+      "id": "Send Email",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "type0": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1100,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "append",
+        "datasetName": "={{ $parameter[\"datasetName\"] }}",
+        "sheetName": "={{ $parameter[\"sheetName\"] }}",
+        "columns": "={{ $parameter[\"columns\"] }}",
+        "dataMode": "autoMapInputs",
+        "options": {}
+      },
+      "id": "Google Sheets",
+      "name": "Google Sheets",
+      "type": "n8n-nodes-base.googleSheets",
+      "typeVersion": 1,
+      "position": [
+        1100,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true
+      },
+      "id": "Set",
+      "name": "Set",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        700,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "options": {}
+      },
+      "id": "Function",
+      "name": "Function",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+        700,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "options": {}
+      },
+      "id": "Function1",
+      "name": "Function1",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+        700,
+        600
+      ]
+    }
+  ],
+