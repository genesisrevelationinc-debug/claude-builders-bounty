 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,45 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
+3. **Configure variables**: Open the workflow and edit the *Set Config* node — set `repoOwner`, `repoName`, `language`, and `webhookUrl`
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Test**: Click *Execute Workflow* to run manually, or wait for the weekly cron trigger
+
+## What It Does
+
+- Runs every Friday at 5:00 PM
+- Fetches commits, closed issues, and merged PRs from the past 7 days
+- Sends them to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- Delivers the summary via Discord webhook (configurable)
+
+## Required Credentials
+
+- `githubApi`: GitHub Personal Access Token (classic) with `repo` scope
+- `anthropicApi`: Anthropic API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Configurable Variables
+
+| Variable | Description | Default |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `language` | Summary language (`EN` or `FR`) | `EN` |
+| `webhookUrl` | Discord webhook URL | — |
+
+## Output Example
+
+> **Weekly Dev Summary — claude-builders-bounty**
+>
+> This week saw 12 commits, 3 closed issues, and 2 merged PRs. The team focused on refactoring the authentication module and improving test coverage. Notable PR: #42 "Add OAuth2 support" by @alice.
+
+## Troubleshooting
+
+- **No data fetched**: Check that your GitHub token has access to the repo
+- **Claude API error**: Verify your Anthropic API key and billing status
+- **Webhook not sending**: Test the webhook URL with `curl` first
+
+*Tested on n8n v1.50+*
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,530 @@
+{
+  "name": "Weekly Dev Summary - n8n + Claude",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "hoursInterval": 168,
+              "triggerAtHour": 17,
+              "triggerAtMinute": 0,
+              "triggerAtDay": 5
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron",
+      "name": "Weekly Friday 5PM",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
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
+              "value": "https://discord.com/api/webhooks/YOUR_WEBHOOK"
+            }
+          ]
+        }
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 2,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "// Calculate date range for the past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nconst toISO = (d) => d.toISOString();\n\nreturn {\n  json: {\n    since: toISO(sevenDaysAgo),\n    until: toISO(now),\n    sinceDateOnly: sevenDaysAgo.toISOString().split('T')[0]\n  }\n};"
+      },
+      "id": "calc-dates",
+      "name": "Calc Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits",
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
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Authorization",
+              "value": "=token {{ $credentials.githubApi.apiKey }}"
+            },
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
+      "type": "n8n-n