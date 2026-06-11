 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and webhook URL (Discord/Slack) or SMTP credentials in *Settings → Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `channelWebhook`, and `language` (EN or FR)
+4. **Activate the workflow**: Toggle the workflow to *Active* in n8n
+5. **Test manually**: Click *Execute Workflow* or wait for the Friday 5 PM cron trigger
+
+## Workflow Overview
+
+- **Trigger**: Weekly cron (Fridays at 5:00 PM)
+- **GitHub Fetch**: Commits, closed issues, and merged PRs from the past 7 days
+- **Claude Summarization**: Narrative summary via `claude-sonnet-4-20250514`
+- **Delivery**: Discord/Slack webhook (configurable) or email
+- **Language**: English or French (configurable)
+
+## Required Credentials
+
+| Service | Credential Type | How to Obtain |
+|---------|---------------|---------------|
+| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
+| Claude (Anthropic) | API Key | [Anthropic Console](https://console.anthropic.com/settings/keys) |
+| Discord/Slack | Webhook URL | [Discord webhook guide](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) or [Slack incoming webhooks](https://api.slack.com/messaging/webhooks) |
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `channelWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Output language | `EN` or `FR` |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Screenshot of successful workflow execution on a live n8n instance.*
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","value":1}],"triggerAtHour":17,"triggerAtMinute":0,"triggerOnSpecificDay":[5]}},"id":"trigger-weekly","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"trigger-weekly"},{"parameters":{"values":{"string":[{"name":"repoOwner","value":"=YOUR_REPO_OWNER"},{"name":"repoName","value":"=YOUR_REPO_NAME"},{"name":"channelWebhook","value":"=YOUR_WEBHOOK_URL"},{"name":"language","value":"=EN"}]},"options":{}},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.set","typeVersion":1,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ DateTime.now().minus({ days: 7 }).toISO() }}"},{"name":"per_page","value":"100"}]},"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApi.apiKey }}"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,200],"credentials":{"githubApi":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ DateTime.now().minus({ days: 7 }).toISO() }}"},{"name":"per_page","value":"100"}]},"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApi.apiKey }}"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,300],"credentials":{"githubApi":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApi.apiKey }}"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,400],"credentials":{"githubApi":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"jsCode":"// Filter merged PRs from the past 7 days\nconst prs = $input.all()[0].json;\nconst oneWeekAgo = new Date();\noneWeekAgo.setDate(oneWeekAgo.getDate() - 7);\n\nconst mergedPRs = prs.filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedAt = new Date(pr.merged_at);\n  return mergedAt >= oneWeekAgo;\n});\n\nreturn [{ json: { mergedPRs } }];"},"id":"filter-merged-prs","name":"Filter Merged PRs","type":"n8n-nodes-base.code","typeVersion":1,"position":[850,400]},{"parameters":{"jsCode":"// Combine all GitHub data\nconst commits = $input.all().find(item => item.json.commits !== undefined)?.json.commits || [];\nconst issues = $input.all().find(item => item