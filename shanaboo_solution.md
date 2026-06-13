 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
+4. **Activate the workflow**: Toggle the workflow to *Active* — it runs automatically every Friday at 5 PM
+5. **Test manually**: Click *Execute Workflow* to verify — check the webhook channel for your summary
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 5:00 PM)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts the summary to a Discord/Slack webhook
+
+## Required Credentials
+
+| Service | Credential Type | How to Get |
+|---------|----------------|------------|
+| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
+| Anthropic | API Key | [Anthropic Console](https://console.anthropic.com/settings/keys) |
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `webhookUrl` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Screenshot
+
+![Successful n8n execution](screenshot.png)
+
+## License
+
+MIT
\ No newline at end of file
--- /dev/null
+++ workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","minutes":10080}]},"options":{}},"id":"trigger-cron-weekly","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"jsCode":"// Calculate date range for past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nconst toISO = (d) => d.toISOString();\n\nreturn [{\n  json: {\n    since: toISO(sevenDaysAgo),\n    until: toISO(now),\n    sinceDate: sevenDaysAgo.toISOString().split('T')[0],\n    untilDate: now.toISOString().split('T')[0]\n  }\n}];"},"id":"calc-date-range","name":"Calc Date Range","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"jsCode":"// Configurable variables\nreturn [{\n  json: {\n    repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.REPO_NAME || 'claude-builders-bounty',\n    webhookUrl: $env.WEBHOOK_URL || '',\n    language: $env.LANGUAGE || 'EN',\n    claudeModel: 'claude-sonnet-4-20250514'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[650,300]},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $('Calc Date Range').item.json.since }}"},{"name":"until","value":"={{ $('Calc Date Range').item.json.until }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[850,200],"credentials":{"githubApi":{"id":"github-api-creds","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $('Calc Date Range').item.json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[850,300],"credentials":{"githubApi":{"id":"github-api-creds","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[850,400],"credentials":{"githubApi":{"id":"github-api-creds","name":"GitHub API"}}},{"parameters":{"jsCode":"// Aggregate all GitHub data\nconst commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\n// Filter to merged PRs in date range\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) >= new Date($('Calc Date Range').item.json.since));\n\n// Filter issues closed in range (exclude PRs)\nconst closedIssues = issues.filter(issue => !issue.pull_request && issue.closed_at && new Date(issue.closed_at) >= new Date($('Calc Date Range').item