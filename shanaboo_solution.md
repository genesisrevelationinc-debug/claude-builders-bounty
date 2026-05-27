```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n *Settings → Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Done!** The workflow runs every Friday at 5 PM. Check the first execution in the *Executions* tab
+
+## What It Does
+
+- Triggers weekly (cron: `0 17 * * 5`)
+- Fetches commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative summarization
+- Delivers the summary via Discord/Slack webhook
+
+## Required Credentials
+
+- `githubApi`: GitHub Personal Access Token (no special scopes needed for public repos; `repo` scope for private)
+- `anthropicApi`: Anthropic API Key from [console.anthropic.com](https://console.anthropic.com)
+
+## Configurable Variables
+
+| Variable | Description | Default |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `webhookUrl` | Discord or Slack incoming webhook URL | *(empty)* |
+| `language` | Output language: `EN` or `FR` | `EN` |
+
+## Output Example
+
+> 📊 **Weekly Dev Summary** for `claude-builders-bounty/claude-builders-bounty`
+>
+> This week saw 12 commits, 3 closed issues, and 2 merged PRs. The team focused on improving the bounty workflow automation, with notable progress on the n8n integration...
+
+## Screenshot
+
+See `screenshot-success.png` for a successful execution on a live n8n instance.
+
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{},"id":"trigger-cron","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtHour":17,"triggerAtMinute":0,"triggerOnSpecificWeekDays":["Friday"]}]}},"id":"trigger-cron-config","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[250,300]},{"parameters":{"jsCode":"// Calculate date range for past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\nconst until = now.toISOString();\n\nreturn [{\n  json: {\n    since,\n    until,\n    repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.REPO_NAME || 'claude-builders-bounty',\n    webhookUrl: $env.WEBHOOK_URL || '',\n    language: $env.LANGUAGE || 'EN'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }"},{"name":"until","value":"={{ $json.until }"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"githubApi","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.since }"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,350],"credentials":{"httpHeaderAuth":{"id":"githubApi","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,500],"credentials":{"httpHeaderAuth":{"id":"githubApi","name":"GitHub API"}}},{"parameters":{"jsCode":"// Filter PRs to only merged ones from past 7 days\nconst config = $input.all()[0].json;\nconst since = new Date(config.since);\n\nconst prs = $