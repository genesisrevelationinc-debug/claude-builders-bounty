```diff
--- /dev/null
+++ b/n8n-workflow.json
@@ -0,0 +1,1069 @@
+{
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "d48ddc40-4f5a-4fb5-9f60-0d8b28798881",
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
+          "interval": [
+            {
+              "field": "cronExpression",
+              "expression": "0 17 * * 5"
+            }
+          ]
+        }
+      },
+      "id": "4e1f3e3b-8c5a-4b6a-9f00-123456789abc",
+      "name": "Cron Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        150
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "issuesAndPullRequests",
+        "query": "=repo:{{$json["repo"]}} is:pr is:closed merged:>={{$json["startDate"]}}",
+        "options": {}
+      },
+      "id": "gh-search-1",
+      "name": "GitHub Search PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        150
+      ],
+      "credentials": {
+        "githubApi": "GitHub_Credentials"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "issuesAndPullRequests",
+        "query": "=repo:{{$json["repo"]}} is:issue is:closed closed:>={{$json["startDate"]}}",
+        "options": {}
+      },
+      "id": "gh-search-2",
+      "name": "GitHub Search Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        300
+      ],
+      "credentials": {
+        "githubApi": "GitHub_Credentials"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "commits",
+        "query": "=repo:{{$json["repo"]}} committer-date:>={{$json["startDate"]}}",
+        "options": {}
+      },
+      "id": "gh-search-3",
+      "name": "GitHub Search Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        450
+      ],
+      "credentials": {
+        "githubApi": "GitHub_Credentials"
+      }
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "Generate a narrative summary of the GitHub activity for the repository {{$json[\"repo\"]}} for the week of {{$json[\"startDate\"]}} to {{$json[\"endDate\"]}}. Include highlights of merged pull requests, closed issues, and important commits. Write in {{$json[\"language\"]}}.",
+        "maxTokens": 1000,
+        "temperature": 0.7
+      },
+      "id": "claude-node",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ],
+      "credentials": {
+        "claudeApi": "Claude_API_Credentials"
+      }
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "fields": [
+          {
+            "name": "repo",
+            "type": "string",
+            "value": "claude-builders-bounty/claude-builders-bounty"
+          },
+          {
+            "name": "startDate",
+            "type": "string",
+            "value": "={{$now.setHours(0,0,0,0).setDate($now.getDate()-7).toISOString().split('T')[0]}}"
+          },
+          {
+            "name": "endDate",
+            "type": "string",
+            "value": "={{$now.setHours(0,0,0,0).toISOString().split('T')[0]}}"
+          },
+          {
+            "name": "language",
+            "type": "string",
+            "value": "English"
+          }
+        ]
+      },
+      "id": "set-node",
+      "name": "Set Parameters",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        400,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "issues",
+        "operation": "getAll",
+        "owner": "={{$json[\"repo\"].split('/')[0]}}",
+        "repo": "={{$json[\"repo\"].split('/')[1]}}",
+        "filters": {
+          "state": "closed",
+          "type": "pull-request"
+        }
+      },
+      "id": "github-prs",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        150
+      ],
+      "credentials": {
+        "githubApi": "GitHub_Credentials"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issues",
+        "operation": "getAll",
+        "owner": "={{$json[\"repo\"].split('/')[0]}}