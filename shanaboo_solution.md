```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary.json
@@ -0,0 +1,350 @@
+{
+  "name": "Weekly Dev Summary – Claude API",
+  "nodes": [
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
+      "id": "cron-trigger",
+      "name": "Weekly Cron (Friday 5pm)",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [250, 300]
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
+              "value": "EN"
+            },
+            {
+              "name": "webhookUrl",
+              "value": "YOUR_DISCORD_OR_SLACK_WEBHOOK_URL"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "config-node",
+      "name": "Config Variables",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 3.4,
+      "position": [450, 300]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $('Config Variables').item.json.repoOwner }}/{{ $('Config Variables').item.json.repoName }}/commits",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github+json"
+            },
+            {
+              "name": "X-GitHub-Api-Version",
+              "value": "2022-11-28"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-commits",
+      "name": "Fetch Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.2,
+      "position": [650, 200],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "1",
+          "name": "GitHub API Token"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $('Config Variables').item.json.repoOwner }}/{{ $('Config Variables').item.json.repoName }}/issues",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "state",
+              "value": "closed"
+            },
+            {
+              "name": "since",
+              "value": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            },
+            {
+              "name": "filter",
+              "value": "all"
+            }
+          ]
+        },
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github+json"
+            },
+            {
+              "name": "X-GitHub-Api-Version",
+              "value": "2022-11-28"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-issues",
+      "name": "Fetch Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.2,
+      "position": [650, 400],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "1",
+          "name": "GitHub API Token"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $('Config Variables').item.json.repoOwner }}/{{ $('Config Variables').item.json.repoName }}/pulls",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "state",
+              "value": "closed"
+            },
+            {
+              "name": "sort",
+              "value": "updated"
+            },
+            {
+              "name": "direction",
+              "value": "desc"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github+json"
+            },
+            {
+              "name": "X-GitHub-Api-Version",
+              "value": "2022-11-28"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-prs",
