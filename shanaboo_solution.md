```diff
--- /dev/null
+++ b/claude-weekly-dev-summary.json
@@ -0,0 +1,1456 @@
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
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "weeks": 1
+            }
+          ]
+        },
+        "timezone": "America/New_York",
+        "cronExpression": "0 17 * * 5"
+      },
+      "id": "2",
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
+        "resource": "commit",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "filters": {
+          "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}",
+          "until": "={{ new Date().toISOString() }}"
+        }
+      },
+      "id": "3",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        500,
+        200
+      ],
+      "credentials": {
+        "githubApi": "GitHub"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "state": "closed",
+        "filters": {
+          "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}"
+        }
+      },
+      "id": "4",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        500,
+        350
+      ],
+      "credentials": {
+        "githubApi": "GitHub"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "state": "closed",
+        "filters": {
+          "sort": "updated",
+          "direction": "desc"
+        }
+      },
+      "id": "5",
+      "name": "Get Pull Requests",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        500,
+        500
+      ],
+      "credentials": {
+        "githubApi": "GitHub"
+      }
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json[\"prompt\"] }}",
+        "system": "={{ $json[\"system\"] }}",
+        "maxTokens": 1024,
+        "temperature": 0.7
+      },
+      "id": "6",
+      "name": "Call Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        1000,
+        300
+      ],
+      "credentials": {
+        "anthropicApi": "Anthropic"
+      }
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "fields": [
+          {
+            "name": "commits",
+            "value": "={{ $json[\"commits\"] }}"
+          },
+          {
+            "name": "issues",
+            "value": "={{ $json[\"issues\"] }}"
+          },
+          {
+            "name": "pullRequests",
+            "value": "={{ $json[\"pullRequests\"] }}"
+          }
+        ]
+      },
+      "id": "7",
+      "name": "Prepare Data",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        750,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+        "combine": {
+          "mergeBy": "index",
+          "join": "inner"
+        }
+      },
+      "id": "8",
+      "name": "Combine Data",
+      "type": "n8n-nodes-base.combine",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+        "combine": {
+          "mergeBy": "index",
+          "join": "inner"
+        }
+      },
+      "id": "9",
+      "name": "Combine Data1",
+      "type": "n8n-nodes-base.combine",
+      "typeVersion": 1,
+      "position": [
+        850,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+        "combine": {
+          "mergeBy": "index",
+          "join": "inner"
+        }
+      },
+      "id": "10",
+      "name": "Combine Data2",
+      "type": "n8n-nodes-base.combine",
+