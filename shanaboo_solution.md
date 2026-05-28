```diff
--- /dev/null
+++ b/n8n-claude-weekly-summary.json
@@ -0,0 +1,1000 @@
+{
+  "name": "Weekly Development Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "GitHub API",
+      "name": "GitHub API",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        100,
+        100
+      ],
+      "webhookId": "wkf_1234567890"
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "owner": "claude-builders-bounty",
+        "repository": "claude-builders-bounty",
+        "timeZone": "America/New_York",
+        "cron": "0 0 17 * * 5"
+      },
+      "id": "Schedule Trigger",
+      "name": "Schedule Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        200,
+        100
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "search",
+        "query": "repo:{{ repository }} is:pr is:merged",
+        "sort": "updated",
+        "order": "desc"
+      },
+      "id": "GitHub Search",
+      "name": "GitHub Search",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        300,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "options": {
+          "maxTokens": 4000,
+          "temperature": 0.7
+        }
+      },
+      "id": "Claude API",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        400,
+        300
+      ]
+    },
+    {
+      "parameters": {
+      },
+      "id": "Function",
+      "name": "Process Data",
+      "type": "n8n-nodes-base.functionItem",
+      "typeVersion": 1,
+      "position": [
+        500,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "get",
+        "owner": "={{ $json['input'].github['owner'] }}",
+        "name": "={{ $json['input'].github['repo'] }}",
+        "additionalFields": {
+          "branchName": "main"
+        }
+      },
+      "id": "Get Repository Data",
+      "name": "Get Repository Data",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        600,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getCommits",
+        "owner": "={{ $json['input'].github['owner'] }}",
+        "repo": "={{ $json['input'].github['repo'] }}",
+        "branchName": "main"
+      },
+      "id": "Get Commits",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        700,
+        600
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getIssues",
+        "owner": "={{ $json['input'].github['owner'] }}",
+        "repo": "={{ $json['input'].github['repo'] }}",
+        "filters": {
+          "state": "closed"
+        }
+      },
+      "id": "Get Issues",
+      "name": "Get Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        800,
+        700
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "getAll",
+        "owner": "={{ $json['input'].github['owner'] }}",
+        "repo": "={{ $json['input'].github['repo'] }}",
+        "filters": {
+          "state": "closed",
+          "base": "main"
+        }
+      },
+      "id": "Get Pull Requests",
+      "name": "Get Pull Requests",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        900,
+        800
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getCommits",
+        "owner": "={{ $json['input'].github['owner'] }}",
+        "repo": "={{ $json['input'].github['repo'] }}",
+        "branchName": "main"
+      },
+      "id": "Get Commits",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        1000,
+        900
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getIssues",
+        "owner": "={{ $json['input'].github['owner'] }}",
+        "repo": "={{ $json['input'].github['repo'] }}",
+        "filters": {
+          "state": "closed"
+        }
+      },
+      "id": "Get Issues",
+      "name": "Get Issues",
+      "type": "n8n-nodes-base.github