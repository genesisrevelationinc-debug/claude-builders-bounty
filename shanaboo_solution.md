 ```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary/README.md
@@ -0,0 +1,35 @@
+# n8n Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import** `workflow.json` into your n8n instance (Settings → Workflows → Import)
+2. **Set credentials** for GitHub, Claude API, and your delivery channel (email/Discord/Slack)
+3. **Configure** the `Configuration` node variables: repo, destination, language
+4. **Activate** the workflow — it runs every Friday at 5 PM
+5. **Test** manually with the "Execute Workflow" button
+
+## Required Credentials
+
+- **GitHub**: Personal access token with `repo` scope
+- **Claude API**: Anthropic API key
+- **Delivery**: One of:
+  - SendGrid / SMTP (email)
+  - Discord webhook URL
+  - Slack webhook URL
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `destinationChannel` | Where to send summary | `discord` or `slack` or `email` |
+| `language` | Summary language | `EN` or `FR` |
+| `webhookUrl` | Webhook URL for Discord/Slack | `https://discord.com/api/webhooks/...` |
+| `emailTo` | Recipient email (if email) | `team@example.com` |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+*Example: Workflow execution showing GitHub data fetch, Claude summary generation, and Discord delivery*
+
--- /dev/null
+++ /workflows/weekly-dev-summary/workflow.json
@@ -0,0 +1,592 @@
+{
+  "name": "Weekly Dev Summary - GitHub + Claude API",
+  "nodes": [
+    {
+      "Node-1": {
+        "id": "trigger-cron-weekly",
+        "name": "Weekly Cron Trigger",
+        "type": "n8n-nodes-base.cron",
+        "position": [250, 300],
+        "parameters": {
+          "rule": {
+            "interval": [
+              {
+                "field": "weekday",
+                "value": "5"
+              },
+              {
+                "field": "hour",
+                "value": "17"
+              },
+              {
+                "field": "minute",
+                "value": "0"
+              }
+            ]
+          }
+        },
+        "typeVersion": 1
+      }
+    },
+    {
+      "Node-2": {
+        "id": "config-variables",
+        "name": "Configuration",
+        "type": "n8n-nodes-base.set",
+        "position": [450, 300],
+        "parameters": {
+          "values": {
+            "string": [
+              {
+                "name": "githubRepo",
+                "value": "claude-builders-bounty/claude-builders-bounty"
+              },
+              {
+                "name": "destinationChannel",
+                "value": "discord"
+              },
+              {
+                "name": "language",
+                "value": "EN"
+              },
+              {
+                "name": "webhookUrl",
+                "value": "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
+              },
+              {
+                "name": "emailTo",
+                "value": "team@example.com"
+              },
+              {
+                "name": "githubToken",
+                "value": "={{ $credentials.githubApi.apiKey }}"
+              }
+            ]
+          }
+        },
+        "typeVersion": 2
+      }
+    },
+    {
+      "Node-3": {
+        "id": "github-commits",
+        "name": "GitHub - Fetch Commits",
+        "type": "n8n-nodes-base.httpRequest",
+        "position": [650, 150],
+        "parameters": {
+          "method": "GET",
+          "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/commits",
+          "sendQuery": true,
+          "queryParameters": {
+            "parameters": [
+              {
+                "name": "since",
+                "value": "={{ DateTime.now().minus({ days: 7 }).toISO() }}"
+              },
+              {
+                "name": "per_page",
+                "value": "100"
+              }
+            ]
+          },
+          "sendHeaders": true,
+          "headerParameters": {
+            "parameters": [
+              {
+                "name": "Authorization",
+                "value": "=Bearer {{ $json.githubToken }}"
+              },
+              {
+                "name": "Accept",
+                "value": "application/vnd.github.v3+json"
+              }
+            ]
+          }
+        },
+        "typeVersion": 1
+      }
+    },
+    {
+      "Node-4": {
+        "id": "github-issues",
+        "name": "GitHub - Fetch Closed Issues",
+        "type": "n8n-nodes-base.httpRequest",
+        "position": [650, 300],
+        "parameters": {
+          "method": "GET",
+          "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/issues",
+          "sendQuery": true,
+          "queryParameters": {
+            "parameters": [
+              {
+                "name": "state",
+                "value": "closed"
+              },
+              {
+                "name": "since",
+                "value": "={{ DateTime.now().minus({ days: 7 }).toISO() }}"
+              },
+              {
+                "name": "per_page",
+                "value": "100"
+              }
+            ]
+          },
+          "sendHeaders": true,
+          "headerParameters": {
+            "parameters": [
+              {
+                "name": "Authorization",
+                "value": "=Bearer {{ $json.githubToken }}"
+              },
+              {
+                "name": "Accept",
+                "value": "application/vnd.github.v3+json"
+              }
+            ]
+          }
+        },
+        "typeVersion": 1
+      }
+    },
+    {
+      "Node-5": {
+        "id": "github-prs",
+        "name": "GitHub - Fetch Merged PRs",
+