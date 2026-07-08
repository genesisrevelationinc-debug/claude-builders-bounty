 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude — Weekly Dev Summary Workflow
+
+Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and the Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`.
+
+2. **Set credentials**: Add your **Claude API** and **GitHub API** credentials in n8n (*Settings → Credentials*).
+
+3. **Configure variables**: Open the workflow and edit the `Set Config` node with your repo, destination, and language.
+
+4. **Set up delivery**: Configure the **Email** or **Webhook** node with your SMTP/Discord/Slack details.
+
+5. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM.
+
+---
+
+## Configurable Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Target repository | `owner/repo-name` |
+| `destinationChannel` | Email or webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+---
+
+## What It Does
+
+- **Trigger**: Weekly cron (Fridays at 5:00 PM)
+- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
+- **Generates**: A narrative summary via Claude API (`claude-sonnet-4-20250514`)
+- **Delivers**: Via email or Discord/Slack webhook
+
+---
+
+## Screenshot
+
+![Successful Execution](screenshot-success.png)
+
+---
+
+## Requirements
+
+- n8n instance (cloud or self-hosted)
+- Claude API key
+- GitHub personal access token
\ No newline at end of file
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - Claude + n8n","nodes":[{"parameters":{},"id":"trigger-cron","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtHour":17,"triggerAtMinute":0,"triggerOnSpecificWeek":1,"triggerAtDayOfWeek":5}]}},"id":"trigger-cron-config","name":"Weekly Cron Trigger","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"jsCode":"// Calculate date range for past 7 days\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nconst since = sevenDaysAgo.toISOString().split('T')[0] + 'T00:00:00Z';\nconst until = now.toISOString().split('T')[0] + 'T23:59:59Z';\n\nreturn [{\n  json: {\n    since,\n    until,\n    days: 7\n  }\n}];"},"id":"calc-date-range","name":"Calculate Date Range","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,300]},{"parameters":{"jsCode":"// Set configurable variables\nconst config = {\n  githubRepo: $env.GITHUB_REPO || 'owner/repo-name',\n  destinationChannel: $env.DESTINATION_CHANNEL || 'email',\n  language: $env.LANGUAGE || 'EN',\n  claudeModel: 'claude-sonnet-4-20250514'\n};\n\nreturn [{ json: config }];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":1,"position":[650,300]},{"parameters":{"resource":"repository","operation":"listCommits","owner":"={{ $json.githubRepo.split('/')[0] }}","repository":"={{ $json.githubRepo.split('/')[1] }}","since":"={{ $('Calculate Date Range').item.json.since }}","returnAll":true},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.github","typeVersion":1,"position":[850,200],"credentials":{"githubApi":"github-credentials"}},{"parameters":{"resource":"issue","operation":"getAll","owner":"={{ $('Set Config').item.json.githubRepo.split('/')[0] }}","repository":"={{ $('Set Config').item.json.githubRepo.split('/')[1] }}","state":"closed","returnAll":true},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.github","typeVersion":1,"position":[850,400],"credentials":{"githubApi":"github-credentials"}},{"parameters":{"resource":"pullRequest","operation":"getAll","owner":"={{ $('Set Config').item.json.githubRepo.split('/')[0] }}","repository":"={{ $('Set Config').item.json.githubRepo.split('/')[1] }}","state":"closed","returnAll":true},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.github","typeVersion":1,"position":[850,600],"credentials":{"githubApi":"github-credentials"}},{"parameters":{"jsCode":"// Filter PRs to only merged ones in the last 7 days\nconst since = new Date($('Calculate Date Range').item.json.since);\nconst prs = $input.all()[0].json;\n\nconst mergedPRs = prs.filter(pr => {\n  if (!pr.merged_at) return false;\n  const mergedDate = new Date(pr.merged_at);\n  return mergedDate >= since;\n});\n\nreturn [{ json: { mergedPRs } }];"},"id":"filter-merged-prs","name":"Filter Merged PRs","type":"n8n-nodes-base.code","typeVersion":1,"position":[1050,600]},{"parameters":{"jsCode":"// Aggregate all data for Claude prompt\nconst commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json.mergedPRs;\nconst config = $('Set Config').item.json;\n\nconst data = {\n  commits: commits.map(c => ({\n    message: c.commit.message.split('\\n')[0],\n    author: c.commit.author.name,\n    date: c.commit.author.date\n  })),\n  issues: issues.map(i => ({\n    title: i.title,\n    number