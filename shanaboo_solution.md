 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,45 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Create n8n credentials for:
+   - GitHub (Personal Access Token with `repo` scope)
+   - Claude API (Anthropic API key)
+
+3. **Configure variables**: In the workflow, open the *Set Variables* node and set:
+   - `githubRepo`: e.g. `owner/repo-name`
+   - `webhookUrl`: Your Discord/Slack webhook URL
+   - `language`: `EN` or `FR`
+
+4. **Activate the workflow**: Toggle the workflow to *Active* — it runs automatically every Friday at 5 PM UTC
+
+5. **Test manually**: Click *Execute Workflow* to verify, then check your Discord/Slack channel
+
+---
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 17:00 UTC)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts the summary to Discord or Slack via webhook
+
+## Required Environment / Credentials
+
+| Service | Credential Type | Permissions Needed |
+|---------|---------------|-------------------|
+| GitHub | OAuth or Personal Access Token | `repo` (read) |
+| Claude API | API Key | Standard API access |
+
+## Customization
+
+- Change `language` to `FR` for French summaries
+- Modify the cron expression in the *Schedule Trigger* node for different timing
+- Adjust the Claude prompt in the *Claude API* node for different summary styles
+
+---
+
+*Tested on n8n v1.50+*
+
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,694 @@
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
+              "triggerAtDayOfWeek": 5
+            }
+          ]
+        }
+      },
+      "id": "trigger-weekly",
+      "name": "Weekly Cron Trigger",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "const now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\n\nreturn [\n  {\n    json: {\n      since: since,\n      now: now.toISOString()\n    }\n  }\n];"
+      },
+      "id": "set-dates",
+      "name": "Set Date Range",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "jsCode": "return [\n  {\n    json: {\n      githubRepo: \"{{ $env.GITHUB_REPO || 'owner/repo' }}\",\n      webhookUrl: \"{{ $env.WEBHOOK_URL || 'https://discord.com/api/webhooks/...' }}\",\n      language: \"{{ $env.LANGUAGE || 'EN' }}\"\n    }\n  }\n];"
+      },
+      "id": "set-variables",
+      "name": "Set Variables",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 2,
+      "position": [
+        450,
+        100
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "listCommits",
+        "owner": "={{ $json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $json.githubRepo.split('/')[1] }}",
+        "since": "={{ $('Set Date Range').item.json.since }}",
+        "returnAll": true
+      },
+      "id": "github-commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        50
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
+        "owner": "={{ $('Set Variables').item.json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $('Set Variables').item.json.githubRepo.split('/')[1] }}",
+        "state": "closed",
+        "returnAll": true,
+        "additionalFields": {
+          "since": "={{ $('Set Date Range').item.json.since }}"
+        }
+      },
+      "id": "github-issues",
+      "name": "GitHub Closed Issues",
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
+        "resource": "pullRequest",
+        "operation": "get",
+        "owner": "={{ $('Set Variables').item.json.githubRepo.split('/')[0] }}",
+        "repository": "={{ $('Set Variables