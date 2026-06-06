```diff
--- /dev/null
+++ b/workflow/Claude_Weekly_Dev_Summary.json
@@ -0,0 +1,1109 @@
+{
+  "name": "Claude Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "options": {
+          "timezone": "America/New_York"
+        },
+        "rule": {
+          "interval": "weeks",
+          "repeatInterval": 1,
+          "triggerTime": {
+            "mode": "everyWeek",
+            "dayOfWeek": 5,
+            "hour": 17,
+            "minute": 0
+          }
+        }
+      },
+      "id": "Schedule Trigger",
+      "name": "Every Friday at 5pm",
+      "type": "n8n-nodes-base.schedule",
+      "typeVersion": 1,
+      "position": [
+        250,
+        330
+      ],
+      "webhookId": "a001"
+    },
+    {
+      "parameters": {
+        "authentication": "oAuth2",
+        "resource": "search",
+        "search": {
+          "term": "repo:claude-builders-bounty/claude-builders-bounty is:commit",
+          "sort": "created",
+          "order": "desc"
+        }
+      },
+      "id": "GitHub",
+      "name": "GitHub",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        330
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "You are a technical writer creating a weekly development summary. Please create a narrative summary of the GitHub activity for the week based on the data provided. Structure your response with the following sections: Summary of Commits, Summary of Closed Issues, Summary of Merged Pull Requests. Keep the tone professional and concise.",
+        "maxTokens": 2048,
+        "inputs": [
+          {
+            "key": "commits",
+            "value": "={{ $json.commits }}",
+            "type": "text"
+          },
+          {
+            "key": "issues",
+            "value": "={{ $json.issues }}",
+            "type": "text"
+            },
+            {
+              "key": "pull_requests",
+              "value": "={{ $json.prs }}",
+              "type": "text"
+            }
+          ],
+          "options": {
+            "temperature": 0.7,
+            "maxTokens": 1024
+          }
+        },
+        "id": "Claude AI",
+        "name": "Claude AI",
+        "type": "n8n-nodes-ai.clarifai",
+        "typeVersion": 1,
+        "position": [
+          850,
+          330
+        ]
+      },
+      {
+        "parameters": {
+          "resource": "issues",
+          "pulls": {
+            "listOptions": {
+              "state": "closed"
+            }
+          }
+        },
+        "id": "GitHub Issues",
+        "name": "GitHub Issues",
+        "type": "n8n-nodes-base.github",
+        "typeVersion": 1,
+        "position": [
+          550,
+          330
+        ]
+      },
+      {
+        "parameters": {
+          "resource": "pulls",
+          "pulls": {
+            "listOptions": {
+              "state": "closed"
+            }
+          }
+        },
+        "id": "GitHub Pull Requests",
+        "name": "GitHub Pull Requests",
+        "type": "n8n-nodes-base.github",
+        "typeVersion": 1,
+        "position": [
+          650,
+          330
+        ]
+      },
+      {
+        "parameters": {
+          "fromOtherKey": true,
+          "outputPropertyName": "commits"
+        },
+        "id": "Set Commits",
+        "name": "Set Commits",
+        "type": "n8n-nodes-base.set",
+        "typeVersion": 1,
+        "position": [
+          750,
+          330
+        ]
+      },
+      {
+        "parameters": {
+          "fromOtherKey": true,
+          "outputPropertyName": "issues"
+        },
+        "id": "Set Issues",
+        "name": "Set Issues",
+        "type": "n8n-nodes-base.set",
+        "typeVersion": 1,
+        "position": [
+          850,
+          430
+        ]
+      },
+      {
+        "parameters": {
+          "fromOtherKey": true,
+          "outputPropertyName": "prs"
+        },
+        "id": "Set PRs",
+        "name": "Set PRs",
+        "type": "n8n-nodes-base.set",
+        "typeVersion": 1,
+        "position": [
+          950,
+          530
+        ]
+      },
+      {
+        "parameters": {
+          "resource": "commits",
+          "commits": {
+            "listOptions": {
+              "since": "={{ $json.since }}",
+              "until": "={{ $json.until }}",
+              "per_page": 100
+            }
+          }
+        },
+        "id": "GitHub Commits",
+        "name": "GitHub Commits",
+        "type": "n8n-nodes-base.github",
+        "typeVersion": 1,
+        "position": [
+          1050,
+          330
+        ]
+      },
+      {
+        "parameters": {
+          "resource": "issues",
+          "issues": {
+            "listOptions": {
+              "state": "closed",
+              "since": "={{ $json.since }}",
+              "until": "={{ $json.until }}",
+              "per_page": 100
+            }
+          }
+        },
+        "id": "GitHub Closed Issues",
+        "name": "GitHub Closed