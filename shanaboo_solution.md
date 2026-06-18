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
+### 1. Import the workflow
+In n8n, click **Workflows → Import from File** and select `weekly-dev-summary.json`.
+
+### 2. Set credentials
+Create three credentials in n8n:
+- **Claude API**: Your Anthropic API key
+- **GitHub API**: Personal access token with `repo` scope
+- **Discord Webhook** (or email): Your webhook URL
+
+### 3. Configure variables
+Open the workflow and edit the **Set Config** node:
+- `repoOwner` / `repoName`: Target GitHub repository
+- `discordWebhook`: Your Discord webhook URL
+- `language`: `EN` or `FR`
+
+### 4. Activate the workflow
+Toggle the workflow **Active**. The cron trigger runs Fridays at 5 PM UTC.
+
+### 5. Test manually
+Click **Execute Workflow** to test immediately, or wait for the scheduled trigger.
+
+---
+
+## Delivery Method
+
+This workflow uses **Discord webhook** by default. To use Slack instead, replace the Discord node with an HTTP Request node pointing to your Slack webhook URL. For email, replace with an SMTP or SendGrid node.
+
+## Required n8n Nodes
+
+- Cron
+- Set (config)
+- HTTP Request (GitHub API)
+- Claude Chat Model (or HTTP Request for direct API)
+- Code (data processing)
+- Discord (or Webhook/Email)
+
+## Screenshot
+Add your successful execution screenshot here: `screenshot-success.png`
+
+--- /dev/null
+++ workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtDay":[5],"triggerAtHour":17,"triggerAtMinute":0}]}},"id":"cron-trigger","name":"Weekly Cron","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"values":{"string":[{"name":"repoOwner","value":"={{ $env.GITHUB_OWNER || \"claude-builders-bounty\" }}"},{"name":"repoName","value":"={{ $env.GITHUB_REPO || \"claude-builders-bounty\" }}"},{"name":"githubToken","value":"={{ $credentials.githubApi.apiKey }}"},{"name":"claudeApiKey","value":"={{ $credentials.claudeApi.apiKey }}"},{"name":"discordWebhook","value":"={{ $env.DISCORD_WEBHOOK }}"},{"name":"language","value":"={{ $env.SUMMARY_LANGUAGE || \"EN\" }}"},{"name":"daysToFetch","value":"7"}]},"options":{}},"id":"set-config","name":"Set Config","type":"n8n-nodes-base.set","typeVersion":2,"position":[450,300]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Authorization","value":"=token {{ $json.githubToken }}"},{"name":"Accept","value":"application/vnd.github.v3+json"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ DateTime.now().minus({ days: $json.daysToFetch }).toISO() }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,200]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Authorization","value":"=token {{ $json.githubToken }}"},{"name":"Accept","value":"application/vnd.github.v3+json"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ DateTime.now().minus({ days: $json.daysToFetch }).toISO() }}"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,400]},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Authorization","value":"=token {{ $json.githubToken }}"},{"name":"Accept","value":"application/vnd.github.v3+json"}]},"sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"options":{}},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[650,600]},{"parameters":{"jsCode":"// Aggregate data from GitHub APIs\nconst commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\n// Filter PRs to only merged ones in the last week\nconst oneWeekAgo = new Date();\noneWeekAgo.setDate(oneWeekAgo.getDate() - 7);\n\nconst mergedPRs = prs.filter(pr => {\n  if (!pr.merged_at) return false;\n  return new Date(pr.merged_at) >= oneWeekAgo;\n});\n\n// Filter issues closed in the last week (not from PRs)\nconst closedIssues = issues.filter(issue => {\n  if (issue.pull_request) return false; // Skip PRs that appear in issues\n  const closedAt = new Date(issue.closed_at);\n  return closedAt >= oneWeekAgo;\n});\n\n// Format commits\nconst commitList = commits.slice(0, 20).map(c => ({\n  message: c.commit.message.split('\\n')[0],\n  author: c.commit.author.name,\n  date: c.commit.author.date,\n  url: c.html_url\n}));\n\n// Format issues\nconst issueList = closedIssues.slice(0, 20).map(i => ({\n  title: i.title,\n  number: i.number,\n  closedAt: i.closed_at,\n  url: i.html_url\n}));\n\n// Format PRs\nconst prList = mergedPRs.slice(0, 20).