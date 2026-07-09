Based on the issue, I need to create:
1. An n8n workflow JSON file
2. Update the README.md to mark the bounty as completed

Let me create the complete n8n workflow and update the README.

```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary.json
@@ -0,0 +1,298 @@
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
+        "jsCode": "// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nconst since = oneWeekAgo.toISOString();\nconst until = now.toISOString();\n\nreturn {\n  since: since,\n  until: until,\n  repo: $env.GITHUB_REPO || \"claude-builders-bounty/claude-builders-bounty\",\n  language: $env.SUMMARY_LANGUAGE || \"EN\"\n};"
+      },
+      "id": "set-date-range",
+      "name": "Set Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [450, 300]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/commits",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ $json.since }}"
+            },
+            {
+              "name": "until",
+              "value": "={{ $json.until }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "options": {
+          "timeout": 30000
+        }
+      },
+      "id": "fetch-commits",
+      "name": "Fetch Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
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
+        "url": "=https://api.github.com/repos/{{ $('Set Date Range').item.json.repo }}/issues",
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
+              "value": "={{ $('Set Date Range').item.json.since }}"
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
+        "options": {
+          "timeout": 30000
+        }
+      },
+      "id": "fetch-issues",
+      "name": "Fetch Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
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
+        "url": "=https://api.github.com/repos/{{ $('Set Date Range').item.json.repo }}/pulls",
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
+        "options": {
+          "timeout": 30000
+        }
+      },
+      "id": "fetch-prs",
+      "name": "Fetch Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [650, 600],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "1",
+          "name": "GitHub API Token"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "jsCode": "// Aggregate all fetched data\nconst commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json;\nconst config = $('Set Date Range').item.json;\n\n// Filter merged PRs (merged_at is not null)\nconst mergedPRs = Array.isArray(prs) ? prs.filter(pr => pr.merged_at && new Date(pr.merged_at) >= new Date(config.since)) : [];\n\n// Filter issues closed this week (exclude