 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,42 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set your repo, destination webhook/ email, and language (EN/FR)
+4. **Activate**: Toggle the workflow to *Active* in the top-right corner
+5. **Verify**: Click *Execute Workflow* to test, or wait for the next Friday 5 PM trigger
+
+## What It Does
+
+- Triggers every Friday at 5:00 PM
+- Fetches commits, closed issues, and merged PRs from the past 7 days
+- Sends them to Claude (`claude-sonnet-4-20250514`) for a narrative summary
+- Delivers the summary via Discord/Slack webhook or email
+
+## Required Credentials
+
+| Service | Credential Type |
+|---------|-----------------|
+| GitHub | `githubApi` — Personal Access Token with `repo` scope |
+| Anthropic | `anthropicApi` — API key from [console.anthropic.com](https://console.anthropic.com) |
+
+## Configurable Variables
+
+All set in the **Set Config** node:
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
+| `githubOwner` | Repo owner/organization | `claude-builders-bounty` |
+| `githubRepoName` | Repo name | `claude-builders-bounty` |
+| `destinationWebhook` | Discord/Slack webhook URL | `https://hooks.slack.com/services/...` |
+| `language` | Summary language | `EN` or `FR` |
+| `emailRecipient` | Optional: email address for summary | `team@example.com` |
+
+## Screenshot
+
+> Include a screenshot of a successful execution here: `screenshot-success.png`
--- /dev/null
+++ workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - Claude + n8n","nodes":[{"parameters":{},"id":"trigger-cron","name":"Weekly Cron Trigger","type":"n8n-nodes-base.cron","typeVersion":1,"position":[250,300],"webhookId":"weekly-cron"},{"parameters":{"jsCode":"// Set configurable variables\nreturn [{\n  json: {\n    githubOwner: $env.GITHUB_OWNER || 'claude-builders-bounty',\n    githubRepo: $env.GITHUB_REPO || 'claude-builders-bounty/claude-builders-bounty',\n    githubRepoName: $env.GITHUB_REPO_NAME || 'claude-builders-bounty',\n    destinationWebhook: $env.DESTINATION_WEBHOOK || '',\n    language: $env.LANGUAGE || 'EN',\n    emailRecipient: $env.EMAIL_RECIPIENT || '',\n    sinceDate: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()\n  }\n}];"},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.githubOwner }}/{{ $json.githubRepoName }}/commits?since={{ $json.sinceDate }}&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,200],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"githubApi"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.githubOwner }}/{{ $json.githubRepoName }}/issues?state=closed&since={{ $json.sinceDate }}&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,400],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"githubApi"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.githubOwner }}/{{ $json.githubRepoName }}/pulls?state=closed&per_page=100","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[650,600],"credentials":{"httpHeaderAuth":{"id":"github-token","name":"githubApi"}}},{"parameters":{"jsCode":"const commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json;\n\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000));\n\nconst config = $input.first().json;\nconst isFrench = config.language === 'FR';\n\nconst prompt = isFrench \n  ? `Résume l'activité de développement de cette semaine pour le repo ${config.githubRepo} en français. Sois concis mais informatif.`\n  : `Summarize this week's development activity for the repo ${config.githubRepo}. Be concise but informative.`;\n\nconst data = {\n  commits: commits.map(c => ({ message: c.commit.message, author: c.commit.author.name, date: c.commit.author.date }