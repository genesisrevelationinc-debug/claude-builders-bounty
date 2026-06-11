 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,42 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `n8n-claude-weekly-summary.json`.
+
+2. **Set credentials**: Add your **Claude API** and **GitHub API** credentials in n8n (*Settings → Credentials*).
+
+3. **Configure variables**: Open the workflow and edit the `Set Config` node with your repo, destination, and language.
+
+4. **Set up delivery**: Configure the email or webhook node (Discord/Slack) with your destination details.
+
+5. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM.
+
+---
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | GitHub owner/repo | `claude-builders-bounty/claude-builders-bounty` |
+| `destinationChannel` | Email or webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+---
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 5:00 PM)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts the summary via email or Discord/Slack webhook
+
+---
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Tested on n8n v1.0+*
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/n8n-claude-weekly-summary.json
@@ -0,0 +1,530 @@
+{
+  "name": "Claude Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "triggerAtHour": 17,
+              "triggerAtMinute": 0,
+              "triggerOnSpecificWeek": 1,
+              "triggerOnSpecificWeekDay": 5
+            }
+          ]
+        }
+      },
+      "id": "trigger-cron",
+      "name": "Weekly Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "const now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\nreturn [{ json: { since } }];"
+      },
+      "id": "calc-dates",
+      "name": "Calculate Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1.1,
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
+              "value": "={{ $env.GITHUB_REPO || \"claude-builders-bounty/claude-builders-bounty\" }}"
+            },
+            {
+              "name": "destinationChannel",
+              "value": "={{ $env.DESTINATION_CHANNEL || \"\" }}"
+            },
+            {
+              "name": "language",
+              "value": "={{ $env.LANGUAGE || \"EN\" }}"
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
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "listCommits",
+        "owner": "={{ $json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $json.githubRepo.split('/')[1] }}",
+        "since": "={{ $json.since }}",
+        "returnAll": true
+      },
+      "id": "github-commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        700,
+        200
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "github-creds",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getIssues",
+        "owner": "={{ $json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $json.githubRepo.split('/')[1] }}",
+        "state": "closed",
+        "since": "={{ $json.since }}",
+        "returnAll": true
+      },
+      "id": "github-issues",
+      "name": "GitHub Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        700,
+        400
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "github-creds",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "get",
+        "owner": "={{ $json.githubRepo.split('/')[0] }}",
n        "repository": "={{ $json.githubRepo.split('/')[1] }}",
+        "state": "closed",
+        "returnAll": true
+      },
+      "id": "github-prs",
+      "name": "GitHub Merged PRs",
+      "