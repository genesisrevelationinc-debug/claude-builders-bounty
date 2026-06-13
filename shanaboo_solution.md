 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, click ⚙️ → Import → paste `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n Credentials
+3. **Configure variables**: Edit the `Configuration` node — set repo, channel webhook, and language
+4. **Activate**: Toggle the workflow to "Active" in n8n
+5. **Test**: Click "Execute Workflow" or wait for the Friday 5pm cron trigger
+
+## Required Credentials
+
+- **GitHub API**: Personal Access Token with `repo` scope
+- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Configuration
+
+Edit these in the `Configuration` node:
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `webhookUrl` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Output
+
+Every Friday at 5pm, the workflow:
+1. Fetches commits, closed issues, and merged PRs from the past 7 days
+2. Sends data to Claude API for narrative summarization
+3. Posts a formatted summary to your configured Discord/Slack channel
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+## Files
+
+- `weekly-dev-summary.json` — Importable n8n workflow
+- `README.md` — This file
+
+--- /dev/null
++++ workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
+@@ -0,0 +1,0 @@
+{
+  "name": "Weekly Dev Summary - GitHub + Claude API",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "triggerAtHour": 17,
+              "triggerAtMinute": 0,
+              "triggerOnSpecificWeekdays": ["5"]
+            }
+          ]
+        }
+      },
+      "id": "cron-trigger",
+      "name": "Weekly Cron (Friday 5pm)",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [250, 300]
+    },
+    {
+      "parameters": {
+        "jsCode": "return [\n  {\n    json: {\n      githubRepo: 'claude-builders-bounty/claude-builders-bounty',\n      webhookUrl: 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL',\n      language: 'EN',\n      daysBack: 7\n    }\n  }\n];"
+      },
+      "id": "config",
+      "name": "Configuration",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [450, 300]
+    },
+    {
+      "parameters": {
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/commits",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ DateTime.now().minus({ days: $json.daysBack }).toISO() }}"
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
+      "position": [650, 200],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-api",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/issues",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "state",
+              "value": "closed"
+            },
+            {
+              "name": "since",
+              "value": "={{ DateTime.now().minus({ days: $json.daysBack }).toISO() }}"
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
+      "typeVersion": 4.1,
+      "position": [650, 400],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-api",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/pulls",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "state",
+              "value": "closed"
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
+      "id": "github-prs",
+      "name": "GitHub Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [650, 600],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-api",
+          "name