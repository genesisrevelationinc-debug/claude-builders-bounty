 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
+3. **Configure variables**: Edit the `Set Config` node with your repo, Discord webhook URL, and language (EN/FR)
+4. **Activate**: Toggle the workflow to *Active* — it runs Fridays at 5 PM
+5. **Test manually**: Click *Execute Workflow* and check your Discord channel
+
+## Required Credentials
+
+- **GitHub API**: Personal Access Token with `repo` scope
+- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `discordWebhook` | Discord webhook URL | `https://discord.com/api/webhooks/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## What It Does
+
+1. Triggers weekly (cron: `0 17 * * 5`)
+2. Fetches commits, closed issues, and merged PRs from the past 7 days
+3. Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
+4. Posts formatted summary to Discord via webhook
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+
+*Screenshot shows successful workflow execution with all nodes green.*
+
+## Files
+
+- `weekly-dev-summary.json` — Importable n8n workflow
+- `README.md` — This file
--- /dev/null
+++ /workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{},"id":"trigger-cron","name":"Weekly Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"jsCode":"const now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\nreturn [{\n  json: {\n    since: sevenDaysAgo.toISOString(),\n    until: now.toISOString()\n  }\n}];"},"id":"set-dates","name":"Set Date Range","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,300]},{"parameters":{"jsCode":"const config = $input.first().json;\nconst items = [];\n\n// Commits\nitems.push({\n  json: {\n    url: `https://api.github.com/repos/${config.githubRepo}/commits`,\n    options: {\n      qs: {\n        since: config.since,\n        until: config.until,\n        per_page: 100\n      },\n      headers: {\n        Authorization: `Bearer {{$credentials.githubApi.apiKey}}`,\n        Accept: 'application/vnd.github.v3+json'\n      }\n    }\n  }\n});\n\n// Closed issues\nitems.push({\n  json: {\n    url: `https://api.github.com/repos/${config.githubRepo}/issues`,\n    options: {\n      qs: {\n        state: 'closed',\n        since: config.since,\n        per_page: 100\n      },\n      headers: {\n        Authorization: `Bearer {{$credentials.githubApi.apiKey}}`,\n        Accept: 'application/vnd.github.v3+json'\n      }\n    }\n  }\n});\n\n// Merged PRs\nitems.push({\n  json: {\n    url: `https://api.github.com/repos/${config.githubRepo}/pulls`,\n    options: {\n      qs: {\n        state: 'closed',\n        sort: 'updated',\n        direction: 'desc',\n        per_page: 100\n      },\n      headers: {\n        Authorization: `Bearer {{$credentials.githubApi.apiKey}}`,\n        Accept: 'application/vnd.github.v3+json'\n      }\n    }\n  }\n});\n\nreturn items;"},"id":"build-requests","name":"Build GitHub Requests","type":"n8n-nodes-base.code","typeVersion":1,"position":[650,300]},{"parameters":{"method":"GET","url":"={{ $json.url }}","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.options.qs.since }}"},{"name":"until","value":"={{ $json.options.qs.until }}"},{"name":"state","value":"={{ $json.options.qs.state }}"},{"name":"sort","value":"={{ $json.options.qs.sort }}"},{"name":"direction","value":"={{ $json.options.qs.direction }}"},{"name":"per_page","value":"100"}]},"sendHeaders":true,"headerParameters":{"parameters":[{"name":"Authorization","value":"Bearer {{$credentials.githubApi.apiKey}}"},{"name":"Accept","value":"application/vnd.github.v3+json"}]},"options":{}},"id":"github-api","name":"GitHub API","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[850,300],"credentials":{"githubApi":{"id":"github-api-key","name":"GitHub API"}}},{"parameters":{"jsCode":"const allItems = $input.all();\nconst commits = allItems.find(i => i.json.url?.includes('/commits'))?.json.response || [];\nconst issues = allItems.find(i => i.json.url?.includes('/issues') && !i.json.url?.includes('/pulls'))?.json.response || [];\nconst prs = allItems.find(i => i.json.url?.includes('/pulls'))?.json.response || [];\n\n// Filter PRs that were actually merged in the last 7 days\nconst mergedPRs = prs.filter(pr => pr.merged_at);\n\nreturn [{\n  json: {\n    commits: commits.map(c => ({\n      message: c.commit.message.split('\\n')[0],\n      author: c.commit.author.name,\n      date: c.commit.author.date,\n      url: c.html_url\n    })),\n    closedIssues: issues.map(i => ({\n      title: i