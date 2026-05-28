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
+1. **Import workflow**: In n8n, click ⚙️ → Import → paste `workflow.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n Credentials
+3. **Configure variables**: Edit the `Configuration` node — set repo, destination, and language
+4. **Set destination**: Add your email/SMTP or webhook URL in the delivery node
+5. **Activate**: Toggle the workflow ON — runs every Friday at 5 PM
+
+## Required Credentials
+
+- **GitHub Personal Access Token** (classic, with `repo` scope)
+- **Anthropic API Key** (from [console.anthropic.com](https://console.anthropic.com))
+
+## Configurable Variables
+
+| Variable | Description | Default |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path (`owner/repo`) | `claude-builders-bounty/claude-builders-bounty` |
+| `language` | Summary language (`EN` or `FR`) | `EN` |
+| `destinationType` | `email` or `webhook` | `webhook` |
+| `webhookUrl` | Discord/Slack webhook URL | (empty) |
+
+## Delivery Options
+
+- **Email**: Configure SMTP credentials in n8n, set `destinationType` to `email`
+- **Webhook**: Paste a Discord or Slack webhook URL, set `destinationType` to `webhook`
+
+## Testing
+
+1. Set all variables in the `Configuration` node
2. Click **Execute Workflow** manually
3. Check your destination for the summary
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+---
+
+*Built for the Claude Builders Bounty — MIT License*
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/workflow.json
@@ -0,0 +1,1074 @@
+{
+  "name": "Weekly Dev Summary - GitHub + Claude",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "triggerAtHour": 17,
+              "triggerAtMinute": 0,
+              "triggerOnSpecificDays": [
+                "Friday"
+              ]
+            }
+          ]
+        }
+      },
+      "id": "cron-trigger",
+      "name": "Weekly Cron",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "// Configuration node - edit these values\nreturn [{\n  json: {\n    githubRepo: \"claude-builders-bounty/claude-builders-bounty\",\n    language: \"EN\",\n    destinationType: \"webhook\",\n    webhookUrl: \"\",\n    emailTo: \"\"\n  }\n}];"
+      },
+      "id": "config-node",
+      "name": "Configuration",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString();\n\nreturn [{\n  json: {\n    since: since,\n    until: now.toISOString(),\n    sinceDate: since.split('T')[0]\n  }\n}];"
+      },
+      "id": "date-range",
+      "name": "Date Range",
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
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/commits",
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
+        200
+      ],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-token",
+          "name": "GitHub Token"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "method": "GET",
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
+              "value": "={{ $json.since }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "headerParameters": {
+          "parameters": [
+            {
+              "name