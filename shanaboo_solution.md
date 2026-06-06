Looking at the issue, I need to create an n8n workflow for generating weekly development summaries using the Claude API. Since there are no existing workflow files, I'll create the necessary structure.

First, let me create a workflows directory and the actual workflow file:

```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary.json
@@ -0,0 +1,1024 @@
+{
+  "name": "Weekly Dev Summary Generator",
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
+        "operation": "issuesAndPullRequests",
+        "query": "repo:={{ $json[\"github_repo\"] }} is:issue state:closed closed:>={{ $json[\"start_date\"] }} closed:<={{ $json[\"end_date\"] }}",
+        "options": {}
+      },
+      "id": "2",
+      "name": "GitHub Issues Search",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "commits",
+        "query": "repo:={{ $json[\"github_repo\"] }} committer-date:{{ $json[\"start_date\"] }}..{{ $json[\"end_date\"] }}",
+        "options": {}
+      },
+      "id": "3",
+      "name": "GitHub Commits Search",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "issuesAndPullRequests",
+        "query": "repo:={{ $json[\"github_repo\"] }} is:pr state:closed merged:>={{ $json[\"start_date\"] }} merged:<={{ $json[\"end_date\"] }}",
+        "options": {}
+      },
+      "id": "4",
+      "name": "GitHub PRs Search",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        550
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-3-5-sonnet-20240620",
+        "options": {
+          "systemPrompt": "You are a technical writer creating a weekly development summary. Be concise and focus on the most important changes.",
+          "maxTokens": 2048,
+          "temperature": 0.7
+        },
+        "prompt": "Create a weekly development summary in {{ $json[\"language\"] }} for the {{ $json[\"github_repo\"] }} repository.\n\nDate Range: {{ $json[\"start_date\"] }} to {{ $json[\"end_date\"] }}\n\nRecent commits:\n{% for commit in $json[\"commits\"] %}\n- {{ commit.commit.message }} (by {{ commit.commit.author.name }})\n{% endfor %}\n\nClosed issues:\n{% for issue in $json[\"issues\"] %}\n- #{{ issue.number }}: {{ issue.title }}\n{% endfor %}\n\nMerged pull requests:\n{% for pr in $json[\"pull_requests\"] %}\n- #{{ pr.number }}: {{ pr.title }}\n{% endfor %}\n\nPlease create a narrative summary that highlights the key developments, major features, and important fixes from this week's activity. Organize the information in a clear, professional format."
+      },
+      "id": "5",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1.1,
+      "position": [
+        1000,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "const now = new Date();\nconst end_date = now.toISOString().split('T')[0];\n\n// Calculate start date (7 days ago)\nconst startDate = new Date(now);\nstartDate.setDate(now.getDate() - 7);\nconst start_date = startDate.toISOString().split('T')[0];\n\n// Get repository from environment variables\nconst github_repo = $env.GITHUB_REPO || 'claude-builders-bounty/claude-builders-bounty';\n\n// Get language from environment variables (default to EN)\nconst language = $env.LANGUAGE || 'EN';\n\n// Get delivery method\nconst delivery_method = $env.DELIVERY_METHOD || 'email';\n\nreturn [{ \n  json: { \n    start_date,\n    end_date,\n    github_repo,\n    language,\n    delivery_method\n  } \n}];"
+      },
+      "id": "6",
+      "name": "Set Date Range",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 2,
+      "position": [
+        400,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "// Process commits data\nconst commits = [];\n\nif (items.length > 0) {\n  items[0].json.commits = $input.all();\n  return [items[0]];\n}\n\nreturn items;"
+      },
+      "id": "7",
+      "name": "Process Commits",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 2,
+      "position": [
+        700,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "// Process issues data\nconst issues = [];\n\nif (items.length > 0) {\n  items[0].json.issues = $input.all();\n  return [items[0]];\n}\n\nreturn items;"
+      },
+      "id": "8",
+      "