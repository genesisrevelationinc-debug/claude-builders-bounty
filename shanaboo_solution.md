 ```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary/README.md
@@ -0,0 +1,42 @@
+# n8n Weekly Dev Summary Workflow
+
+Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.
+
+## Setup (5 steps)
+
+1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
+3. **Configure variables**: Edit the *Set Config* node — set `repo`, `channelWebhook`, and `language` (EN/FR)
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Test**: Click *Execute Workflow* to run manually, or wait for the weekly cron trigger (Fridays at 5pm UTC)
+
+## Delivery Options
+
+The workflow sends summaries via **Discord webhook** by default. To use Slack instead, change the HTTP Request node URL to your Slack webhook. For email delivery, replace the webhook node with an n8n *Send Email* node.
+
+## Required Credentials
+
+- **GitHub API**: Personal Access Token with `repo` scope
+- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Workflow Overview
+
+| Node | Purpose |
+|------|---------|
+| Cron | Triggers weekly (Fridays 5pm UTC) |
+| Set Config | Defines repo, language, destination |
+| GitHub Commits | Fetches commits from the past 7 days |
+| GitHub Issues | Fetches closed issues from the past 7 days |
+| GitHub PRs | Fetches merged PRs from the past 7 days |
+| Merge Data | Combines all GitHub data |
+| Claude API | Generates narrative summary |
+| Send Summary | Delivers via Discord/Slack webhook |
+
+## Customization
+
+- **Language**: Set `language` to `EN` or `FR` in the Set Config node
+- **Repo**: Change `repo` format to `owner/repository`
+- **Destination**: Update `channelWebhook` to your Discord/Slack webhook URL
+
+## Screenshot
+
+See `screenshot-success.png` for a successful execution example.
--- /dev/null
+++ /workflows/weekly-dev-summary/workflow.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{},"id":"cron-trigger","name":"Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"jsCode":"// Set configuration variables\nconst now = new Date();\nconst sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nreturn [{\n  json: {\n    repo: $env.GITHUB_REPO || 'claude-builders-bounty/claude-builders-bounty',\n    language: $env.LANGUAGE || 'EN',\n    channelWebhook: $env.WEBHOOK_URL || '',\n    since: sevenDaysAgo.toISOString(),\n    until: now.toISOString()\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":1,"position":[450,300]},{"parameters":{"authentication":"oAuth2","resource":"repository","operation":"listCommits","owner":"={{ $json.repo.split('/')[0] }}","repository":"={{ $json.repo.split('/')[1] }}","since":"={{ $json.since }}","returnAll":true},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,200],"credentials":{"githubApi":{"id":"github-cred","name":"GitHub API"}}},{"parameters":{"authentication":"oAuth2","resource":"issue","operation":"getAll","owner":"={{ $('Set Config').first().json.repo.split('/')[0] }}","repository":"={{ $('Set Config').first().json.repo.split('/')[1] }}","returnAll":true,"filters":{"state":"closed","since":"={{ $('Set Config').first().json.since }}"}},"id":"github-issues","name":"GitHub Issues","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,400],"credentials":{"githubApi":{"id":"github-cred","name":"GitHub API"}}},{"parameters":{"authentication":"oAuth2","resource":"pullRequest","operation":"getAll","owner":"={{ $('Set Config').first().json.repo.split('/')[0] }}","repository":"={{ $('Set Config').first().json.repo.split('/')[1] }}","returnAll":true,"filters":{"state":"closed"}},"id":"github-prs","name":"GitHub PRs","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,600],"credentials":{"githubApi":{"id":"github-cred","name":"GitHub API"}}},{"parameters":{"jsCode":"const config = $('Set Config').first().json;\nconst commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst since = new Date(config.since);\nconst filteredIssues = issues.filter(i => new Date(i.closed_at) >= since);\nconst filteredPRs = prs.filter(p => p.merged_at && new Date(p.merged_at) >= since);\n\nreturn [{\n  json: {\n    repo: config.repo,\n    language: config.language,\n    channelWebhook: config.channelWebhook,\n    period: {\n      start: config.since,\n      end: config.until\n    },\n    commits: commits.map(c => ({\n      message: c.commit.message.split('\\n')[0],\n      author: c.commit.author.name,\n      date: c.commit.author.date,\n      url: c.html_url\n    })),\n    issues: filteredIssues.map(i => ({\n      title: i.title,\n      number: i.number,\n      closed_at: i.closed_at,\n      url: i.html_url\n    })),\n    pullRequests: filteredPRs.map(p => ({\n      title: p.title,\n      number: p.number,\n      author: p.user.login,\n      merged_at: p.merged_at,\n      url: p.html_url\n    }))\n  }\n}];"},"id":"merge-data","name":"Merge Data","type":"n8n-nodes-base.code","typeVersion":1,"position":[850,300]},{"parameters":{"jsCode":"const data = $input JSON.parse