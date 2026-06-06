```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,274 @@
+{
+  "versionId": "1.0",
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Start",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "issues",
+        "owner": "={{ $json[\"github_repo\"].split(\"/\")[0] }}",
+        "repository": "={{ $json[\"github_repo\"].split(\"/\")[1] }}",
+        "query": "={{ \"repo:\" + $json[\"github_repo\"] + \" is:issue closed:>\" + $json[\"since_date\"] }}",
+        "returnAll": true
+      },
+      "id": "2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "pullRequests",
+        "owner": "={{ $json[\"github_repo\"].split(\"/\")[0] }}",
+        "repository": "={{ $json[\"github_repo\"].split(\"/\")[1] }}",
+        "query": "={{ \"repo:\" + $json[\"github_repo\"] + \" is:pr merged:>\" + $json[\"since_date\"] }}",
+        "returnAll": true
+      },
+      "id": "3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getCommits",
+        "owner": "={{ $json[\"github_repo\"].split(\"/\")[0] }}",
+        "repository": "={{ $json[\"github_repo\"].split(\"/\")[1] }}",
+        "since": "={{ $json[\"since_date\"] }}",
+        "until": "={{ $json[\"until_date\"] }}",
+        "returnAll": true
+      },
+      "id": "4",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        600
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ \"Please provide a narrative summary of the following GitHub activity for the week ending \" + $json[\"until_date\"] + \":\\n\\nClosed Issues:\\n\" + $json[\"closed_issues\"] + \"\\n\\nMerged PRs:\\n\" + $json[\"merged_prs\"] + \"\\n\\nCommits:\\n\" + $json[\"commits\"] }}",
+        "maxTokens": 1000,
+        "temperature": 0.7
+      },
+      "id": "5",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        750,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "subject": "={{ \"Weekly Dev Summary - \" + $json[\"github_repo\"] }}",
+        "to": "={{ $json[\"email\"] }}",
+        "body": "={{ $json[\"claude_response\"].content[0].text }}"
+      },
+      "id": "6",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        950,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "const today = new Date();\nconst lastWeek = new Date();\nlastWeek.setDate(today.getDate() - 7);\n\nitems[0] = {\n  json: {\n    github_repo: 'claude-builders-bounty/claude-builders-bounty',\n    email: 'devteam@example.com',\n    since_date: lastWeek.toISOString().split('T')[0],\n    until_date: today.toISOString().split('T')[0]\n  }\n};\n\nreturn items;"
+      },
+      "id": "7",
+      "name": "Set Dates",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+        250,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "const issues = items[0].json.response.items.map(issue => `- ${issue.title} (#${issue.number})`).join('\\n');\n\nitems[0].json = {\n  closed_issues: issues\n};\n\nreturn items;"
+      },
+      "id": "8",
+      "name": "Format Issues",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "const prs = items[0].json.response.items.map(pr => `- ${pr.title} (#${pr.number})`).join('\\n');\n\nitems[0].json = {\n  merged_prs: prs\n};\n\nreturn items;"
+      },
+      "id": "9",
+      "name": "Format PRs",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+