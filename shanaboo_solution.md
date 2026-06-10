```diff
--- /dev/null
+++ b/claude-weekly-summary.json
@@ -0,0 +1,1404 @@
+{
+  "name": "Claude Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Start",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ],
+      "webhookId": "b8c9f0d1-1a2b-3c4d-5e6f-7a8b9c0d1e2f"
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": "week",
+          "timezone": "America/New_York"
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
+        "resource": "commit",
+        "methodName": "/repos/{owner}/{repo}/commits"
+      },
+      "id": "3",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "methodName": "/repos/{owner}/{repo}/issues",
+        "state": "closed",
+        "sort": "created",
+        "direction": "desc"
+      },
+      "id": "4",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pulls",
+        "methodName": "/repos/{owner}/{repo}/pulls",
+        "state": "closed",
+        "sort": "updated",
+        "direction": "desc"
+      },
+      "id": "5",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        600
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "Generate a narrative summary of the following GitHub activity for the past week:\n\nCommits:\n{% for commit in [{$json[\"commits\"]['data']}}\n- {{commit.commit.message}} (by {{commit.author.login}})\n{% endfor %}\n\nClosed Issues:\n{% for issue in [{$json[\"issues\"]['data']}}\n- {{issue.title}} (#{{issue.number}})\n{% endfor %}\n\nMerged PRs:\n{% for pr in [{$json[\"pulls\"]['data']}}\n- {{pr.title}} (#{{pr.number}}) by {{pr.user.login}}\n{% endfor %}\n\nPlease provide a concise, narrative summary of the key developments this week.",
+        "max_tokens": 1000,
+        "temperature": 0.7
+      },
+      "id": "6",
+      "name": "Claude AI",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "url": "={{ $json[\"repo\"] }}",
+        "method": "GET",
+        "queryParameters": {
+          "state": "all",
+          "sort": "created",
+          "direction": "desc"
+        }
+      },
+      "id": "7",
+      "name": "GitHub Request",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "methodName": "/repos/{owner}/{repo}/issues"
+      },
+      "id": "8",
+      "name": "Get All Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        750
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pulls",
+        "methodName": "/repos/{owner}/{repo}/pulls"
+      },
+      "id": "9",
+      "name": "Get All PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        900
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "methodName": "/repos/{owner}/{repo}",
+        "owner": "={{ $json[\"repo\"].split(\"/\")[0] }}",
+        "repo": "={{ $json[\"repo\"].split(\"/\")[1] }}",
+        "filters": {
+          "commits": {
+            "since": "={{ $now }}",
+            "until": "={{ $now }}"
+          },
+          "issues": {
+            "state": "closed",
+            "sort": "updated",
+            "direction": "desc"
+          },
+          "pulls": {
+            "state": "closed",
+            "sort": "updated",
+            "direction": "desc"
+          }
+        }
+      },
+      "id": "10",
+      "name": "GitHub",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position":