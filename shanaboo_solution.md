 ```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, click "Add Workflow" → "Import from File" → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your GitHub API token and Claude API key in n8n's "Credentials" section
+
+3. **Configure variables**: Open the workflow and edit the "Set Config" node with your repo, channel, and language
+
+4. **Activate**: Toggle the workflow to "Active" — it runs every Friday at 5 PM
+
+5. **Test**: Click "Execute Workflow" to run manually and verify output
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `destinationWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Required Credentials
+
+- **GitHub API**: Personal access token with `repo` scope
+- **Claude API**: Anthropic API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Output
+
+The workflow delivers a narrative summary including:
+- Commit highlights
+- Closed issues summary
+- Merged PRs overview
+- Overall week sentiment
+
+## Testing
+
+See `screenshot-success.png` for a successful execution example.
+
+*Built for the Claude Builders Bounty — MIT License*
--- /dev/null
+++ b/workflows/weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,534 @@
+{
+  "name": "Weekly Dev Summary - Claude API",
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
+      "id": "trigger-cron",
+      "name": "Weekly Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ],
+      "cron": {
+        "mode": "custom",
+        "custom": "0 17 * * 5"
+      }
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
+              "name": "destinationWebhook",
+              "value": "={{ $env.DESTINATION_WEBHOOK || \"https://discord.com/api/webhooks/YOUR_WEBHOOK_URL\" }}"
+            },
+            {
+              "name": "language",
+              "value": "={{ $env.LANGUAGE || \"EN\" }}"
+            },
+            {
+              "name": "claudeModel",
+              "value": "claude-sonnet-4-20250514"
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
+        "url": "=https://api.github.com/repos/{{ $json.githubRepo }}/commits",
+        "sendQuery": true,
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ DateTime.now().minus({ days: 7 }).toISODate() }}"
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
+      "position": [
+        650,
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
+              "value": "={{ DateTime.now().minus({ days: 7 }).toISODate() }}"
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
+      "position": [
+        650,
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
+      "id":