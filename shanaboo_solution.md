 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.
+
+## Quick Setup (5 steps)
+
+1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Create n8n credentials for:
+   - **GitHub API** (Personal Access Token with `repo` scope)
+   - **Anthropic Claude API** (API key from [console.anthropic.com](https://console.anthropic.com))
+
+3. **Configure variables**: Open the workflow and edit these in *Workflow Settings* → *Variables*:
+   - `githubRepo` — target repo (e.g., `owner/repo-name`)
+   - `destinationWebhook` — email SMTP or Discord/Slack webhook URL
+   - `language` — `EN` or `FR`
+   - `deliveryMethod` — `email`, `discord`, or `slack`
+
+4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM UTC
+
+5. **Test manually**: Click *Execute Workflow* to verify, then check your destination channel
+
+---
+
+## Delivery Options
+
+| Method | Configuration |
+|--------|---------------|
+| **Email** | Set SMTP credentials + `destinationWebhook` as recipient email |
+| **Discord** | Paste Discord webhook URL in `destinationWebhook` |
+| **Slack** | Paste Slack incoming webhook URL in `destinationWebhook` |
+
+## Required GitHub Token Scopes
+
+- `repo` (for private repos)
+- `public_repo` (for public repos, minimum)
+
+## Claude Model
+
+Uses `claude-sonnet-4-20250514` via Anthropic Messages API.
+
+---
+*Part of the Claude Builders Bounty program*
--- /dev/null
+++ workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1047 @@
+{
+  "name": "Weekly Dev Summary - GitHub + Claude",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "expression": "1"
+            }
+          ]
+        }
+      },
+      "id": "cron-trigger",
+      "name": "Weekly Cron Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [
+        250,
+        300
+      ],
+      "cronExpression": "0 17 * * 5"
+    },
+    {
+      "parameters": {
+        "jsCode": "// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString();\nconst until = now.toISOString();\n\nreturn [\n  {\n    json: {\n      since,\n      until,\n      repo: $env.GITHUB_REPO || 'owner/repo-name'\n    }\n  }\n];"
+      },
+      "id": "date-calc",
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
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/commits",
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
+        "genericAuthType": "httpHeaderAuth"
+      },
+      "id": "github-commits",
+      "name": "Fetch Commits",
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
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/issues",
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
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth"
+      },
+      "id": "github-issues",
+      "name": "Fetch Closed Issues",
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
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/pulls",
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
+     