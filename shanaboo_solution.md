 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,42 @@
+# n8n + Claude — Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `claude-weekly-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and email/SMTP or webhook credentials in n8n *Settings → Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `destinationChannel`, and `language` (EN/FR)
+4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
+5. **Test manually**: Click *Execute Workflow* to verify; check your email/Discord/Slack for the summary
+
+## Delivery Options
+
+The workflow supports **email** (SMTP) or **webhook** (Discord/Slack) delivery. Configure one:
+
+- **Email**: Set `deliveryMethod = "email"` and configure SMTP credentials
+- **Discord/Slack**: Set `deliveryMethod = "webhook"` and paste your webhook URL
+
+## Required Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub organization or user | `claude-builders-bounty` |
+| `repoName` | Repository name | `claude-builders-bounty` |
+| `deliveryMethod` | `"email"` or `"webhook"` | `"webhook"` |
+| `destinationChannel` | Email address or webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `"EN"` or `"FR"` |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+> Include a screenshot of a successful n8n execution run here.
+
+## Files
+
+- `claude-weekly-summary.json` — Importable n8n workflow
+- `README.md` — This file
+
+---
+
+*Built for the Claude Builders Bounty*
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/claude-weekly-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary — Claude + n8n","nodes":[{"parameters":{},"id":"trigger-cron","name":"Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"rule":{"interval":[{"field":"weekday","value":"5"},{"field":"hour","value":"17"},{"field":"minute","value":"0"}]}},"id":"trigger-cron-config","name":"Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"jsCode":"// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString();\nconst until = now.toISOString();\nreturn [{ json: { since, until } }];"},"id":"date-range","name":"Set Date Range","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,300]},{"parameters":{"jsCode":"// Set configurable variables\nreturn [{\n  json: {\n    repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.REPO_NAME || 'claude-builders-bounty',\n    deliveryMethod: $env.DELIVERY_METHOD || 'webhook',\n    destinationChannel: $env.DESTINATION_CHANNEL || '',\n    language: $env.LANGUAGE || 'EN',\n    claudeModel: 'claude-sonnet-4-20250514'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.set","typeVersion":1,"position":[650,300]},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/commits","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{$json.since}}"},{"name":"until","value":"={{$json.until}}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":1,"position":[850,200],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/issues","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{$json.since}}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":1,"position":[850,400],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.repoOwner}}/{{$json.repoName}}/pulls","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":1,"position":[850,600],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"jsCode":"// Filter PRs merged in the last week\nconst since = new Date($input.first().json.since);\nconst prs = $input.all()[0].json;\nconst mergedPRs = (Array.isArray(prs) ? prs : []).filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedAt = new Date(pr.merged_at);\n  return mergedAt >= since;\n});\nreturn [{ json: { mergedPRs, count: mergedPRs.length } }];"},"id":"filter-prs","name":"Filter Merged PRs","type":"n8n-nodes-base.code","typeVersion":1,"position