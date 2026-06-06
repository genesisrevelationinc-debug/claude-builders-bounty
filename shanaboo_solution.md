 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +0,0 @@
+# n8n + Claude — Weekly Dev Summary Workflow
+
+Auto-generates a narrative weekly summary of GitHub repo activity via n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import** `workflow.json` into your n8n instance (Settings → Import)
+2. **Set credentials**: Add your GitHub Personal Access Token, Claude API Key, and Email (or Webhook) in n8n Credentials
+3. **Configure variables**: Open the "Set Config" node and set `repo`, `channel` (or email), and `language` (`EN` or `FR`)
+4. **Activate** the workflow and ensure the Cron trigger is enabled
+5. **Test** manually by clicking "Execute Workflow" — check your destination for the summary
+
+## Delivery Options
+
+- **Email**: Uses n8n's built-in Email node (SMTP or SendGrid)
+- **Discord/Slack**: Replace the Email node with an HTTP Request node pointing to your webhook URL
+
+## Required Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repo` | GitHub owner/repo | `claude-builders-bounty/claude-builders-bounty` |
+| `channel` | Email address or webhook URL | `dev-updates@company.com` |
+| `language` | Output language | `EN` or `FR` |
+
+## Screenshot
+
+> Add a screenshot of a successful execution here: `assets/success-screenshot.png`
+
+## License
+
+MIT
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/workflow.json
@@ -0,0 +1,0 @@
+{
+  "name": "Weekly Dev Summary - Claude + n8n",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "triggerAtHour": 17,
+              "triggerAtDay": 5
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron-weekly",
+      "name": "Weekly Cron Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [250, 300]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "repo",
+              "value": "={{ $env.GITHUB_REPO || \"claude-builders-bounty/claude-builders-bounty\" }}"
+            },
+            {
+              "name": "channel",
+              "value": "={{ $env.DESTINATION_CHANNEL || \"dev-updates@example.com\" }}"
+            },
+            {
+              "name": "language",
+              "value": "={{ $env.LANGUAGE || \"EN\" }}"
+            },
+            {
+              "name": "since",
+              "value": "={{ DateTime.now().minus({ days: 7 }).toISO() }}"
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
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/commits",
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
+          "id": "github-token",
+          "name": "GitHub API Token"
+        }
+      }
+    },
+    {
+      "parameters": {
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
+      "name": "GitHub Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [650, 400],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-token",
+          "name": "GitHub API Token"
+        }
+      }
+    },
+    {
+      "parameters": {
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
+      },
+      "id": "github-prs",
+      "name": "GitHub Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [650, 600],
+      "credentials": {
+        "httpHeaderAuth": {
+          "id": "github-token",
+          "name": "GitHub API Token"
+        }
+      }
+    },
+    {
+      "parameters": {
+       