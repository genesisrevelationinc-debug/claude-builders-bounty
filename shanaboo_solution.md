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
+1. **Import workflow**: In n8n, click *Workflows* → *Import from File* → select `weekly-dev-summary.json`
+2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*
+3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN/FR)
+4. **Activate**: Toggle the workflow *Active* — it runs automatically every Friday at 5 PM
+5. **Test manually**: Click *Execute Workflow* to verify — check the webhook channel for your summary
+
+## Delivery
+
+This workflow delivers summaries via **Discord webhook** (configurable in the `Set Config` node). To use Slack instead, replace the `HTTP Request` node URL with your Slack webhook URL.
+
+## Required Credentials
+
+- `githubApi`: GitHub Personal Access Token (classic) with `repo` scope
+- `anthropicApi`: Anthropic API key from [console.anthropic.com](https://console.anthropic.com)
+
+## Workflow Nodes
+
+| Node | Purpose |
+|------|---------|
+| Cron | Triggers weekly (Fri 17:00) |
+| Set Config | Defines repo, language, webhook |
+| GitHub Commits | Fetches commits from past 7 days |
+| GitHub Issues | Fetches closed issues from past 7 days |
+| GitHub PRs | Fetches merged PRs from past 7 days |
+| Merge Data | Combines all GitHub data |
+| Claude API | Generates narrative summary |
+| Format Message | Prepares Discord payload |
+| Send to Discord | Posts via webhook |
+
+## Language Support
+
+Set `language` to `EN` or `FR` in the `Set Config` node. The Claude prompt adapts automatically.
+
+## Screenshot
+
+![Successful Execution](screenshot.png) — *Replace with your actual screenshot after testing*
+
--- /dev/null
+++ b/workflows/n8n-weekly-dev-summary/weekly-dev-summary.json
@@ -0,0 +1,1 @@
+{"name":"Weekly Dev Summary - GitHub + Claude","nodes":[{"parameters":{"rule":{"interval":[{"field":"weeks","value":1}],"hours":17,"minutes":0,"weekdays":["5"]}},"type":"n8n-nodes-base.scheduleTrigger","typeVersion":1,"position":[0,0],"id":"cron-trigger","name":"Weekly Cron (Fri 5pm)"},{"parameters":{"values":{"string":[{"name":"repoOwner","value":"=YOUR_REPO_OWNER"},{"name":"repoName","value":"=YOUR_REPO_NAME"},{"name":"webhookUrl","value":"=YOUR_DISCORD_WEBHOOK_URL"},{"name":"language","value":"EN"}]}},"type":"n8n-nodes-base.set","typeVersion":2,"position":[200,0],"id":"set-config","name":"Set Config"},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/commits","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"queryParameters":{"parameters":[{"name":"since","value":"={{ DateTime.now().minus({ days: 7 }).toISO() }}"},{"name":"per_page","value":"100"}]},"options":{}},"type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[400,-200],"id":"github-commits","name":"GitHub Commits","credentials":{"httpHeaderAuth":{"id":"githubApi","name":"githubApi"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/issues","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"since","value":"={{ DateTime.now().minus({ days: 7 }).toISO() }}"},{"name":"per_page","value":"100"}]},"options":{}},"type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[400,0],"id":"github-issues","name":"GitHub Issues","credentials":{"httpHeaderAuth":{"id":"githubApi","name":"githubApi"}}},{"parameters":{"url":"=https://api.github.com/repos/{{ $json.repoOwner }}/{{ $json.repoName }}/pulls","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"Accept","value":"application/vnd.github.v3+json"},{"name":"User-Agent","value":"n8n-weekly-summary"}]},"queryParameters":{"parameters":[{"name":"state","value":"closed"},{"name":"sort","value":"updated"},{"name":"direction","value":"desc"},{"name":"per_page","value":"100"}]},"options":{}},"type":"n8n-nodes-base.httpRequest","typeVersion":4,"position":[400,200],"id":"github-prs","name":"GitHub PRs","credentials":{"httpHeaderAuth":{"id":"githubApi","name":"githubApi"}}},{"parameters":{"mode":"jsonToBinary","options":{}},"type":"n8n-nodes-base.convertToFile","typeVersion":1,"position":[600,-200],"id":"merge-commits","name":"Merge Commits"},{"parameters":{"mode":"jsonToBinary","options":{}},"type":"n8n-nodes-base.convertToFile","typeVersion":1,"position":[600,0],"id":"merge-issues","name":"Merge Issues"},{"parameters":{"mode":"jsonToBinary","options":{}},"type":"n8n-nodes-base.convertToFile","typeVersion":1,"position":[600,200],"id":"merge-prs","name":"Merge PRs"},{"parameters":{"jsCode":"// Merge all GitHub data into a single object\nconst commits = $input.all()[0]?.json || [];\nconst issues = $input.all()[1]?.json || [];\nconst prs = $input.all()[2]?.json || [];\n\nconst mergedPRs = prs.filter(pr => pr.merged_at);\n\nreturn [{\n  json: {\n    commits: commits.map(c => ({\n      message: c.commit?.message?.split('\\n')[0],\n      author: c.commit?.