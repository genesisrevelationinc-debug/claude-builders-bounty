 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity using n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Credentials*
+3. **Configure variables**: Open the *Configuration* node and set your repo, destination, and language
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Test run**: Click *Execute Workflow* to verify, then wait for the weekly cron trigger
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `destination` | Email or webhook URL | `https://hooks.slack.com/services/...` |
+| `language` | Summary language | `EN` or `FR` |
+| `summaryType` | Delivery method | `slack`, `discord`, or `email` |
+
+## What It Does
+
+- **Trigger**: Every Friday at 5:00 PM (cron: `0 17 * * 5`)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
+- **Generates**: Narrative summary via Claude API (`claude-sonnet-4-20250514`)
+- **Delivers**: To your configured Slack/Discord webhook or email
+
+## Required Credentials
+
+- **GitHub API**: Personal Access Token with `repo` scope
+- **Anthropic**: API key from [console.anthropic.com](https://console.anthropic.com)
+- **Email (optional)**: SMTP credentials if using email delivery
+
+## Testing
+
+The workflow includes a manual trigger node for immediate testing. Click *Execute Workflow* after configuration to run it once before the cron schedule takes over.
+
+## Screenshot
+
+*(Add screenshot of successful execution here)*
+
+---
+
+## License
+
+MIT
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - n8n + Claude","nodes":[{"parameters":{},"id":"trigger-cron","name":"Weekly Cron Trigger","type":"n8n-nodes-base.cron","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAt":"5","triggerAtHour":"17"}]}},"id":"trigger-manual","name":"Manual Trigger","type":"n8n-nodes-base.manualTrigger","typeVersion":1,"position":[250,500]},{"parameters":{"jsCode":"// Configuration variables\nconst config = {\n  githubRepo: $env.GITHUB_REPO || 'claude-builders-bounty/claude-builders-bounty',\n  destination: $env.DESTINATION_URL || 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL',\n  language: $env.LANGUAGE || 'EN',\n  summaryType: $env.SUMMARY_TYPE || 'slack', // slack, discord, or email\n  anthropicModel: 'claude-sonnet-4-20250514',\n  daysBack: 7\n};\n\n// Calculate date range\nconst now = new Date();\nconst since = new Date(now.getTime() - config.daysBack * 24 * 60 * 60 * 1000);\n\nreturn [{\n  json: {\n    ...config,\n    since: since.toISOString(),\n    until: now.toISOString(),\n    sinceDate: since.toISOString().split('T')[0],\n    untilDate: now.toISOString().split('T')[0]\n  }\n}];"},"id":"config-node","name":"Configuration","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{$json.githubRepo}}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{$json.since}}"},{"name":"until","value":"={{$json.until}}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.githubRepo}}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{$json.since}}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"url":"=https://api.github.com/repos/{{$json.githubRepo}}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,600],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"GitHub Token"}}},{"parameters":{"jsCode":"// Filter merged PRs from closed PRs\nconst prs = $input.all()[0].json;\nconst since = $input.all()[0].json.__config?.since || new Date(Date.now() - 7 * 24 * 60