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
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
+3. **Configure variables**: Open the workflow and edit the `Configuration` node — set your repo, destination, and language
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Test**: Click *Execute Workflow* to run manually, or wait for the weekly cron trigger
+
+## What it does
+
+- Runs every Friday at 5 PM
+- Fetches commits, closed issues, and merged PRs from the past 7 days
+- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
+- Delivers the summary via Discord webhook (configurable)
+
+## Required Credentials
+
+| Service | Type | How to get |
+|---------|------|-----------|
+| GitHub | Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
+| Anthropic | API Key | [Anthropic Console](https://console.anthropic.com/) |
+
+## Configurable Variables
+
+| Variable | Description | Default |
+|----------|-------------|---------|
+| `githubRepo` | Target repository (format: `owner/repo`) | `claude-builders-bounty/claude-builders-bounty` |
+| `discordWebhookUrl` | Discord webhook URL for delivery | — |
+| `language` | Output language (`EN` or `FR`) | `EN` |
+
+## Output Example
+
+> 📊 **Weekly Dev Summary** — `claude-builders-bounty/claude-builders-bounty`
+> 
+> This week, the team merged 3 pull requests, closed 5 issues, and pushed 12 commits. Key highlights include...
+
+## Screenshot
+
+*(Include screenshot of successful execution here)*
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtDay":[5],"triggerAtHour":17,"triggerAtMinute":0}]},"options":{}},"id":"trigger-weekly","name":"Weekly Cron (Friday 5PM)","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"trigger-weekly"},{"parameters":{"jsCode":"// Configuration variables\nconst config = {\n  githubRepo: $env.GITHUB_REPO || 'claude-builders-bounty/claude-builders-bounty',\n  discordWebhookUrl: $env.DISCORD_WEBHOOK_URL || '',\n  language: ($env.LANGUAGE || 'EN').toUpperCase(),\n  anthropicModel: 'claude-sonnet-4-20250514'\n};\n\n// Validate\nif (!['EN','FR'].includes(config.language)) {\n  throw new Error('Language must be EN or FR');\n}\n\nreturn [{ json: config }];"},"id":"config-node","name":"Configuration","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"jsCode":"// Calculate date range for past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\n\nreturn [{\n  json: {\n    since,\n    until: now.toISOString(),\n    owner: $input.first().json.githubRepo.split('/')[0],\n    repo: $input.first().json.githubRepo.split('/')[1]\n  }\n}];"},"id":"date-range","name":"Calculate Date Range","type":"n8n-nodes-base.code","typeVersion":2,"position":[650,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.owner }}/{{ $json.repo }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub: Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[850,200],"credentials":{"githubApi":"github-api"}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.owner }}/{{ $json.repo }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub: Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[850,300],"credentials":{"githubApi":"github-api"}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.owner }}/{{ $json.repo }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub: Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[850,400],"credentials":{"githubApi":"github-api"}},{"parameters":{"jsCode":"const commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json;\nconst config = $input.all()[0].json.__config || { language: 'EN' };\n\n// Filter PRs merged in last 7 days\nconst mergedPRs = (Array.isArray(prs) ? prs : []).filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedDate = new Date(pr.merged_at);\n  const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);\n  return mergedDate >= weekAgo;\n});\n\n// Filter issues closed in last 7 days (not PRs)\nconst closedIssues = (Array.isArray(issues) ? issues : []).filter(issue => {\n  if