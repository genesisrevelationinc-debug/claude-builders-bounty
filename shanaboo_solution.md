 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity using n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, click *Add Workflow* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your **Claude API** key (Anthropic) and **GitHub Personal Access Token** in n8n *Settings → Credentials*
+
+3. **Configure variables**: Open the *Set Config* node and edit:
+   - `githubRepo` — e.g. `owner/repo`
+   - `webhookUrl` — your Discord/Slack webhook URL
+   - `language` — `EN` or `FR`
+
+4. **Activate the workflow**: Toggle the workflow *Active* in n8n
+
+5. **Test manually**: Click *Execute Workflow* or wait for the Friday 5 PM cron trigger
+
+---
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 17:00)
+- **Fetches**: Commits, closed issues, merged PRs from the past 7 days via GitHub API
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts the summary to a Discord or Slack webhook
+
+## Required Credentials
+
+| Service | Credential Type |
+|---------|-----------------|
+| Anthropic (Claude) | API Key |
+| GitHub | Personal Access Token |
+
+## Nodes Overview
+
+| Node | Purpose |
+|------|---------|
+| Cron | Weekly trigger (Friday 17:00) |
+| Set Config | Workflow variables |
+| GitHub (3x) | Fetch commits, issues, PRs |
+| Claude API | Generate narrative summary |
+| HTTP Request | Send to Discord/Slack webhook |
+
+## License
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
+              "triggerAtHour": 17,
+              "triggerAtMinute": 0,
+              "triggerDay": "Friday"
+            }
+          ]
+        }
+      },
+      "id": "cron-trigger",
+      "name": "Weekly Cron",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "githubRepo",
+              "value": "={{ $json.githubRepo || \"owner/repo\" }}"
+            },
+            {
+              "name": "webhookUrl",
+              "value": "={{ $json.webhookUrl || \"https://discord.com/api/webhooks/...\" }}"
+            },
+            {
+              "name": "language",
+              "value": "={{ $json.language || \"EN\" }}"
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
+        "resource": "repository",
+        "operation": "listCommits",
+        "owner": "={{ $json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $json.githubRepo.split('/')[1] }}",
+        "since": "={{ DateTime.now().minus({ days: 7 }).toISO() }}",
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
+          "id": "github-creds",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getAll",
+        "owner": "={{ $json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $json.githubRepo.split('/')[1] }}",
+        "state": "closed",
+        "since": "={{ DateTime.now().minus({ days: 7 }).toISO() }}",
+        "returnAll": true
+      },
+      "id": "github-issues",
+      "name": "GitHub Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
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
+        "operation": "getAll",
+        "owner": "={{ $json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $json.githubRepo.split('/')[1] }}",
+        "state": "closed",
+        "returnAll": true
+      },
+      "id": "github-prs",
+      "name": "GitHub Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
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
+        "jsCode": "const commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json ||