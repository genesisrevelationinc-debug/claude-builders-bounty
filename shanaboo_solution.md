 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,44 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, click *Import* → *From File* → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Credentials*
+3. **Configure variables**: Open the *Set Variables* node and set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
+4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
+5. **Test manually**: Click *Execute Workflow* to verify, then check your Discord/Slack channel
+
+## Delivery
+
+The workflow sends summaries via **Discord webhook** (configurable to Slack by changing the HTTP Request node URL).
+
+## Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub organization or user | `claude-builders-bounty` |
+| `repoName` | Repository name | `claude-builders-bounty` |
+| `webhookUrl` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Include a screenshot of a successful n8n execution here.*
+
+## Files
+
+- `weekly-dev-summary.json` — Importable n8n workflow
+- `README.md` — This file
+
+## Requirements
+
+- n8n instance (cloud or self-hosted)
+- GitHub Personal Access Token (classic, with `repo` scope)
+- Anthropic API key (access to `claude-sonnet-4-20250514`)
+- Discord or Slack webhook URL
+
+---
+*Generated for Claude Builders Bounty #5*
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - Claude API","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks"}]},"mode":"everyWeek","timezone":"UTC"},"id":"trigger-cron","name":"Weekly Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"options":{},"assignments":{"assignments":[{"id":"variables","name":"repoOwner","type":"string","value":"claude-builders-bounty"},{"id":"variables-2","name":"repoName","type":"string","value":"claude-builders-bounty"},{"id":"variables-3","name":"webhookUrl","type":"string","value":"https://discord.com/api/webhooks/YOUR_WEBHOOK"},{"id":"variables-4","name":"language","type":"string","value":"EN"}]}},"id":"set-variables","name":"Set Variables","type":"n8n-nodes-base.set","typeVersion":3,"position":[450,300]},{"parameters":{"method":"GET","url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits?since={{ $now.minus({ days: 7 }).toISO() }}&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"method":"GET","url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues?state=closed&since={{ $now.minus({ days: 7 }).toISO() }}&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,300],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"method":"GET","url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls?state=closed&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"jsCode":"// Filter PRs merged in last 7 days\nconst prs = $input.all()[0]?.json || [];\nconst oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) >= oneWeekAgo);\nreturn [{ json: { mergedPRs, count: mergedPRs.length } }];"},"id":"filter-prs","name":"Filter Merged PRs","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,400]},{"parameters":{"jsCode":"// Aggregate all data\nconst commits = $input.all().find(i => i.json && Array.isArray(i.json))?.json || [];\nconst issues = $input.all().find(i => i.json && Array.isArray(i.json))?.json || [];\nconst prs = $input.all().find(i => i.json && i.json.mergedPRs)?.json?.mergedPRs || [];\n\nconst commitMessages = commits.slice(0, 20).map(c => `- ${c.commit.message.split('\\n')[0]}`).join('\\n');\nconst issueTitles = issues.slice(0, 20).map(i => `- ${i.title}`).join('\\n');\nconst prTitles