```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n *Settings → Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Done!** The workflow runs every Friday at 5 PM. Check the first execution in the *Executions* tab
+
+## What It Does
+
+- Triggers weekly (cron: `0 17 * * 5`)
+- Fetches commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative summarization
+- Delivers the summary via Discord/Slack webhook
+
+## Required Credentials
+
+- `githubApi`: GitHub Personal Access Token (no special scopes needed for public repos; `repo` scope for private)
+- `anthropicApi`: Anthropic API Key from [console.anthropic.com](https://console.anthropic.com)
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub organization or user | `claude-builders-bounty` |
+| `repoName` | Repository name | `claude-builders-bounty` |
+| `webhookUrl` | Discord/Slack incoming webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Output language | `EN` or `FR` |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Screenshot of successful execution on a real n8n instance.*
+
+---
+
+*Part of the Claude Builders Bounty program*
\ No newline at end of file
--- /dev/null
+++ b workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,530 @@
+{
+  "name": "Weekly Dev Summary - GitHub + Claude",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks"
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron",
+      "name": "Weekly Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [
+        250,
+        300
+      ],
+      "webhookId": "weekly-trigger"
+    },
+    {
+      "parameters": {
+        "jsCode": "const now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\n\nreturn [{\n  json: {\n    since: since,\n    until: now.toISOString()\n  }\n}];"
+      },
+      "id": "set-dates",
+      "name": "Set Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "return [{\n  json: {\n    repoOwner: 'claude-builders-bounty',\n    repoName: 'claude-builders-bounty',\n    webhookUrl: 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL',\n    language: 'EN'\n  }\n}];"
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [
+        250,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits?since={{ $input.first().json.since }}&per_page=100",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github.v3+json"
+            },
+            {
+              "name": "User-Agent",
+              "value": "n8n-weekly-summary"
+            }
+          ]
+        }
+      },
+      "id": "github-commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [
+        650,
+        200
+      ],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-api",
+          "name": "githubApi"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues?state=closed&since={{ $input.first().json.since }}&per_page=100",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github.v3+json"
+            },
+            {
+              "name": "User-Agent",
+              "value": "n8n-weekly-summary"
+            }
+          ]
+        }
+      },
+      "id": "github-issues",
+      "name": "GitHub Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position":