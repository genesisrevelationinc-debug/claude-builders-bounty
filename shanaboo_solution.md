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
+1. **Import the workflow**: In n8n, click "Add Workflow" → "Import from File" → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your GitHub API token and Claude API key in n8n "Credentials"
+
+3. **Configure variables**: Open the workflow and edit the "Set Config" node with your repo, destination, and language
+
+4. **Activate the workflow**: Toggle the workflow to "Active" in n8n
+
+5. **Test or wait**: Click "Execute Workflow" to test, or wait for the Friday 5pm cron trigger
+
+## Configuration
+
+Edit these variables in the "Set Config" node:
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Target repository | `owner/repo` |
+| `destinationChannel` | Webhook URL or email | `https://hooks.slack.com/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Delivery Options
+
+- **Slack/Discord**: Set `destinationChannel` to a webhook URL
+- **Email**: Configure the "Send Email" node with SMTP credentials
+
+## What It Does
+
+1. Triggers every Friday at 5pm
+2. Fetches commits, closed issues, and merged PRs from the past week
+3. Sends data to Claude API for narrative summary generation
+4. Delivers the summary to your configured channel
+
+## Requirements
+
+- n8n instance (cloud or self-hosted)
+- GitHub API token (no special scopes needed for public repos)
+- Claude API key
--- /dev/null
+++ /workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","hoursInterval":168,"triggerAtHour":"17","triggerAtMinute":0,"triggerOnSpecificWeekdays":{"0":false,"1":false,"2":false,"3":false,"4":true,"5":false,"6":false}}]}},"type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[0,0],"id":"schedule-trigger","name":"Weekly Friday 5pm"},{"parameters":{"jsCode":"// Calculate date range for past week\nconst now = new Date();\n Sources
+const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = oneWeekAgo.toISOString().split('T')[0];\n\nreturn [{\n  json: {\n    since,\n    until: now.toISOString().split('T')[0]\n  }\n}];"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[220,0],"id":"date-range","name":"Calculate Date Range"},{"parameters":{"jsCode":"// Merge GitHub data for Claude prompt\nconst commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst config = $input.first().json;\n\nreturn [{\n  json: {\n    commits: commits.map(c => ({\n      message: c.commit.message.split('\\n')[0],\n      author: c.commit.author.name,\n      date: c.commit.author.date\n    })),\n    closedIssues: issues.map(i => ({\n      title: i.title,\n      number: i.number,\n      closedAt: i.closed_at\n    })),\n    mergedPRs: prs.map(p => ({\n      title: p.title,\n      number: p.number,\n      mergedAt: p.merged_at,\n      author: p.user.login\n    })),\n    repo: config.githubRepo,\n    language: config.language\n  }\n}];"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[880,0],"id":"merge-data","name":"Merge GitHub Data"},{"parameters":{"options":{},"requestMethod":"POST","url":"https://api.anthropic.com/v1/messages","sendBody":true,"contentType":"json","body":{"messages":[{"role":"user","content":"=You are a technical writer. Write a weekly development summary for the repository {{ $json.repo }}.\n\n## Commits (past 7 days):\n{{ JSON.stringify($json.commits, null, 2) }}\n\n## Closed Issues:\n{{ JSON.stringify($json.closedIssues, null, 2) }}\n\n## Merged Pull Requests:\n{{ JSON.stringify($json.mergedPRs, null, 2) }}\n\nWrite a friendly, narrative summary in {{ $json.language === 'FR' ? 'French' : 'English' }} highlighting key changes, fixes, and contributions. Keep it under 300 words."}],"model":"claude-sonnet-4-20250514","max_tokens":1024},"headerParameters":{"parameters":[{"name":"x-api-key","value":"={{ $credentials.claudeApi.apiKey }}","name":"anthropic-version","value":"2023-06- ACA"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth"},"type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[1100,0],"id":"claude-api","name":"Claude API Summary","credentials":{"claudeApi":{"id":"claude-api","name":"Claude API"}}},{"parameters":{"jsCode":"return [{\n  json: {\n    summary: $input.first().json.content[0].text\n  }\n}];"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[1320,0],"id":"extract-summary","name":"Extract Summary"},{"parameters":{"options":{},"requestMethod":"POST","url":"={{ $json.destinationChannel }}","sendBody":true,"contentType":"json","body":{"text":"=📊 *Weekly Dev Summary: {{ $json.repo }}*\n\n{{ $json.summary }}\n\n_Generated by Claude + n8n_"},"headerParameters":{"parameters":[]},"authentication":"none"},"type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[1540,0],"id":"send-webhook","name":"Send to Webhook"},{"parameters":{"options":{},"values":{"string":[{"name":"githubRepo","value":"owner/repo