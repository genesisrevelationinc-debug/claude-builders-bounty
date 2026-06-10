 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, click **Add Workflow** → **Import from File** → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub token, Claude API key, and webhook URL in **Settings → Credentials**
+3. **Configure variables**: Open the **Set Variables** node and set `repo`, `channel`, and `language`
+4. **Activate**: Toggle the workflow to **Active**
+5. **Test**: Click **Execute Workflow** or wait for the Friday 5pm cron trigger
+
+## Required Credentials
+
+- **GitHub API**: Personal access token with `repo` scope
+- **Claude API**: Anthropic API key (https://console.anthropic.com)
+- **Webhook**: Discord or Slack incoming webhook URL
+
+## Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repo` | GitHub repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
+| `channel` | Webhook destination URL | `https://hooks.slack.com/services/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## What It Does
+
+1. Triggers every Friday at 5:00 PM
+2. Fetches commits, closed issues, and merged PRs from the past 7 days
+3. Sends data to Claude API for narrative summarization
+4. Posts the formatted summary to your configured channel
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Include a screenshot of a successful execution from your n8n instance here.*
+
+## Files
+
+- `weekly-dev-summary.json` — Importable n8n workflow
+- `README.md` — This file
+
+---
+
+Built for [Claude Builders Bounty](https://github.com/claude-builders-bounty/claude-builders-bounty)
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,594 @@
+{
+  "name": "Weekly Dev Summary - Claude + n8n",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "expression": "1"
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron",
+      "name": "Weekly Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ],
+      "webhookId": "weekly-trigger"
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "repo",
+              "value": "={{ $env.GITHUB_REPO || \"claude-builders-bounty/claude-builders-bounty\" }}"
+            },
+            {
+              "name": "channel",
+              "value": "={{ $env.WEBHOOK_URL }}"
+            },
+            {
+              "name": "language",
+              "value": "={{ $env.SUMMARY_LANGUAGE || \"EN\" }}"
+            }
+          ]
+        }
+      },
+      "id": "set-variables",
+      "name": "Set Variables",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "const now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString().split('T')[0];\nreturn [{ json: { since, now: now.toISOString() } }];"
+      },
+      "id": "calculate-dates",
+      "name": "Calculate Dates",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/commits",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ $json.since }}"
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
+      "position": [
+        850,
+        200
+      ],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-api",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/issues",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "state",
+              "value": "closed"
+            },
+            {
+              "name": "since",
+              "value": "={{ $json.since }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-issues",
+      "name": "Fetch Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [
+        850,
+        400
+      ],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-api",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+       