 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-dev-summary/README.md
@@ -0,0 +1,52 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+An n8n workflow that automatically generates a weekly narrative summary of a GitHub repo's activity using the Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `workflow.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
+3. **Configure variables**: Edit the *Set Config* node to set your `repo`, `channelWebhook`, and `language` (EN/FR)
+4. **Set the webhook destination**: In the *Deliver Summary* node, paste your email, Discord, or Slack webhook URL
+5. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
+
+## What It Does
+
+- **Trigger**: Weekly cron (Friday 5:00 PM)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts the summary via webhook (Discord/Slack) or email
+
+## Required Credentials
+
+| Service | Credential Type | How to Get |
+|---------|---------------|------------|
+| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
+| Anthropic | API Key | [Anthropic Console](https://console.anthropic.com/settings/keys) |
+
+## Configurable Variables
+
+All set in the **Set Config** node:
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repo` | GitHub repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
+| `channelWebhook` | Discord/Slack webhook URL or email | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Nodes Overview
+
+| # | Node | Purpose |
+|---|------|---------|
+| 1 | Cron Trigger | Weekly schedule (Friday 5 PM) |
+| 2 | Set Config | Workflow variables |
+| 3 | Get Commits | GitHub API: commits from last 7 days |
+| 4 | Get Closed Issues | GitHub API: closed issues from last 7 days |
+| 5 | Get Merged PRs | GitHub API: merged PRs from last 7 days |
+| 6 | Build Prompt | Aggregates data into Claude prompt |
+| 7 | Claude API | Generates narrative summary |
+| 8 | Deliver Summary | Sends via webhook/email |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Tested on n8n v1.50.0*
--- /dev/null
+++ /workflows/n8n-claude-weekly-dev-summary/workflow.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - n8n + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtHour":17,"triggerAtDay":5}]},"options":{}},"id":"trigger-cron-weekly","name":"Weekly Cron (Friday 5PM)","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"trigger-cron-weekly"},{"parameters":{"values":{"string":[{"name":"repo","value":"={{ $env.GITHUB_REPO || \"claude-builders-bounty/claude-builders-bounty\" }}"},{"name":"channelWebhook","value":"={{ $env.WEBHOOK_URL }}"},{"name":"language","value":"={{ $env.SUMMARY_LANGUAGE || \"EN\" }}"},{"name":"sinceDate","value":"={{ DateTime.now().minus({ days: 7 }).toISODate() }}"}]},"options":{}},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.set","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repo }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.sinceDate }}T00:00:00Z"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"Get Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-api-creds","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repo }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.sinceDate }}T00:00:00Z"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"Get Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,300],"credentials":{"httpHeaderAuth":{"id":"github-api-creds","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repo }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"sort","value":"updated"},{"name":"direction","value":"desc"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"Get Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-api-creds","name":"GitHub API"}}},{"parameters":{"jsCode":"const commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) >= new Date(Date.now() - 7 * 24 * 60 * 60 * 1000));\n\nconst commitSummary = commits.map(c => `- ${c.commit.message.split('\\n')[0]} (${c.commit.author.name})`).slice(0, 20).join('\\n') || 'No commits this week.';\nconst issueSummary = issues.map(i => `- #${i.number}: ${i.title}`).slice(0, 20).join('\\n') || 'No closed issues this week.';\nconst prSummary = mergedPRs.map(p => `- #${p