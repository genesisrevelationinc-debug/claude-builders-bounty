 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,42 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and the Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`.
+
+2. **Set credentials**: Create n8n credentials for:
+   - **GitHub**: Personal access token with `repo` scope.
+   - **Claude API**: Anthropic API key from [console.anthropic.com](https://console.anthropic.com).
+   - **Delivery** (choose one):
+     - *Email*: SMTP credentials, or
+     - *Discord/Slack*: Webhook URL.
+
+3. **Configure variables**: Open the workflow, click the ⚙️ *Settings* tab, and set these environment variables (or edit the `Configuration` node):
+   | Variable | Description | Example |
+   |----------|-------------|---------|
+   | `githubRepo` | Target repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
+   | `destinationChannel` | Email address or webhook URL | `https://hooks.slack.com/services/...` |
+   | `language` | Summary language (`EN` or `FR`) | `EN` |
+
+4. **Activate the workflow**: Toggle the workflow to *Active*. It runs automatically every Friday at 5:00 PM.
+
+5. **Test manually**: Click *Execute Workflow* to run it immediately and verify delivery.
+
+---
+
+## Delivery Options
+
+- **Email**: Uses n8n's built-in *Send Email* node. Set `destinationChannel` to the recipient's email address.
+- **Slack/Discord**: Uses the *HTTP Request* node to POST to a webhook. Set `destinationChannel` to the webhook URL.
+
+> 💡 **Tip**: The workflow detects if `destinationChannel` contains `http` to choose between email and webhook automatically.
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+## License
+
+MIT
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,518 @@
+{
+  "name": "Weekly Dev Summary - Claude + n8n",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "value": 1
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
+        "jsCode": "// Configuration node - set your variables here\nconst config = {\n  githubRepo: $env.GITHUB_REPO || 'claude-builders-bounty/claude-builders-bounty',\n  destinationChannel: $env.DESTINATION_CHANNEL || 'your-email@example.com',\n  language: $env.LANGUAGE || 'EN',\n  claudeModel: 'claude-sonnet-4-20250514'\n};\n\n// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString().split('T')[0];\策
+        "T00:00:00Z";
+        
+return {
+  ...config,
+  since,
+  now: now.toISOString()
+};"
+      },
+      "id": "config-node",
+      "name": "Configuration",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "url": "={{ \"https://api.github.com/repos/\" + $json.githubRepo + \"/commits\" }}",
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
+          "id": "github-creds",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "url": "={{ \"https://api.github.com/repos/\" + $json.githubRepo + \"/issues\" }}",
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
+      "id": "github-issues",
+      "name": "GitHub Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [
+        650,
+        400
+      ],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-creds",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "url": "={{ \"https://api.github.com/repos/\" + $json.githubRepo + \"/pulls\" }}",
+        "sendQuery