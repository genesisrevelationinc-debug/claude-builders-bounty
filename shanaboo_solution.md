 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,49 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: In n8n *Settings* → *Credentials*, add:
+   - `claude-api` — your Anthropic API key
+   - `github-api` — a GitHub personal access token (needs `repo` scope)
+   - `discord-webhook` — your Discord webhook URL (or configure email/SMTP instead)
+
+3. **Configure variables**: Open the workflow and edit the *Set Variables* node:
+   - `repoOwner` / `repoName` — target GitHub repository
+   - `language` — `EN` or `FR`
+   - `discordWebhook` — your Discord webhook URL (or switch to the Email node)
+
+4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM UTC
+
+5. **Test manually**: Click *Execute Workflow* to verify, then check your Discord channel
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 17:00 UTC)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts the summary to a Discord webhook (configurable to email/Slack)
+
+## Required n8n Nodes
+
+- Cron node (trigger)
+- HTTP Request nodes (GitHub API, Claude API, Discord)
+- Set node (variables)
+- Code node (data processing)
+- No external npm packages needed
+
+## Customization
+
+- Switch the final *Discord* node to an *Email* or *Slack* node for alternative delivery
+- Adjust the cron expression in the *Schedule Trigger* node for different timing
+- Modify the Claude prompt in the *Claude API* node to change summary style
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+---
+
+*Created for [Claude Builders Bounty](https://github.com/claude-builders-bounty/claude-builders-bounty)*
+
+--- /dev/null
+++	/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","hoursInterval":168,"mode":"everyWeek","triggerAtHour":17,"triggerAtMinute":0}]},"options":{}},"id":"trigger-1","name":"Weekly Trigger (Friday 5PM)","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-trigger"},{"parameters":{"jsCode":"const now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString();\nconst until = now.toISOString();\nreturn [{ json: { since, until } }];"},"id":"set-dates","name":"Set Date Range","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,300]},{"parameters":{"jsCode":"const repoOwner = $env.GITHUB_REPO_OWNER || 'claude-builders-bounty';\nconst repoName = $env.GITHUB_REPO_NAME || 'claude-builders-bounty';\nconst language = $env.LANGUAGE || 'EN';\nconst discordWebhook = $env.DISCORD_WEBHOOK_URL || '';\nreturn [{ json: { repoOwner, repoName, language, discordWebhook } }];"},"id":"set-variables","name":"Set Variables","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,500]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $('Set Date Range').item.json.since }}"},{"name":"until","value":"={{ $('Set Date Range').item.json.until }}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"github-commits","name":"GitHub: Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"github-api"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $('Set Date Range').item.json.since }}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"github-issues","name":"GitHub: Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"github-api"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"sort","value":"updated"},{"name":"direction","value":"desc"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"github-prs","name":"GitHub: Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,600],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"github-api"}}},{"parameters":{"jsCode":"const commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst mergedPRs = prs.filter(pr => pr.merged_at);\n\nconst commitsText = commits.map(c => `- ${c.commit.message.split('\\n')[0]} (${c.author?.login || 'unknown'})`).join('\\n') || 'No commits this week.';\nconst issuesText = issues.map(i => `-