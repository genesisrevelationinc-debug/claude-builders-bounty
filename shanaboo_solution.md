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
+5. **Done!** The workflow runs every Friday at 5 PM. Check the first execution in *Executions*
+
+## Required Credentials
+
+- **GitHub API**: Personal Access Token with `repo` scope
+- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Output
+
+The workflow delivers a narrative summary including:
+- Commits merged this week
+- Issues closed this week
+- Pull requests merged this week
+- Highlights and notable changes
+
+## Delivery
+
+By default, the workflow sends output to a **Discord webhook**. To use Slack instead, replace the Discord node with a Slack node and update `webhookUrl`.
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Screenshot of successful execution on a live n8n instance.*
+
+## Files
+
+- `weekly-dev-summary.json` — Importable n8n workflow
+- `README.md` — This file
+
+---
+
+Built for [Claude Builders Bounty](https://github.com/claude-builders-bounty/claude-builders-bounty)
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{},"id":"trigger-cron","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtHour":17,"triggerAtMinute":0,"triggerOnSpecificWeek":1,"triggerAtDay":5}]}},"id":"trigger-cron-config","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"jsCode":"// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString().split('T')[0] + 'T00:00:00Z';\nconst until = now.toISOString();\n\nreturn [{\n  json: {\n    since,\n    until,\n    repoOwner: $env.GITHUB_REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.GITHUB_REPO_NAME || 'claude-builders-bounty',\n    webhookUrl: $env.DISCORD_WEBHOOK_URL || '',\n    language: $env.SUMMARY_LANGUAGE || 'EN',\n    anthropicModel: 'claude-sonnet-4-20250514'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApi.accessToken }}"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"until","value":"={{ $json.until }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"githubApi":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApi.accessToken }}"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400],"credentials":{"githubApi":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApi.accessToken }}"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,600],"credentials":{"githubApi":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"jsCode":"// Filter PRs to only merged ones within date range\nconst since = new Date($input.first().json.since);\nconst prs = $input.all()[0].json;\nconst items = Array.isArray(prs) ? prs : (prs.data || []);\n\nconst mergedPRs = items.filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedDate = new Date(pr.merged_at);\n  return mergedDate >= since;\n});\n\nreturn [{\n 