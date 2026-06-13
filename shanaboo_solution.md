 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,45 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your *GitHub API*, *Anthropic Claude*, and *Email (SMTP)* or *Webhook* credentials in n8n
+3. **Configure variables**: Open the workflow, click *Workflow Settings*, and set these variables:
+   - `repo` — GitHub repo (e.g., `owner/repo`)
+   - `channel` — email address or webhook URL
+   - `language` — `EN` or `FR`
+4. **Activate**: Toggle the workflow *Active* in the top-right corner
+5. **Done**: The workflow runs automatically every Friday at 5 PM. You can also click *Execute Workflow* to test manually
+
+---
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 17:00)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
+- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
+- **Delivers**: Posts summary via email or webhook (Discord/Slack)
+
+---
+
+## Required Credentials
+
+| Service | Credential Type |
+|---------|-----------------|
+| GitHub | GitHub API (Personal Access Token) |
+| Claude | Anthropic API Key |
+| Delivery | SMTP (email) or HTTP Request (webhook) |
+
+---
+
+## Testing
+
+Run the workflow manually and check the execution output. A successful run shows green checkmarks on all nodes.
+
+---
+
+## Files
+
+- `weekly-dev-summary.json` — Importable n8n workflow
+- `README.md` — This file
+
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - n8n + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weekday","mode":"every","value":5},{"field":"hour","mode":"every","value":17},{"field":"minute","mode":"every","value":0}]}},"id":"trigger-cron","name":"Weekly Cron (Friday 5PM)","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"jsCode":"// Calculate date range for past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString();\nconst until = now.toISOString();\n\nreturn [{\n  json: {\n    since,\n    until,\n    repo: $env.REPO || 'owner/repo',\n    language: ($env.LANGUAGE || 'EN').toUpperCase(),\n    channel: $env.CHANNEL || 'webhook-url-or-email'\n  }\n}];"},"id":"set-variables","name":"Set Variables","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"url":"={{ $json.repo }}/commits","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"={{ $json.repo }}/issues","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,300],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"url":"={{ $json.repo }}/pulls","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"sort","value":"updated"},{"name":"direction","value":"desc"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-api","name":"GitHub API"}}},{"parameters":{"jsCode":"const commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst mergedPRs = prs.filter(pr => pr.merged_at);\n\nconst formatDate = (d) => new Date(d).toLocaleDateString();\n\nconst commitsText = commits.map(c => `- ${c.commit.message.split('\\n')[0]} by ${c.commit.author.name} (${formatDate(c.commit.author.date)})`).join('\\n') || 'No commits this week.';\nconst issuesText = issues.map(i => `- #${i.number}: ${i.title} (closed ${formatDate(i.closed_at)})`).join('\\n') || 'No closed issues this week.';\nconst prsText = mergedPRs.map(p => `- #${p.number}: ${p.title} by ${p.user.login} (merged ${formatDate(p.merged_at)})`).join('\\n') || 'No merged PRs this week.';\n\nreturn [{\n  json: {\n    commitsText,\n    issuesText,\n    prsText,\n    language: $input.first().json