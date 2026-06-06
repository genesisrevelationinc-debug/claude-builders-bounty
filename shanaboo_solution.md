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
+### 1. Import the workflow
+In n8n: **Settings** → **Import/Export** → Import `workflow.json`
+
+### 2. Set credentials
+Create these credential entries in n8n:
+- **Claude API**: Your Anthropic API key
+- **GitHub API**: Personal access token with `repo` scope
+- **SMTP** (if using email) or **Webhook** (if using Discord/Slack)
+
+### 3. Configure variables
+Open the workflow and edit the **Set Variables** node:
+- `repoOwner` / `repoName`: Target GitHub repository
+- `language`: `EN` or `FR`
+- `deliveryMethod`: `email` or `webhook`
+- `destination`: Email address or webhook URL
+
+### 4. Activate the workflow
+Toggle the workflow **Active**. The cron trigger runs Fridays at 5 PM UTC.
+
+### 5. Test manually
+Click **Execute Workflow** to verify. Check execution logs for the green checkmark.
+
+---
+
+## Workflow Overview
+
+| Node | Purpose |
+|------|---------|
+| Cron Trigger | Weekly schedule (Fri 17:00 UTC) |
+| Set Variables | Configurable parameters |
+| GitHub Commits | Fetch commits from past 7 days |
+| GitHub Issues | Fetch closed issues from past 7 days |
+| GitHub PRs | Fetch merged PRs from past 7 days |
+| Merge Data | Combine all GitHub data |
+| Claude Prompt | Generate narrative summary |
+| Claude API | Call `claude-sonnet-4-20250514` |
+| Deliver | Email or webhook output |
+
+## Screenshot
+
+![Successful Execution](screenshot.png)
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/workflow.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","value":1},{"field":"hours","value":17}]},"timezone":"UTC"},"id":"cron-trigger","name":"Weekly Cron (Fri 5PM)","type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[250,300]},{"parameters":{"values":{"string":[{"name":"repoOwner","value":"={{ $env.GITHUB_REPO_OWNER || \"claude-builders-bounty\" }}"},{"name":"repoName","value":"={{ $env.GITHUB_REPO_NAME || \"claude-builders-bounty\" }}"},{"name":"language","value":"={{ $env.SUMMARY_LANGUAGE || \"EN\" }}"},{"name":"deliveryMethod","value":"={{ $env.DELIVERY_METHOD || \"webhook\" }}"},{"name":"destination","value":"={{ $env.DELIVERY_DESTINATION || \"\" }}"},{"name":"claudeModel","value":"claude-sonnet-4-20250514"}]},"options":{}},"id":"set-variables","name":"Set Variables","type":"n8n-nodes-base.set","typeVersion":2,"position":[450,300]},{"parameters":{"resource":"repository","operation":"listCommits","owner":"={{ $json.repoOwner }}","repository":"={{ $json.repoName }}","since":"={{ DateTime.now().minus({days: 7}).toISO() }}","returnAll":true},"id":"github-commits","name":"GitHub Commits","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,200],"credentials":{"githubApi":"github-api"}},{"parameters":{"resource":"issue","operation":"getAll","owner":"={{ $('Set Variables').item.json.repoOwner }}","repository":"={{ $('Set Variables').item.json.repoName }}","state":"closed","since":"={{ DateTime.now().minus({days: 7}).toISO() }}","returnAll":true},"id":"github-issues","name":"GitHub Closed Issues","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,300],"credentials":{"githubApi":"github-api"}},{"parameters":{"resource":"pullRequest","operation":"getAll","owner":"={{ $('Set Variables').item.json.repoOwner }}","repository":"={{ $('Set Variables').item.json.repoName }}","state":"closed","returnAll":true},"id":"github-prs","name":"GitHub Merged PRs","type":"n8n-nodes-base.github","typeVersion":1,"position":[650,400],"credentials":{"githubApi":"github-api"}},{"parameters":{"mode":"mergeByPosition"},"id":"merge-data","name":"Merge GitHub Data","type":"n8n-nodes-base.merge","typeVersion":2,"position":[850,300]},{"parameters":{"jsCode":"const commits = $input.all()[0]?.json?.commits || $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json?.issues || $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json?.pullRequests || $input.all()[2]?.json || [];\n\nconst lang = $('Set Variables').item.json.language || 'EN';\nconst isFrench = lang === 'FR';\n\nconst commitList = Array.isArray(commits) ? commits.map(c => `- ${c.commit?.message?.split('\\n')[0] || c.message} (${c.author?.login || c.commit?.author?.name || 'unknown'})`).join('\\n') : 'No commits';\nconst issueList = Array.isArray(issues) ? issues.filter(i => i.closed_at && new Date(i.closed_at) > Date.now() - 7*24*60*60*1000).map(i => `- #${i.number}: ${i.title}`).join('\\n') : 'No closed issues';\nconst prList = Array.isArray(prs) ? prs.filter(p => p.merged_at && new Date(p.merged_at) > Date.now() - 7*24*60*60*1000).map(p => `- #${p.number}: ${p.title} by @${p.user?.login || 'unknown'}`).join('\\n') : 'No merged PRs';\n\nconst prompt = isFrench \n  ? `Rédige un résumé hebdomadaire concis et engageant de l'activité de développement pour ce dépôt. Utilise un ton professionnel mais accessible.\n\nCOMMITS (7 derniers jours):\n${commitList}\n\nISSUES FERMÉES:\n${issueList}\n\nPULL REQUESTS FUSIONNÉES:\n${prList}\n\nFormat: Markdown. Longueur: 200-300 m