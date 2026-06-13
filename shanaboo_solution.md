 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,44 @@
+# n8n + Claude — Weekly Dev Summary Workflow
+
+Automatically generate and deliver a weekly narrative summary of any GitHub repository's activity using n8n and the Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
+2. **Set credentials**: Add your GitHub Personal Access Token, Claude API Key, and (optional) Slack/Discord webhook or SMTP credentials in n8n *Settings* → *Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `channelWebhook`, and `language`
+4. **Activate the schedule**: Enable the `Weekly Cron` trigger node (default: Fridays at 5:00 PM UTC)
+5. **Save & activate**: Click *Save* and toggle the workflow to *Active*
+
+## Delivery Options
+
+- **Slack/Discord**: Set `channelWebhook` to your incoming webhook URL; the `Deliver Summary` node will POST the summary
+- **Email**: Replace the HTTP Request node with an *Send Email* node, or add SMTP credentials and use the *Send Email* node
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `channelWebhook` | Slack/Discord webhook URL | `https://hooks.slack.com/services/...` |
+| `language` | Summary language (`EN` or `FR`) | `EN` |
+
+## Workflow Overview
+
+1. **Weekly Cron Trigger** — runs every Friday at 5:00 PM UTC
+2. **Fetch Commits** — GitHub API: commits from the past 7 days
+3. **Fetch Closed Issues** — GitHub API: issues closed in the past 7 days
+4. **Fetch Merged PRs** — GitHub API: pull requests merged in the past 7 days
+5. **Build Prompt** — aggregates data into a structured prompt
+6. **Claude API** — sends prompt to `claude-sonnet-4-20250514` for narrative generation
+7. **Deliver Summary** — posts the generated summary to the configured channel
+
+## Testing
+
+Run the workflow manually by clicking *Execute Workflow* in n8n. Check the execution output for green checkmarks on all nodes.
+
+---
+
+*Compatible with n8n 1.0+ and Claude API (Anthropic Messages API)*
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/workflow.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - n8n + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","seconds":604800}],"triggerAtHour":17,"triggerAtMinute":0}},"id":"trigger-weekly-cron","name":"Weekly Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"jsCode":"// Calculate date range for past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString().split('T')[0] + 'T00:00:00Z';\n\nreturn [{\n  json: {\n    since: since,\n    until: now.toISOString(),\n    repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.REPO_NAME || 'claude-builders-bounty',\n    channelWebhook: $env.CHANNEL_WEBHOOK || '',\n    language: $env.SUMMARY_LANGUAGE || 'EN',\n    claudeModel: 'claude-sonnet-4-20250514'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{$json.since}}"},{"name":"until","value":"={{$json.until}}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"fetch-commits","name":"Fetch Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{$json.since}}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"fetch-issues","name":"Fetch Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,300],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"sort","value":"updated"},{"name":"direction","value":"desc"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"fetch-prs","name":"Fetch Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"jsCode":"const commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) >= new Date($input.first().json.since));\n\nconst commitList = commits.map(c => `- ${c.commit.message.split('\\n')[0]} (${c.author?.login || c.commit.author