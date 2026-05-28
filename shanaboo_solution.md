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
+2. **Set credentials**: Add your GitHub token and Claude API key in *Settings → Credentials*
+3. **Configure variables**: Edit the *Set Config* node with your repo, destination, and language
+4. **Activate**: Toggle the workflow to *Active* — it runs Fridays at 5pm
+5. **Test**: Click *Execute Workflow* to verify, check your email/Discord for the summary
+
+## Required Credentials
+
+- `githubApi`: GitHub personal access token (classic) with `repo` scope
+- `anthropicApi`: Anthropic API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Configurable Variables
+
+| Variable | Description | Default |
+|----------|-------------|---------|
+| `githubRepo` | Target repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
+| `destination` | Email address or webhook URL | `your-email@example.com` |
+| `language` | Summary language: `EN` or `FR` | `EN` |
+| `deliveryMethod` | `email` or `webhook` | `email` |
+
+## Delivery Options
+
+- **Email**: Configure SMTP credentials in n8n, set `deliveryMethod` to `email`
+- **Discord/Slack**: Set `deliveryMethod` to `webhook` and paste your webhook URL in `destination`
+
+## Tested On
+
+- n8n v1.50.0 (self-hosted)
+- Claude API: `claude-sonnet-4-20250514`
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+---
+
+*Part of the Claude Builders Bounty — MIT License*
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,530 @@
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
+              "triggerAtDayOfWeek": "Friday",
+              "triggerAtHour": 17,
+              "triggerAtMinute": 0
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron",
+      "name": "Weekly Cron",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [250, 300]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "githubRepo",
+              "value": "={{ $env.GITHUB_REPO || \"claude-builders-bounty/claude-builders-bounty\" }}"
+            },
+            {
+              "name": "destination",
+              "value": "={{ $env.DESTINATION || \"your-email@example.com\" }}"
+            },
+            {
+              "name": "language",
+              "value": "={{ $env.LANGUAGE || \"EN\" }}"
+            },
+            {
+              "name": "deliveryMethod",
+              "value": "={{ $env.DELIVERY_METHOD || \"email\" }}"
+            }
+          ]
+        }
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 2,
+      "position": [450, 300]
+    },
+    {
+      "parameters": {
+        "jsCode": "const now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst formatDate = (d) => d.toISOString().split('T')[0];\nreturn [{\n  json: {\n    since: formatDate(oneWeekAgo),\n    until: formatDate(now)\n  }\n}];"
+      },
+      "id": "calc-dates",
+      "name": "Calculate Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [650, 300]
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
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth"
+      },
+      "id": "github-commits",
+      "name": "Fetch Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [850, 150],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-api-cred",
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
+        "authentication": "genericCredentialType",
