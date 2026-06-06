```diff
--- /dev/null
+++ b/claude-weekly-summary.json
@@ -0,0 +1,404 @@
+{
+  "meta": {
+    "instanceId": "0488421c-6df7-45bd-9da0-35f7d29521a3",
+    "createdAt": "2024-01-15T12:00:00.000Z",
+    "schemaVersion": 18,
+    "workflowVersion": 1
+  },
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "59",
+          "mode": "everyX"
+        }
+      },
+      "id": "Schedule1",
+      "name": "Weekly Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "filters": {
+          "since": "={{ $now.setHours(0, 0, 0, 0).subtract(7, 'days').toISOString() }}",
+          "until": "={{ $now.toISOString() }}",
+          "state": "all"
+        },
+        "options": {
+          "sort": "updated",
+          "direction": "desc"
+        }
+      },
+      "id": "GitHub1",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "filters": {
+          "since": "={{ $now.setHours(0, 0, 0, 0).subtract(7, 'days').toISOString() }}",
+          "until": "={{ $now.toISOString() }}",
+          "state": "closed"
+        },
+        "options": {
+          "sort": "updated",
+          "direction": "desc"
+        }
+      },
+      "id": "GitHub2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "filters": {
+          "since": "={{ $now.setHours(0, 0, 0, 0).subtract(7, 'days').toISOString() }}",
+          "until": "={{ $now.toISOString() }}",
+          "state": "closed"
+        },
+        "options": {
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
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ \"Create a weekly development summary for the \" + $parameter[\"repoName\"] + \" repository.\\n\\nHere's the activity for the week:\\n\\nCommits:\\n\" + JSON.stringify($items('Get Commits')) + \"\\n\\nClosed Issues:\\n\" + JSON.stringify($items('Get Closed Issues')) + \"\\n\\nMerged PRs:\\n\" + JSON.stringify($items('Get Merged PRs')) + \"\\n\\nPlease provide a narrative summary of this activity in \" + $parameter[\"language\"] + \".\" }}",
+        "systemPrompt": "={{ \"You are an expert technical writer creating a development summary for a software team.\" }}",
+        "maxTokens": 1000,
+        "temperature": 0.5
+      },
+      "id": "Claude1",
+      "name": "Generate Summary",
+      "type": "claude3-nodes.claude",
+      "typeVersion": 1,
+      "position": [
+        650,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{ $parameter[\"senderEmail\"] }}",
+        "toEmail": "={{ $parameter[\"recipientEmail\"] }}",
+        "subject": "={{ 'Weekly Summary for ' + $parameter[\"repoName\"] }}",
+        "text": "={{ $items('Generate Summary')[0].json.response }}",
+        "options": {}
+      },
+      "id": "Email1",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        850,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "repoOwner",
+              "value": "claude-builders-bounty"
+            },
+            {
+              "name": "repoName",
+              "value": "claude-builders-bounty"
+            },
+            {
+              "name": "language",
+              "value": "English"
+            },
+            {
+              "name": "senderEmail",
+              "value": "weekly-summary@example.com"
+            },
+            {
+              "name": "recipientEmail",
+              "value": "team@example.com"
+            }
+         