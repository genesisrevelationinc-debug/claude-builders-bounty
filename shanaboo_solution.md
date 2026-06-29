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
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Create credentials in n8n for:
+   - GitHub (Personal Access Token with `repo` scope)
+   - Anthropic (Claude API key from [console.anthropic.com](https://console.anthropic.com))
+
+3. **Configure variables**: Open the workflow and edit the **Set Config** node:
+   - `repoOwner` — GitHub organization or user name
+   - `repoName` — repository name
+   - `language` — `EN` or `FR`
+   - `webhookUrl` — Discord/Slack webhook URL for delivery
+
+4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
+
+5. **Test it**: Click *Execute Workflow* to run manually and verify output in your channel
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 17:00)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
+- **Summarizes**: Claude `claude-sonnet--20250514` generates a narrative summary
+- **Delivers**: Posts to Discord/Slack via webhook
+
+## Screenshot
+
+![Successful execution](screenshot.png)
+
+## Requirements
+
+- n8n 1.0+ (self-hosted or cloud)
+- GitHub Personal Access Token
+- Anthropic API key
+- Discord or Slack webhook URL
+
+## License
+
+MIT
\ No newline at end of file
--- /dev/null
+++ b/workflows/weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,650 @@
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
+              "triggerAtHour": 17,
+              "triggerAtDay": 5
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
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nconst toISO = (d) => d.toISOString();\n\nreturn [{\n  json: {\n    since: toISO(oneWeekAgo),\n    until: toISO(now),\n    sinceDate: oneWeekAgo.toISOString().split('T')[0],\n    untilDate: now.toISOString().split('T')[0]\n  }\n}];"
+      },
+      "id": "set-date-range",
+      "name": "Set Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "// Configuration variables - EDIT THESE\nreturn [{\n  json: {\n    repoOwner: \"claude-builders-bounty\",\n    repoName: \"claude-builders-bounty\",\n    language: \"EN\",\n    webhookUrl: \"https://discord.com/api/webhooks/YOUR_WEBHOOK_URL\"\n  }\n}];"
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [
+        450,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "listCommits",
+        "owner": "={{ $json.repoOwner }}",
n        "repository": "={{ $json.repoName }}",
+        "since": "={{ $('Set Date Range').item.json.since }}",
+        "returnAll": true
+      },
+      "id": "github-commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        200
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "github-cred",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getAll",
+        "repository": {
+          "__rl": true,
+          "value": "={{ $json.repoName }}",
+          "mode": "name"
+        },
+        "owner": "={{ $json.repoOwner }}",
+        "filters": {
+          "state": "closed",
+          "since": "={{ $('Set Date Range').item.json.since }}"
+        },
+        "returnAll": true
+      },
+      "id": "github-issues",
+      "name": "GitHub Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        400
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "github-cred",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "getAll",
+        "repository": {
+          "__rl": true,
+          "value": "={{ $json.repoName }}",
+          "mode": "name"
+        },
+        "owner": "={{ $json.repoOwner }}",
+        "filters": {
+          "