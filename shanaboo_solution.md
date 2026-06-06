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
+### 1. Import the workflow
+In n8n, go to **Workflows → Import from File** and select `weekly-dev-summary.json`.
+
+### 2. Set credentials
+Configure these credentials in n8n:
+- **GitHub API**: Personal access token with `repo` scope
+- **Claude API**: Anthropic API key
+- **Discord Webhook** (or configure Email/SMTP instead)
+
+### 3. Configure variables
+Open the workflow and edit the **Set Config** node:
+- `repoOwner` / `repoName`: Target GitHub repository
+- `discordWebhook`: Your Discord channel webhook URL
+- `language`: `EN` or `FR`
+
+### 4. Activate the schedule
+The **Cron** node is pre-configured for Fridays at 5 PM. Adjust if needed.
+
+### 5. Activate & test
+Click **Activate**, then use **Test Workflow** to verify. Check your Discord channel for the summary.
+
+---
+
+## What It Does
+
+1. **Triggers weekly** (Friday 5 PM)
+2. **Fetches** commits, closed issues, and merged PRs from the past 7 days
+3. **Sends to Claude** (`claude-sonnet-4-20250514`) for narrative summarization
+4. **Delivers** the formatted summary to Discord (configurable)
+
+## Output Example
+
+> **Weekly Dev Summary: `owner/repo`**
+> 📅 May 12 – May 19, 2025
+>
+> This week saw 12 commits, 3 merged PRs, and 5 closed issues. The team focused on refactoring the authentication module and improving test coverage...
+
+## Requirements
+
+- n8n 1.0+ (self-hosted or cloud)
+- GitHub personal access token
+- Anthropic API access
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,518 @@
+{
+  "name": "Weekly Dev Summary - Claude + GitHub",
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
+      "id": "cron-trigger",
+      "name": "Weekly Cron",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ],
+      "webhookId": "weekly-cron"
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
+              "name": "discordWebhook",
+              "value": "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
+            },
+            {
+              "name": "language",
+              "value": "EN"
+            }
+          ]
+        }
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "const now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\n\nreturn [{\n  json: {\n    since: since,\n    sinceDate: since.split('T')[0]\n  }\n}];"
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
+        "url": "=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits",
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
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth"
+      },
+      "id": "github-commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [
+        850,
+        100
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
+        "url": "=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues",
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
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth"
+      },
+      "id": "github-issues",
+      "name": "GitHub Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1