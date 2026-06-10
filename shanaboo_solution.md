 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,45 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your *Anthropic API* and *GitHub* credentials in n8n *Settings → Credentials*
+
+3. **Configure variables**: Open the workflow and edit the **Set Config** node:
+   - `repoOwner` / `repoName` — target GitHub repository
+   - `discordWebhookUrl` — your Discord webhook URL (or switch to Email node)
+   - `language` — `EN` or `FR`
+
+4. **Activate**: Toggle the workflow *Active* — it runs every Friday at 5 PM
+
+5. **Test manually**: Click *Execute Workflow* to verify, then check your Discord channel
+
+---
+
+## Workflow Overview
+
+| Step | Node | Purpose |
+|------|------|---------|
+| 1 | Cron Trigger | Weekly schedule (Fri 17:00) |
+| 2 | Set Config | Variables: repo, language, webhook |
+| 3 | GitHub Commits | Fetch commits from last 7 days |
+| 4 | GitHub Issues | Fetch closed issues from last 7 days |
+| 5 | GitHub PRs | Fetch merged PRs from last 7 days |
+| 6 | Merge Data | Combine into single dataset |
+| 7 | Claude API | Generate narrative summary |
+| 8 | Discord Webhook | Deliver the summary |
+
+## Required n8n Nodes
+
+- n8n-nodes-base.cron
+- n8n-nodes-base.github
+- n8n-nodes-base.httpRequest (for Claude API)
+- n8n-nodes-base.discord (or n8n-nodes-base.email for email delivery)
+
+## Screenshot
+
+*(Add screenshot of successful execution here)*
+
+> 💡 To switch to email delivery: replace the Discord node with an *Send Email* node and update the config variable.

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
+              "triggerAtHour": 17,
+              "triggerAtMinute": 0,
+              "triggerAtDay": 5
+            }
+          ]
+        }
+      },
+      "id": "cron-trigger",
+      "name": "Weekly Cron",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "return [\n  {\n    json: {\n      repoOwner: $env.GITHUB_REPO_OWNER || 'claude-builders-bounty',\n      repoName: $env.GITHUB_REPO_NAME || 'claude-builders-bounty',\n      discordWebhookUrl: $env.DISCORD_WEBHOOK_URL || '',\n      language: $env.SUMMARY_LANGUAGE || 'EN',\n      daysBack: 7\n    }\n  }\n];"
+      },
+      "id": "set-config",
+      "name": "Set Config",
+      "type": "n8n-nodes-base.code",
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
+        "owner": "={{ $json.repoOwner }}",
+        "repository": "={{ $json.repoName }}",
+        "since": "={{ DateTime.now().minus({ days: $json.daysBack }).toISO() }}",
+        "returnAll": true
+      },
+      "id": "github-commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        150
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
+        "owner": "={{ $json.repoOwner }}",
n        "repository": "={{ $json.repoName }}",
+        "state": "closed",
+        "since": "={{ DateTime.now().minus({ days: $json.daysBack }).toISO() }}",
+        "returnAll": true
+      },
+      "id": "github-issues",
+      "name": "GitHub Issues",
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
+        "operation": "get",
+        "owner": "={{ $json.repoOwner }}",
+        "repository": "={{ $json.repoName }}",
+        "state": "closed",
+        "returnAll": true
+      },
+      "id": "github-prs",
+      "name": "GitHub PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        450
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
+        "jsCode": "const commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json