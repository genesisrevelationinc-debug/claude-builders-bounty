```diff
--- /dev/null
+++ b/n8n-claude-weekly-summary.json
@@ -0,0 +1,1059 @@
+{
+  "name": "Weekly Dev Summary with Claude",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Start",
+      "type": "n8n-nodes-base.manualTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        360
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field_name": "cronExpression",
+              "cron_expression": "0 17 * * 5"
+            }
+          ]
+        }
+      },
+      "id": "2",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/commits",
+        "options": {
+          "qs": {
+            "since": "={{$parameter[\"calculateSince\"]}}",
+            "until": "={{new Date().toISOString()}}"
+          }
+        },
+        "headerParametersUi": {
+          "parameter": [
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{$parameter[\"githubToken\"]}}"
+            },
+            {
+              "name": "Accept",
+              "value": "application/vnd.github.v3+json"
+            }
+          ]
+        }
+      },
+      "id": "3",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        550,
+        360
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/issues",
+        "options": {
+          "qs": {
+            "state": "closed",
+            "since": "={{$parameter[\"calculateSince\"]}}"
+          }
+        },
+        "headerParametersUi": {
+          "parameter": [
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{$parameter[\"githubToken\"]}}"
+            },
+            {
+              "name": "Accept",
+              "value": "application/vnd.github.v3+json"
+            }
+          ]
+        }
+      },
+      "id": "4",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        550,
+        520
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/pulls",
+        "options": {
+          "qs": {
+            "state": "closed",
+            "sort": "updated",
+            "direction": "desc"
+          }
+        },
+        "headerParametersUi": {
+          "parameter": [
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{$parameter[\"githubToken\"]}}"
+            },
+            {
+              "name": "Accept",
+              "value": "application/vnd.github.v3+json"
+            }
+          ]
+        }
+      },
+      "id": "5",
+      "name": "Get Pull Requests",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        550,
+        680
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "=Please generate a weekly development summary for the repository {{$parameter[\"repoName\"]}}.\n\nHere is the activity for the past week:\n\nCommits:\n{{$parameter[\"formatCommits\"]}}\n\nClosed Issues:\n{{$parameter[\"formatIssues\"]}}\n\nMerged Pull Requests:\n{{$parameter[\"formatPRs\"]}}\n\nPlease provide a narrative summary of the key developments, major changes, and overall progress in a {{$parameter[\"language\"]}} language. Focus on the most significant changes and their impact.",
+        "options": {
+          "max_tokens_to_sample": 2000,
+          "temperature": 0.5
+        }
+      },
+      "id": "6",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claudeApi",
+      "typeVersion": 1,
+      "position": [
+        850,
+        360
+      ]
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{$parameter[\"fromEmail\"]}}",
+        "toEmail": "={{$parameter[\"toEmail\"]}}",
+        "subject": "=Weekly Development Summary for {{$parameter[\"repoName\"]}} - {{new Date().toISOString().slice(0, 10)}}",
+        "text": "={{$parameter[\"summary\"]}}"
+      },
+      "id": "7",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1150,
+        360
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
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
+              "name": "githubToken",
+