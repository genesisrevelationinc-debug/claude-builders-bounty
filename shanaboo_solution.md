 ```diff
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/README.md
@@ -0,0 +1,45 @@
+# n8n + Claude Weekly Dev Summary Workflow
+
+Automated weekly narrative summary of GitHub repo activity, powered by n8n and Claude API.
+
+## Quick Setup (5 steps)
+
+### 1. Import the workflow
+In n8n: **Settings** → **Import from File** → Select `weekly-dev-summary.json`
+
+### 2. Set credentials
+- **GitHub API**: Create a [GitHub Personal Access Token](https://github.com/settings/tokens) with `repo` scope
+- **Claude API**: Get your key from [Anthropic Console](https://console.anthropic.com)
+- **Email (SMTP)** or **Webhook**: Configure your delivery method
+
+### 3. Configure variables
+Open the **Set Variables** node and set:
+- `repoOwner` / `repoName`: Target GitHub repository
+- `language`: `EN` or `FR`
+- `deliveryMethod`: `email` or `webhook`
+- `webhookUrl`: Discord/Slack webhook URL (if using webhook)
+- `smtpSettings`: Your SMTP config (if using email)
+
+### 4. Activate the workflow
+Toggle the workflow **On**. It runs automatically every Friday at 5 PM.
+
+### 5. Test manually
+Click **Execute Workflow** to run a test immediately.
+
+---
+
+## Delivery Options
+
+| Method | Configuration |
+|--------|--------------|
+| **Email** | Fill SMTP fields in the Email node |
+| **Discord/Slack** | Paste webhook URL in `webhookUrl` variable |
+
+## Required n8n Nodes
+- Cron Trigger
+- HTTP Request (GitHub API)
+- Anthropic (Claude) Chat Model
+- Code (data transformation)
+- Email or HTTP Request (delivery)
+
+## Screenshot
+
+> 📸 *Include screenshot of successful execution here*
--- /dev/null
+++ b/workflows/n8n-claude-weekly-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - Claude + n8n","nodes":[{"parameters":{"rule":{"interval":[{"field":"weekDay","operation":["on","friday"],"value":5},{"field":"hour","operation":["on"],"value":17},{"field":"minute","operation":["on"],"value":0}]}},"type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[0,0],"id":"cron-trigger","name":"Weekly Cron (Fri 5PM)"},{"parameters":{"jsCode":"// Calculate date range for last week\nconst now = new Date();\nconst endOfWeek = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 17, 0, 0);\nconst startOfWeek = new Date(endOfWeek);\nstartOfWeek.setDate(startOfWeek.getDate() - 7);\n\nconst since = startOfWeek.toISOString();\nconst until = endOfWeek.toISOString();\n\nreturn [{ json: { since, until, repoOwner: $env.REPO_OWNER || 'claude-builders-bounty', repoName: $env.REPO_NAME || 'claude-builders-bounty' } }];"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[200,0],"id":"set-date-range","name":"Set Date Range"},{"parameters":{"method":"GET","url":"={{ $json.githubApiUrl }}/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","sendQuery":true,"queryParameters":{"parameters":[{"name":"since","value":"={{ $json.since }}"},{"name":"until","value":"={{ $json.until }}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth"},"type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[400,-200],"id":"fetch-commits","name":"Fetch Commits"},{"parameters":{"method":"GET","url":"={{ $json.githubApiUrl }}/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ $json.since }}"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth"},"type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[400,0],"id":"fetch-issues","name":"Fetch Closed Issues"},{"parameters":{"method":"GET","url":"={{ $json.githubApiUrl }}/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","sendQuery":true,"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"per_page","value":"100"}]},"authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth"},"type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[400,200],"id":"fetch-prs","name":"Fetch Merged PRs"},{"parameters":{"jsCode":"const commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json;\n\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) >= new Date($input.all()[0].json.since));\n\nconst summary = {\n  commits: commits.map(c => ({ message: c.commit.message.split('\\n')[0], author: c.commit.author.name, date: c.commit.author.date })),\n  issuesClosed: issues.length,\n  prsMerged: mergedPRs.length,\n  topContributors: [...new Set(commits.map(c => c.commit.author.name))].slice(0, 5),\n  since: $input.all()[0].json.since,\n  until: $input.all()[0].json.until\n};\n\nreturn [{ json: summary }];"},"type":"n8n-nodes-base.code","typeVersion":2,"position":[600,0],"id":"aggregate-data","name":"Aggregate Data"},{"parameters":{"model":"claude-sonnet-4-20250514","messages":{"messageValues":[{"role":"system","content":"You are a technical writer creating weekly development summaries. Write in a friendly, professional tone.","messageType":"system"},{"role":"user","content":"={{ $json.prompt }}","messageType":"user"}]},"options":{}},"type":"@n8n/n8n-nodes-langchain.lmChatAnthropic","typeVersion":1,"position":[800,0],"id":"claude-summary","name":"Claude Summary"},{"parameters":{"jsCode":"const data = $input.first().json;\nconst lang = $env.LANGUAGE || 'EN';\n\nconst