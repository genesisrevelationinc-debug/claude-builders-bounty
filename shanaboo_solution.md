 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,47 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
+
+3. **Configure variables**: Open the workflow and edit the `Set Config` node with your repo, destination, and language
+
+4. **Activate the workflow**: Toggle the workflow ON — it runs every Friday at 5 PM
+
+5. **Test it**: Click *Execute Workflow* to run manually and verify output
+
+## Required Credentials
+
+- **GitHub API**: Personal Access Token with `repo` scope
+- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Target repository | `owner/repo-name` |
+| `destination` | Webhook URL for delivery | `https://hooks.slack.com/services/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Output
+
+The workflow delivers a narrative summary including:
+- Commits merged this week
+- Issues closed this week
+- Pull requests merged this week
+- Highlights and key changes
+
+## Delivery Options
+
+By default, the workflow sends to a webhook (Discord/Slack). To use email instead:
+1. Replace the `HTTP Request` node with an `Email` node
+2. Configure SMTP credentials in n8n settings
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Include a screenshot of your successful execution here*
+
+--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","hoursInterval":1,"mode":"everyWeek","triggerAtDay":[5],"triggerAtHour":[17]}]}},"id":"trigger-weekly","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1.1,"position":[240,300],"webhookId":"weekly-cron"},{"parameters":{"jsCode":"// Calculate date range for the past week\nconst now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nconst toISO = (d) => d.toISOString().split('T')[0];\n\nreturn [{\n  json: {\n    startDate: toISO(oneWeekAgo),\n    endDate: toISO(now),\n    githubRepo: $env.GITHUB_REPO || 'owner/repo-name',\n    destination: $env.DESTINATION_WEBHOOK || 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL',\n    language: $env.SUMMARY_LANGUAGE || 'EN',\n    anthropicModel: 'claude-sonnet-4-20250514'\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[460,300]},{"parameters":{"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","method":"GET","url":"=https://api.github.com/repos/{{ $json.githubRepo }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.startDate }}T00:00:00Z"},{"name":"until","value":"={{ $json.endDate }}T23:59:59Z"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[680,180],"credentials":{"httpHeaderAuth":{"id":"GitHub API","name":"GitHub API"}}},{"parameters":{"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","method":"GET","url":"=https://api.github.com/repos/{{ $json.githubRepo }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.startDate }}T00:00:00Z"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[680,300],"credentials":{"httpHeaderAuth":{"id":"GitHub API","name":"GitHub API"}}},{"parameters":{"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","method":"GET","url":"=https://api.github.com/repos/{{ $json.githubRepo }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"sort","value":"updated"},{"name":"direction","value":"desc"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[680,420],"credentials":{"httpHeaderAuth":{"id":"GitHub API","name":"GitHub API"}}},{"parameters":{"jsCode":"const config = $input.first().json;\nconst commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json;\n\n// Filter PRs merged in the date range\nconst mergedPRs = (Array.isArray(prs) ? prs : []).filter(pr => {\n  if (!pr.merged_at) return false;\n  const merged = new Date(pr.merged_at);\n  const start = new Date(config.startDate);\n  const end = new Date(config.endDate);\n  return merged >= start && merged <= end;\n});\n\n// Filter issues closed in the date range (not PRs)\nconst closedIssues = (Array.isArray(issues) ? issues : []).filter(issue => {\n  if (issue.pull_request) return false;\n  const closed = new Date(issue.closed_at);\n  const start = new Date(config.startDate);\n  const end = new Date(config.endDate);\n  return closed >= start && closed <= end;\n});\n\nconst commitList = Array.isArray(commits)