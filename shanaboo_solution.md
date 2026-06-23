 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,47 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to Workflows → Import from File → select `n8n-claude-weekly-summary.json`
+
+2. **Set credentials**: Add your GitHub API token and Claude API key in n8n Settings → Credentials
+
+3. **Configure variables**: Edit the "Set Config" node with your repo, destination, and language
+
+4. **Activate the workflow**: Toggle the workflow to "Active" — it runs Fridays at 5pm
+
+5. **Test it**: Click "Execute Workflow" to run manually and verify output
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `destination` | Email or webhook URL | `https://hooks.slack.com/services/...` |
+| `language` | Summary language | `EN` or `FR` |
+| `deliveryMethod` | How to send | `slack`, `discord`, or `email` |
+
+## Delivery Options
+
+- **Slack**: Set `deliveryMethod` to `slack` and `destination` to your Slack webhook URL
+- **Discord**: Set `deliveryMethod` to `discord` and `destination` to your Discord webhook URL
+- **Email**: Set `deliveryMethod` to `email` and `destination` to the email address
+
+## Required n8n Nodes
+
+- Cron (schedule)
+- HTTP Request (GitHub API, Claude API, webhook)
+- Set (variables)
+- Code (data processing)
+- If (conditional routing)
+
+## Claude Model
+
+Uses `claude-sonnet-4-20250514` via Anthropic Messages API.
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Add your own screenshot after testing*
+
--- /dev/null
+++ workflows/n8n-claude-weekly-summary/n8n-claude-weekly-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - n8n + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtHour":17,"triggerAtMinute":0,"triggerOnSpecificWeek":1,"triggerOnSpecificWeekDay":5}]},"options":{}},"id":"cron-trigger","name":"Weekly Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"values":[{"name":"githubRepo","value":"=claude-builders-bounty/claude-builders-bounty"},{"name":"destination","value":"=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"},{"name":"language","value":"=EN"},{"name":"deliveryMethod","value":"=slack"},{"name":"daysBack","value":"=7"}]},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.set","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.githubRepo }}/commits","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApiToken ? $credentials.githubApiToken : '' }}"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ new Date(new Date().getTime() - ($json.daysBack * 24 * 60 * 60 disputing * 1000)).toISOString() }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"githubApiToken":{"id":"github-api-token","name":"GitHub API Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.githubRepo }}/issues","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApiToken ? $credentials.githubApiToken : '' }}"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ new Date(new Date().getTime() - ($json.daysBack * 24 * 60 * 60 * 1000)).toISOString() }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400],"credentials":{"githubApiToken":{"id":"github-api-token","name":"GitHub API Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.githubRepo }}/pulls","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"},{"name":"Authorization","value":"=Bearer {{ $credentials.githubApiToken ? $credentials.githubApiToken : '' }}"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"sort","value":"updated"},{"name":"direction","value":"desc"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,600],"credentials":{"githubApiToken":{"id":"github-api-token","name":"GitHub API Token"}}},{"parameters":{"jsCode":"// Filter merged PRs from the last week\nconst items = $input.all()[0].json;\nconst config = $input.all()[1].json;\nconst daysBack = config.daysBack || 7;\nconst cutoff = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000);\n\nconst mergedPRs = items.filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedDate = new Date(pr.merged_at);\n  return mergedDate >= cutoff;\n});\n\nreturn [{ json: { mergedPRs } }];"},"id":"filter-merged-prs","name":"Filter Merged PRs","type":"n8n-nodes-base.code