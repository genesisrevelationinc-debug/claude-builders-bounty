 ```diff
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/README.md
@@ -0,0 +1,45 @@
+# n8n Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.
+
+## Setup (5 steps)
+
+1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings* → *Credentials*
+
+3. **Configure variables**: Open the workflow and edit the `Set Config` node with your repo, destination, and language
+
+4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
+
+5. **Test**: Click *Execute Workflow* to run manually and verify the output
+
+## Configuration Variables
+
+| Variable | Description | Example |
+|----------|-------------|---------|
+| `githubRepo` | Target repository | `claude-builders-bounty/claude-builders-bounty` |
+| `destinationWebhook` | Email, Discord, or Slack webhook URL | `https://hooks.slack.com/services/...` |
+| `language` | Summary language | `EN` or `FR` |
+
+## Delivery Options
+
+The workflow supports **Discord**, **Slack**, or **email** delivery. Set your preferred `destinationWebhook` in the config node. For email, use an SMTP node instead of the HTTP Request node.
+
+## Required Scopes
+
+- **GitHub token**: `repo` (private repos) or `public_repo` (public repos)
+- **Claude API**: Standard API key with `claude-sonnet-4-20250514` access
+
+## Nodes Overview
+
+| Node | Purpose |
+|------|---------|
+| Cron Trigger | Weekly schedule (Fridays 17:00) |
+| Set Config | Centralized variables |
+| GitHub (3x) | Fetch commits, closed issues, merged PRs |
+| Claude API | Generate narrative summary |
+| HTTP Request | Deliver to webhook |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
+*Example: Successful workflow execution in n8n*
+
--- /dev/null
+++ /workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weekday","operation":"equals","value":"5"},{"field":"hour","operation":"equals","value":"17"}]}},"id":"cron-trigger","name":"Weekly Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"values":[{"name":"githubRepo","value":"={{ $env.GITHUB_REPO || \"claude-builders-bounty/claude-builders-bounty\" }}"},{"name":"destinationWebhook","value":"={{ $env.WEBHOOK_URL || \"\" }}"},{"name":"language","value":"={{ $env.LANGUAGE || \"EN\" }}"},{"name":"claudeModel","value":"claude-sonnet-4-20250514"}]},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.set","typeVersion":1,"position":[450,300]},{"parameters":{"resource":"repository","operation":"listCommits","owner":"={{ $json.githubRepo.split('/')[0] }}","repository":"={{ $json.githubRepo.split('/')[1] }}","since":"={{ DateTime.now().minus({ days: 7 }).toISO() }}","returnAll":true},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,200],"credentials":{"githubApi":"github-credentials"}},{"parameters":{"resource":"issue","operation":"getAll","owner":"={{ $('Set Config').item.json.githubRepo.split('/')[0] }}","repository":"={{ $('Set Config').item.json.githubRepo.split('/')[1] }}","state":"closed","since":"={{ DateTime.now().minus({ days: 7 }).toISO() }}","returnAll":true},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,300],"credentials":{"githubApi":"github-credentials"}},{"parameters":{"resource":"pullRequest","operation":"getAll","owner":"={{ $('Set Config').item.json.githubRepo.split('/')[0] }}","repository":"={{ $('Set Config').item.json.githubRepo.split('/')[1] }}","state":"closed","returnAll":true},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,400],"credentials":{"githubApi":"github-credentials"}},{"parameters":{"jsCode":"const commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000));\n\nconst recentIssues = issues.filter(issue => !issue.pull_request && new Date(issue.closed_at) > new Date(Date.now() - 7 * 24 * 60 * 60 * 1000));\n\nreturn [{\n  json: {\n    commits: commits.map(c => ({ message: c.commit.message.split('\\n')[0], author: c.commit.author.name, date: c.commit.author.date })),\n    issues: recentIssues.map(i => ({ title: i.title, number: i.number, closedAt: i.closed_at })),\n    prs: mergedPRs.map(p => ({ title: p.title, number: p.number, author: p.user.login, mergedAt: p.merged_at }))\n  }\n}];"},"id":"format-data","name":"Format GitHub Data","type":"n8n-nodes-base.code","typeVersion":1,"position":[850,300]},{"parameters":{"model":"={{ $('Set Config').item.json.claudeModel }}","messages":"={{ [\n  {\n    role: \"user\",\n    content: `Generate a weekly development summary for the repository ${$('Set Config').item.json.githubRepo}.\n\nLanguage: ${$('Set Config').item.json.language}\n\nCommits: ${JSON.stringify($input.all()[0].json.commits)}\nClosed Issues: ${JSON.stringify($input.all()[0].json.issues)}\nMerged PRs: ${JSON.stringify($input.all()[0].json.prs)}\n\nWrite a concise, engaging narrative summary (3-5 paragraphs) highlighting key changes, fixes, and contributions.