```diff
--- /dev/null
+++ b/n8n-workflow.json
@@ -0,0 +1,470 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "0",
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
+          "interval": "weeks",
+          "dateTime": "friday 17:00"
+        }
+      },
+      "id": "1",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getAll",
+        "owner": "={{ $json[\"github_owner\"] }}",
+        "repository": "={{ $json[\"github_repo\"] }}",
+        "filters": {
+          "commits": {
+            "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+            "until": "={{ new Date().toISOString() }}",
+            "per_page": 100
+          }
+        }
+      },
+      "id": "2",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getAll",
+        "owner": "={{ $json[\"github_owner\"] }}",
+        "repository": "={{ $json[\"github_repo\"] }}",
+        "filters": {
+          "state": "closed",
+          "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}"
+        }
+      },
+      "id": "3",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "position": [
+        600,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "getAll",
+        "owner": "={{ $json[\"github_owner\"] }}",
+        "repository": "={{ $json[\"github_repo\"] }}",
+        "filters": {
+          "state": "closed",
+          "base": "main"
+        }
+      },
+      "id": "4",
+      "name": "Get Pull Requests",
+      "type": "n8n-nodes-base.github",
+      "position": [
+        750,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "messages": [
+          {
+            "role": "user",
+            "content": "Please summarize this week's development activity for the {{ $json[\"github_repo\"] }} repository. Include commits: {{ $json[\"commits\"] }}, closed issues: {{ $json[\"closed_issues\"] }}, and merged pull requests: {{ $json[\"merged_prs\"] }}. Write in {{ $json[\"language\"] }}."
+          }
+        ]
+      },
+      "id": "5",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "position": [
+        900,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{ $json[\"email_from\"] }}",
+        "toEmail": "={{ $json[\"email_to\"] }}",
+        "subject": "Weekly Dev Summary for {{ $json[\"github_repo\"] }}",
+        "text": "={{ $json[\"summary\"] }}"
+      },
+      "id": "6",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "position": [
+        1050,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "url": "={{ $json[\"webhook_url\"] }}",
+        "method": "POST",
+        "data": "={{ { content: $json[\"summary\"] } }}"
+      },
+      "id": "7",
+      "name": "Send to Discord",
+      "type": "n8n-nodes-base.http",
+      "position": [
+        1200,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "url": "={{ $json[\"webhook_url\"] }}",
+        "method": "POST",
+        "data": "={{ { text: $json[\"summary\"] } }}"
+      },
+      "id": "8",
+      "name": "Send to Slack",
+      "type": "n8n-nodes-base.http",
+      "position": [
+        1350,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "language": "={{ $parameter[\"language\"] }}",
+          "github_owner": "={{ $parameter[\"github_owner\"] }}",
+          "github_repo": "={{ $parameter[\"github_repo\"] }}",
+          "email_to": "={{ $parameter[\"email_to\"] }}",
+          "email_from": "={{ $parameter[\"email_from\"] }}",
+          "webhook_url": "={{ $parameter[\"webhook_url\"] }}",
+          "summary": "={{ $parameter[\"summary\"] }}",
+          "commits": "={{ $parameter[\"commits\"] }}",
+          "closed_issues": "={{ $parameter[\"closed_issues\"] }}",
+          "merged_prs": "={{ $parameter[