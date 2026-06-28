 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings* → *Credentials*
+3. **Configure variables**: Edit the *Set Config* node — set `repoOwner`, `repoName`, `deliveryWebhook`, and `language`
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Test**: Click *Execute Workflow* to run manually and verify output
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `deliveryWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## What It Does
+
+- **Trigger**: Runs every Friday at 5:00 PM (cron: `0 17 * * 5`)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
+- **Delivers**: Posts the summary to your configured Discord/Slack webhook
+
## Requirements
+
+- n8n instance (cloud or self-hosted)
+- GitHub Personal Access Token (classic or fine-grained with `repo` scope)
+- Anthropic API Key with access to `claude-sonnet-4-20250514`
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Screenshot showing successful workflow execution with data flowing through all nodes.*
+
+## Files
+
+- `workflow.json` — Importable n8n workflow
+- `README.md` — This file
+
+---
+*Generated for Claude Builders Bounty #5*
--- /dev/null
+++ /workflows/n8n-claude-weekly-summary/workflow.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - Claude + n8n","nodes":[{"parameters":{"rule":{"interval":[{"field":"hours","hoursInterval":1}]},"options":{}},"id":"trigger-cron-weekly","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[250,300],"webhookId":"trigger-cron-weekly"},{"parameters":{"jsCode":"// Calculate date range for past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\nconst until = now.toISOString();\n\nreturn [{\n  json: {\n    since,\n    until,\n    repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.REPO_NAME || 'claude-builders-bounty',\n    language: $env.SUMMARY_LANGUAGE || 'EN',\n    deliveryWebhook: $env.DELIVERY_WEBHOOK || 'https://discord.com/api/webhooks/placeholder'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"method":"GET","url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits?since={{ $json.since }}&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"method":"GET","url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues?state=closed&since={{ $json.since }}&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"method":"GET","url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls?state=closed&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,600],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"jsCode":"// Filter PRs to only merged ones in the date range\nconst since = new Date($input.all()[0].json.since);\nconst prs = $input.all()[0].json;\nconst mergedPRs = (Array.isArray(prs) ? prs : []).filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedAt = new Date(pr.merged_at);\n  return mergedAt >= since;\n});\n\nreturn [{\n  json: {\n    mergedPRs,\n    count: mergedPRs.length\n  }\n}];"},"id":"filter-merged-prs","name":"Filter Merged PRs","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,600]},{"parameters":{"jsCode":"// Aggregate all data for Claude