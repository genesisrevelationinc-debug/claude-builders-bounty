```diff
--- /dev/null
+++ b/n8n-github-summary.json
@@ -0,0 +1,1304 @@
+{
+  "name": "Weekly GitHub Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "0a0d7b56-878d-426d-9e71-9de4a828fd60",
+      "name": "Start",
+      "type": "n8n-nodes-base.manualTrigger",
+      "typeVersion": 1,
+      "position": [
+        240,
+        340
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "weeks": [
+                "5pm on Friday"
+              ]
+            }
+          ]
+        }
+      },
+      "id": "8e5f36a8-7b1e-4b5e-9d5a-8e5f36a87b1e",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        240,
+        340
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{ $json.github_repo }}/commits",
+        "options": {
+          "qs": {
+            "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+          }
+        }
+      },
+      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        400,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{ $json.github_repo }}/issues",
+        "options": {
+          "qs": {
+            "state": "closed",
+            "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}"
+          }
+        }
+      },
+      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567891",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        400,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{ $json.github_repo }}/pulls",
+        "options": {
+          "qs": {
+            "state": "closed",
+            "sort": "updated",
+            "direction": "desc"
+          }
+        }
+      },
+      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567892",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        400,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "prompt": "Generate a narrative summary of the following GitHub activity for the past week:\n\nCommits:\n{{ $json.commits }}\n\nClosed Issues:\n{{ $json.closed_issues }}\n\nMerged PRs:\n{{ $json.merged_prs }}\n\nPlease provide a concise, narrative summary in {{ $json.language }}.",
+        "model": "claude-sonnet-4-20250514",
+        "max_tokens": 1000,
+        "temperature": 0.7
+      },
+      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567893",
+      "name": "Claude API",
+      "type": "claude-ai.Claude",
+      "typeVersion": 1,
+      "position": [
+        600,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "subject": "Weekly GitHub Summary",
+        "to": "{{ $json.email }}",
+        "text": "={{ $json.claude_response }}",
+        "html": "={{ $json.claude_response }}"
+      },
+      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567894",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        600,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "github_repo",
+              "value": "={{ $parameter.github_repo }}",
+              "type": "string"
+            },
+            {
+              "name": "language",
+              "value": "={{ $parameter.language }}",
+              "type": "string"
+            },
+            {
+              "name": "email",
+              "value": "={{ $parameter.email }}",
+              "type": "string"
+            }
+          ]
+        }
+      },
+      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567895",
+      "name": "Set Variables",
+      "type": "n8n-nodes-base.set",
+      "typeVersion