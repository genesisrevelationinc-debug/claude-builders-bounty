 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
+3. **Configure variables**: Open the *Set Config* node and edit: `repoOwner`, `repoName`, `destinationWebhook`, `language` (EN/FR)
+4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM UTC
+5. **Test manually**: Click *Execute Workflow* to verify, then check your email/Discord/Slack for the summary
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 17:00 UTC)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts the summary via Discord/Slack webhook (configurable)
+
+## Required Credentials
+
+| Service | Credential Type | How to Get |
+|---------|---------------|------------|
+| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) — needs `repo` scope |
+| Anthropic | API Key | [Anthropic Console](https://console.anthropic.com/) |
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `destinationWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Output Example
+
+> **Weekly Dev Summary for claude-builders-bounty** (May 12–18, 2025)
+>
+> This week saw 12 commits, 3 closed issues, and 2 merged PRs. The team focused on improving the bounty workflow automation, with notable progress on the n8n integration...
+
+---
+
+*Built for the Claude Builders Bounty program.*
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1048 @@
+{
+  "name": "Weekly Dev Summary - GitHub + Claude API",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "weeksInterval": 1,
+              "triggerAtDay": "friday",
+              "triggerAtHour": 17
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron",
+      "name": "Weekly Cron Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString();\nconst until = now.toISOString();\n\nreturn [\n  {\n    json: {\n      since,\n      until,\n      repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n      repoName: $env.REPO_NAME || 'claude-builders-bounty',\n      language: $env.LANGUAGE || 'EN',\n      destinationWebhook: $env.WEBHOOK_URL || ''\n    }\n  }\n];"
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits?since={{ $json.since }}&until={{ $json.until }}&per_page=100",
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
+      "id": "fetch-commits",
+      "name": "Fetch Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [
+        650,
+        200
+      ],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-auth",
+          "name": "GitHub PAT"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues?state=closed&since={{ $json.since }}&per_page=100",
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
+      "id": "fetch-issues",
+      "name": "