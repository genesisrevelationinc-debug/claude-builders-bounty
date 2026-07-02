 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,56 @@
+# n8n Weekly Dev Summary Workflow
+
+Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n + Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and email/SMTP or webhook credentials in n8n *Settings → Credentials*
+
+3. **Configure variables**: Open the workflow and edit the *Set Config* node with your repo, destination, and language
+
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+
+5. **Test**: Click *Execute Workflow* manually or wait for the next Friday 5pm trigger to verify
+
+---
+
+## Required Credentials
+
+| Service | Type | How to get |
+|---------|------|-----------|
+| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
+| Claude | API Key | [Anthropic Console](https://console.anthropic.com/) |
+| Email/SMTP | SMTP credentials | Your email provider (Gmail, SendGrid, etc.) |
+| **OR** Discord | Webhook URL | Discord channel → Integrations → Webhooks |
+| **OR** Slack | Webhook URL | Slack app → Incoming Webhooks |
+
+## Configurable Variables
+
+Edit the **Set Config** node to customize:
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `destinationChannel` | Email or webhook URL | `https://hooks.discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+| `deliveryMethod` | How to send | `email`, `discord`, or `slack` |
+
+## What It Does
+
+Every Friday at 5pm, the workflow:
+
+1. Calculates the date range for the past week
+2. Fetches commits, closed issues, and merged PRs from GitHub
+3. Sends the data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
+4. Delivers the formatted summary via your chosen channel
+
+## Testing
+
+Run the workflow manually and check the execution output. A successful run shows green checkmarks on all nodes.
+
+---
+
+## License
+
+MIT — same as the parent repo.
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1046 @@
+{
+  "name": "Weekly Dev Summary - GitHub + Claude",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "weeksInterval": 1,
+              "triggerAtDay": [
+                "Friday"
+              ],
+              "triggerAtHour": 17
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron-weekly",
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
+        "jsCode": "const now = new Date();\nconst lastWeek = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst formatDate = (d) => d.toISOString().split('T')[0];\n\nreturn [{\n  json: {\n    since: formatDate(lastWeek),\n    until: formatDate(now),\n    sinceISO: lastWeek.toISOString(),\n    untilISO: now.toISOString()\n  }\n}];"
+      },
+      "id": "calc-date-range",
+      "name": "Calculate Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "githubRepo",
+              "value": "claude-builders-bounty/claude-builders-bounty"
+            },
+            {
+              "name": "destinationChannel",
+              "value": "your-webhook-url-or-email@example.com"
+            },
+            {
+              "name": "language",
+              "value": "EN"
+            },
+            {
+              "name": "deliveryMethod",
+              "value": "discord"
+            }
+          ]
+        }
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        250,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/commits",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ $json.sinceISO }}"
+            },
+            {
+              "name": "until",
+              "value": "={{ $json.untilISO }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "options": {}
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
+          "id": "github-token",
+          "name": "GitHub Token"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/issues",
+        "sendQuery": true