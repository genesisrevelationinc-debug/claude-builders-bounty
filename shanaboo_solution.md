```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1079 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "triggerAt": "5:00 PM",
+          "triggerAtDay": "Friday"
+        }
+      },
+      "id": "Schedule Trigger",
+      "name": "Schedule Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $json[\"repoOwner\"] }}",
+        "repository": "={{ $json[\"repoName\"] }}",
+        "filters": {
+          "state": "all",
+          "base": "main"
+        },
+        "options": {
+          "sort": "updated",
+          "direction": "desc"
+        }
+      },
+      "id": "GitHub Pull Requests",
+      "name": "GitHub Pull Requests",
+      "type": "n8n-nodes-base.githubPullRequest",
+      "typeVersion": 1,
+      "position": [
+        550,
+        250
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $json[\"repoOwner\"] }}",
+        "repository": "={{ $json[\"repoName\"] }}",
+        "filters": {
+          "state": "closed"
+        }
+      },
+      "id": "GitHub Issues",
+      "name": "GitHub Issues",
+      "type": "n8n-nodes-base.githubIssue",
+      "typeVersion": 1,
+      "position": [
+        550,
+        450
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $json[\"repoOwner\"] }}",
+        "repository": "={{ $json[\"repoName\"] }}",
+        "filters": {
+          "since": "={{ $now.toISOString().substring(0, 10) }}T00:00:00Z"
+        }
+      },
+      "id": "GitHub Commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.githubCommit",
+      "typeVersion": 1,
+      "position": [
+        550,
+        50
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json[\"prompt\"] }}",
+        "maxTokens": 1000,
+        "temperature": 0.7
+      },
+      "id": "Claude API",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        350
+      ],
+      "credentials": {
+        "anthropicApi": "Anthropic API"
+      }
+    },
+    {
+      "parameters": {
+        "functionCode": "const now = new Date();\nconst oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\nconst formatDate = (date) => {\n  return date.toISOString().split('T')[0];\n};\n\nreturn [\n  {\n    json: {\n      repoOwner: 'claude-builders-bounty',\n      repoName: 'claude-builders-bounty',\n      since: formatDate(oneWeekAgo),\n      until: formatDate(now),\n      language: 'EN'\n    }\n  }\n];"
+      },
+      "id": "Set Variables",
+      "name": "Set Variables",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+        400,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "const items = [];\n\nfor (const item of $input.all()) {\n  const commits = item.json.commits || [];\n  const issues = item.json.issues || [];\n  const pullRequests = item.json.pullRequests || [];\n  \n  const language = item.json.language || 'EN';\n  \n  let prompt = '';\n  \n  if (language === 'FR') {\n    prompt = `Veuillez générer un résumé narratif des activités du dépôt GitHub pour la semaine dernière. Incluez les informations suivantes dans le résumé :\n\n1. Commits :\n${commits.map(commit => `- ${commit.commit.message}`).join('\\n')}\n\n2. Problèmes fermés :\n${issues.map(issue => `- ${issue.title}`).join('\\n')}\n\n3. Pull Requests fusionnées :\n${pullRequests.map(pr => `- ${pr.title}`).join('\\n')}\n\nVeuillez structurer le résumé de manière cohérente et narrative. Commencez par un bref aperçu, puis détaillez chaque catégorie. Utilisez un ton professionnel.`;\n  } else {\n    prompt = `Please generate a narrative summary of the GitHub repository activity for the past week. Include the following information in the summary:\n\n1. Commits:\n${commits.map(commit => `- ${commit.commit.message}`).join('\\n')}\n\n2. Closed Issues:\n${issues.map(issue => `- ${issue.title}`).join('\\n')}\n\n3. Merged Pull Requests:\n${pullRequests.map(pr => `- ${pr.title}`).join('\\n')}\n\nPlease structure the summary in a coherent and narrative way. Start with a brief overview, then detail each category. Use a professional tone.`;\n  }\n