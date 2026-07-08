Based on the issue, I need to create:
1. An n8n workflow JSON file for the automated weekly dev summary
2. A README with setup instructions

Since the repo only shows README.md and LICENSE, I'll create the workflow file and update the README.

```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary.json
@@ -0,0 +1,438 @@
+{
+  "name": "Weekly Dev Summary - Claude API",
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
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo_owner }}/{{ $json.repo_name }}/commits",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ $json.week_start }}"
+            },
+            {
+              "name": "until",
+              "value": "={{ $json.week_end }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-commits",
+      "name": "Fetch Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [450, 200],
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
+        "url": "=https://api.github.com/repos/{{ $json.repo_owner }}/{{ $json.repo_name }}/issues",
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
+              "value": "={{ $json.week_start }}"
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
+        "options": {}
+      },
+      "id": "fetch-issues",
+      "name": "Fetch Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [450, 400],
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
+        "url": "=https://api.github.com/repos/{{ $json.repo_owner }}/{{ $json.repo_name }}/pulls",
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
+        "options": {}
+      },
+      "id": "fetch-prs",
+      "name": "Fetch Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [450, 600],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "1",
+          "name": "GitHub API Token"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "jsCode": "// Prepare date range for the past week\nconst now = new Date();\nconst weekStart = new Date(now);\nweekStart.setDate(now.getDate() - 7);\n\n// Get config variables\nconst repoFull = $input.first().json.repo || 'claude-builders-bounty/claude-builders-bounty';\nconst [repoOwner, repoName] = repoFull.split('/');\nconst language = $input.first().json.language || 'EN';\nconst destination = $input.first().json.destination || 'discord';\nconst webhookUrl = $input.first().json.webhook_url || '';\n\nreturn {\n  week_start: weekStart.toISOString(),\n  week_end: now.toISOString(),\n  repo_owner: repoOwner,\n  repo_name: repoName,\n  language: language,\n  destination: destination,\n  webhook_url: webhookUrl,\n  week_label: `${weekStart.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} - ${now.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}`\n};"
+      },
+      "id": "prepare-dates",
+      "name": "Prepare Date Range & Config",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [250, 500]
+    },
+    {
+      "parameters": {
+        "jsCode": "