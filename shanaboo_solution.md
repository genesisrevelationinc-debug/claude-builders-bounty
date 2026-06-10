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
+1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+
+2. **Set credentials**: Add your *Claude API* and *GitHub* credentials in n8n *Settings* → *Credentials*
+
+3. **Configure variables**: Open the workflow and edit the——
+   - `repo` (GitHub owner/repo, e.g., `claude-builders-bounty/claude-builders-bounty`)
+   - `destination` (email address **or** webhook URL for Discord/Slack)
+   - `language` (`EN` or `FR`)
+
+4. **Activate**: Toggle the workflow *Active* — it runs automatically every Friday at 5 PM
+
+5. **Test manually**: Click *Execute Workflow* to verify and check the output
+
+---
+
+## Delivery Method
+
+This workflow supports **Discord/Slack webhook** by default.  
+Set `destination` to your webhook URL. For email delivery, replace the *HTTP Request* node with an *Email* node.
+
+## Required n8n Nodes
+
+- **Schedule Trigger** — weekly cron
+- **GitHub** — fetch commits, issues, PRs
+- **HTTP Request** — call Claude API
+- **HTTP Request** — send to webhook
+
+## Screenshot
+
+![Successful execution](screenshot.png)
+
+*Include your own screenshot after testing on a live n8n instance.*
+
+---
+
+*Built for the Claude Builders Bounty — MIT License*
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","triggerAtDay":[5],"triggerAtHour":[17]}]}},"type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[0,0],"id":"trigger-weekly","name":"Weekly Friday 5PM"},{"parameters":{"resource":"repository","operation":"listCommits","owner":"={{ $json.repo.split('/')[0] }}","repository":"={{ $json.repo.split('/')[1] }}","since":"={{ DateTime.now().minus({ days: 7 }).toISO() }}","returnAll":true},"type":"n8n-nodes-base.github","typeVersion":1,"position":[200,0],"id":"github-commits","name":"GitHub Commits"},{"parameters":{"resource":"issue","operation":"getAll","owner":"={{ $json.repo.split('/')[0] }}","repository":"={{ $json.repo.split('/')[1] }}","state100,"state":"closed","since":"={{ DateTime.now().minus({ days: 7 }).toISO() }}","returnAll":true},"type":"n8n-nodes-base.github","typeVersion":1,"position":[200,200],"id":"github-issues","name":"GitHub Closed Issues"},{"parameters":{"resource":"pullRequest","operation":"getAll","owner":"={{ $json.repo.split('/')[0] }}","repository":"={{ $json.repo.split('/')[1] }}","state":"closed","returnAll":true},"type":"n8n-nodes-base.github","typeVersion":1,"position":[200,400],"id":"github-prs","name":"GitHub Merged PRs"},{"parameters":{"jsCode":"// Filter to only merged PRs in last 7 days\nconst prs = $input.all()[0]?.json?.pullRequests || [];\nconst oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);\nconst mergedPRs = prs.filter(pr => pr.merged_at && new Date(pr.merged_at) > oneWeekAgo);\nreturn [{ json: { mergedPRs } }];"},"type":"n8n-nodes-base.code","typeVersion":1,"position":[400,400],"id":"filter-merged-prs","name":"Filter Merged PRs"},{"parameters":{"jsCode":"// Combine all GitHub data\nconst commits = $input.all().find(n => n.json.commits)?.json?.commits || [];\nconst issues = $input.all().find(n => n.json.issues)?.json?.issues || [];\nconst prs = $input.all().find(n => n.json.mergedPRs)?.json?.mergedPRs || [];\n\nconst repo = $input.all()[0]?.json?.repo || 'unknown/repo';\nconst language = $input.all()[0]?.json?.language || 'EN';\n\nconst summary = {\n  repo,\n  language,\n  period: 'last 7 days',\n  commits: commits.map(c => ({\n    message: c.commit.message.split('\\n')[0],\n    author: c.commit.author.name,\n    date: c.commit.author.date\n  })),\n  closedIssues: issues.map(i => ({\n    title: i.title,\n    number: i.number,\n    closed_at: i.closed_at\n  })),\n  mergedPRs: prs.map(p => ({\n    title: p.title,\n    number: p.number,\n    merged_at: p.merged_at\n  }))\n};\n\nreturn [{ json: summary }];"},"type":"n8n-nodes-base.code","typeVersion":1,"position":[600,200],"id":"combine-data","name":"Combine GitHub Data"},{"parameters":{"method":"POST","url":"https://api.anthropic.com/v1/messages","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendBody":true,"contentType":"json","body":{"model":"claude-sonnet-4-20250514","max_tokens":4096,"messages":[{"role":"user","content":"={{ $json.prompt }}"]}},"headers":{"anthropic-version":"2023-06-01","content-type":"application/json"},"options":{}},"type":"n8n-nodes-base.httpRequest","typeVersion":4.1,"position":[800,200],"id":"claude-api","name":"Claude API"},{"parameters":{"jsCode":"// Build prompt for Claude\nconst data = $input.all()[0].json;\nconst isFrench = data.language === 'FR';\n\nconst prompt = isFrench \n  ? `Résume l'activité de développement de la semaine pour le repo ${data.repo}.\n\nCommits (${data.commits.length}):\n${data.commits.map(c => `- ${c.message} (${c.author})`).join('\\n')}\n