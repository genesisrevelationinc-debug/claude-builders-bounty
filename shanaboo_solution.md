 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API, delivered via email or webhook.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set repo, destination, and language
+4. **Choose delivery**: In the `Switch` node, enable either Email or Webhook branch (Discord/Slack)
+|5. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5pm
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full GitHub repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `destination` | Email or webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Nodes Overview
+
+- **Cron Trigger**: Runs weekly (Friday 5pm)
+- **GitHub Commits**: Fetches commits from the past 7 days
+- **GitHub Closed Issues**: Fetches closed issues from the past 7 days
+- **GitHub Merged PRs**: Fetches merged PRs from the past 7 days
+- **Claude API**: Generates narrative summary with `claude-sonnet-4-20250514`
+- **Switch**: Routes to Email or Webhook delivery
+
+## Testing
+
+Run the workflow manually in n8n and check execution output. A successful run shows green checkmarks on all nodes.
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+## Requirements
+
+- n8n instance (cloud or self-hosted)
+- GitHub Personal Access Token (no special scopes needed for public repos; `repo` for private)
+- Anthropic API key
+- Email SMTP credentials OR Discord/Slack webhook URL
+
+## License
+
+MIT
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - Claude + n8n","nodes":[{"parameters":{},"id":"cron-trigger","name":"Cron Trigger","type":"n8n-nodes-base.cron","typeVersion":1,"position":[250,300],"webhookId":"weekly-summary-cron"},{"parameters":{"rule":{"interval":[{"field":"weeks","hours":17,"minutes":0,"day":5}]},"mode":"everyWeek"},"id":"cron-trigger-config","name":"Cron Trigger","type":"n8n-nodes-base.cron","typeVersion":1,"position":[250,300]},{"parameters":{"jsCode":"// Calculate date range for past week\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString().split('T')[0];\n\nreturn [{\n  json: {\n    since: since + 'T00:00:00Z',\n    repo: $env.GITHUB_REPO || 'claude-builders-bounty/claude-builders-bounty',\n    language: $env.LANGUAGE || 'EN',\n    destination: $env.DESTINATION || 'webhook'\n  }\n}]"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repo }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repo }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repo }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,600],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"jsCode":"// Filter PRs to only merged in last 7 days and combine data\nconst commits = $input.all()[0] || [];\nconst issues = $input.all()[1] || [];\nconst prs = $input.all()[2] || [];\n\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nconst mergedPRs = prs.filter(pr => {\n  if (!pr.merged_at) return false;\n  return new Date(pr.merged_at) >= sevenDaysAgo;\n});\n\nreturn [{\n  json: {\n    commits: commits.map(c => ({\n      message: c.commit?.message?.split('\\n')[0] ||