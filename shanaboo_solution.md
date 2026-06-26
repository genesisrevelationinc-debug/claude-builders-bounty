 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and Claude API.
+
+## Setup (5 steps)
+
+### 1. Import the workflow
+In n8n, go to **Workflows → Import from File** and select `weekly-dev-summary.json`.
+
+### 2. Set credentials
+Create three credentials in n8n:
+- **Claude API**: Add your Anthropic API key
+- **GitHub API**: Add a GitHub personal access token (needs `repo` scope)
+- **Discord Webhook** (or email): Add your Discord webhook URL
+
+### 3. Configure workflow variables
+Open the workflow and edit the **Set Config** node:
+- `repoOwner` / `repoName`: Target GitHub repository
+- `discordWebhook`: Your Discord channel webhook URL
+- `language`: `EN` or `FR`
+
+### 4. Activate the schedule
+The **Schedule Trigger** is set to Fridays at 5:00 PM. Adjust the cron expression if needed.
+
+### 5. Activate & test
+Click **Activate**, then click **Execute Workflow** to test manually. Check your Discord channel for the summary.
+
+---
+
+## Delivery Method
+
+**Discord webhook** (configurable in the workflow). To use email instead, replace the Discord node with an SMTP node and update the `discordWebhook` variable to your email configuration.
+
+## Required n8n Nodes
+
+- Schedule Trigger
+- HTTP Request (GitHub API)
+- HTTP Request (Claude API)
+- HTTP Request (Discord webhook)
+- Set (configuration variables)
+- Code (data transformation)
+- Merge
+
+## Screenshot
+
+![Successful execution](screenshot.png) — *Add your screenshot here after testing*
+
+--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - Claude + n8n","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","value":1}],"weeks":1}},"id":"schedule-trigger","name":"Schedule Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-summary-trigger"},{"parameters":{"jsCode":"// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString();\n\nreturn [{\n  json: {\n    since: since,\n    until: now.toISOString(),\n    repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.REPO_NAME || 'claude-builders-bounty',\n    language Boulder: $env.DISCORD_WEBHOOK || 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL',\n    language: $env.LANGUAGE || 'EN',\n    claudeModel: 'claude-sonnet-4-20250514'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"until","value":"={{ $json.until }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,600],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"jsCode":"// Filter PRs merged in the date range\nconst since = new Date($input.all()[0].json.since);\nconst prs = $input.all()[0].json;\n\nif (!Array.isArray(prs)) {\n  return [{ json: { mergedPRs: [] } }];\n}\n\nconst mergedPRs = prs.filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedAt = new Date(pr.merged_at);\n  return mergedAt >= since;\n});\n\nreturn [{ json: { mergedPRs } }];"},"id":"filter-merged-prs","name":"Filter Merged PRs","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,600]},{"parameters":{"jsCode":"// Combine all data for Claude\nconst commits = $input.all().find(n => n.name === 'GitHub Commits')?.json || [];\nconst issues = $input.all().find(n => n.name === 'GitHub Issues')?.json || [];\nconst prs = $input.all().find(n => n.name === 'Filter Merged PRs')?.json?.mergedPRs || [];\nconst config = $input.all().find(n => n.name === 'Set Config')?.json || {};\n\nconst commitMessages = commits.map(c => `- ${c.commit.message.split('\\n')[0]} (${c.commit.author.name})`).slice(0, 20);\nconst issueTitles = issues.map(i => `- #${i.number}: ${i.title} (${i.state === 'closed' ? 'closed' : 'open'})`).slice(