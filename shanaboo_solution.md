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
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Settings* → *Credentials*
+
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `language` (EN/FR), and `webhookUrl`
+
+4. **Activate the trigger**: Enable the `Weekly Cron` node (runs Fridays at 5 PM UTC by default)
+
+5. **Activate the workflow**: Toggle the workflow to *Active* in n8n
+
+## What It Does
+
+- Fetches commits, closed issues, and merged PRs from the past 7 days
+- Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
+- Posts the summary to a Discord/Slack webhook
+
+## Required Credentials
+
+- `githubApi` — GitHub Personal Access Token (needs `repo` scope)
+- `anthropicApi` — Anthropic API key
+
+## Configurable Variables
+
+| Variable | Description | Default |
+|----------|-------------|---------|
+| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
+| `repoName` | GitHub repository name | `claude-builders-bounty` |
+| `language` | Summary language (`EN` or `FR`) | `EN` |
+| `webhookUrl` | Discord/Slack webhook URL | *(required)* |
+
+## Testing
+
+Run the workflow manually by clicking *Execute Workflow* in n8n. Check the execution output for the Claude API response and webhook delivery status.
+
+---
+*Built for the Claude Builders Bounty — MIT License*
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weekday","operation":"on","value":"5"},{"field":"hour","operation":"on","value":"17"}]}},"id":"trigger-cron-weekly","name":"Weekly Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"jsCode":"// Calculate date range for past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString().split('T')[0] + 'T00:00:00Z';\nconst until = now.toISOString();\n\nreturn [{\n  json: {\n    since,\n    until,\n    repoOwner: $env.REPO_OWNER || 'claude-builders-bounty',\n    repoName: $env.REPO_NAME || 'claude-builders-bounty',\n    language: $env.SUMMARY_LANGUAGE || 'EN',\n    webhookUrl: $env.WEBHOOK_URL || ''\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"url":"={{ $json.repoOwner }}/{{ $json.repoName }}/commits","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"until","value":"={{ $json.until }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"githubApi"}}},{"parameters":{"url":"={{ $json.repoOwner }}/{{ $json.repoName }}/issues","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,300],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"githubApi"}}},{"parameters":{"url":"={{ $json.repoOwner }}/{{ $json.repoName }}/pulls","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"githubApi"}}},{"parameters":{"jsCode":"const commits = $input.all()[0] || [];\nconst issues = $input.all()[1] || [];\nconst prs = $input.all()[2] || [];\n\nconst closedIssues = issues.filter(i => i.closed_at >= $json.since);\nconst mergedPRs = prs.filter(p => p.merged_at && p.merged_at >= $json.since);\n\nconst commitList = commits.slice(0, 20).map(c => `- ${c.commit.message.split('\\n')[0]} (${c.commit.author.name})`).join('\\n');\nconst issueList = closedIssues.slice(0, 15).map(i => `- #${i.number}: ${i.title}`).join('\\n');\nconst prList = mergedPRs.slice(0, 15).map(p => `- #${p.number}: ${p.title} by @${p.user.login}`).join('\\n');\n\nreturn [{\n  json: {\n    ...$json,\n    commitCount: commits.length,\n    issueCount: closedIssues.length,\n    prCount: mergedPRs.length,\n    commitList,\n    issueList,\n    prList\n  }\n}];"},"id":"aggregate-data","name":"Aggregate Data","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,300]},{"parameters":{"js