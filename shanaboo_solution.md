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
+1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your *Claude API* and *GitHub API* credentials in n8n *Settings → Credentials*
+
+3. **Configure variables**: Open the workflow and edit the `Set Config` node with your repo, channel, and language
+
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+
+5. **Test run**: Click *Execute Workflow* to verify, or wait for the Friday 5pm cron trigger
+
+---
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `destinationWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Output
+
+The workflow delivers a narrative summary including:
+- 📊 Commit highlights
+- ✅ Closed issues
+- 🔀 Merged PRs
+- 💡 Key themes and achievements
+
+## Requirements
+
+- n8n instance (cloud or self-hosted)
+- Claude API key (Anthropic console)
+- GitHub personal access token (for private repos, optional for public)
+
+---
+*Built for the Claude Builders Bounty*
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,530 @@
+{
+  "name": "Weekly Dev Summary - Claude API",
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
+              "name": "githubRepo",
+              "value": "claude-builders-bounty/claude-builders-bounty"
+            },
+            {
+              "name": "destinationWebhook",
+              "value": "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
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
+        "jsCode": "const now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst formatDate = (d) => d.toISOString().split('T')[0];\n\nreturn [{\n  json: {\n    since: formatDate(oneWeekAgo),\n    until: formatDate(now)\n  }\n}];"
+      },
+      "id": "calc-dates",
+      "name": "Calculate Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
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
n            {
+              "name": "since",
+              "value": "={{ $json.since }}T00:00:00Z"
+            },
+            {
+              "name": "until",
+              "value": "={{ $json.until }}T23:59:59Z"
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
+              "value": "={{ $json.since }}T00:00:00Z"
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
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/pulls",
+