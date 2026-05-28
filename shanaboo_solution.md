```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1059 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "triggerAtDayOfWeek": "5",
+          "triggerAtHour": 17,
+          "triggerAtMinute": 0
+        }
+      },
+      "id": "Schedule1",
+      "name": "Schedule",
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
+        "q": "=repo:{{ $json.repository }} is:pr is:merged closed:>={{ $json.since }}",
+        "options": {
+          "per_page": 100
+        }
+      },
+      "id": "Github1",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        250
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "GitHub",
+          "name": "GitHub"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "issuesAndPullRequests",
+        "q": "=repo:{{ $json.repository }} is:issue is:closed closed:>={{ $json.since }}",
+        "options": {
+          "per_page": 100
+        }
+      },
+      "id": "Github2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        400
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "GitHub",
+          "name": "GitHub"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getCommits",
+        "owner": "={{ $json.owner }}",
+        "repository": "={{ $json.repo }}",
+        "options": {
+          "since": "={{ $json.since }}"
+        }
+      },
+      "id": "Github3",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        100
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "GitHub",
+          "name": "GitHub"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "repository",
+              "value": "={{ $parameter1.repository }}"
+            },
+            {
+              "name": "since",
+              "value": "={{ $parameter1.since }}"
+            },
+            {
+              "name": "owner",
+              "value": "={{ $parameter1.owner }}"
+            },
+            {
+              "name": "repo",
+              "value": "={{ $parameter1.repo }}"
+            },
+            {
+              "name": "language",
+              "value": "={{ $parameter1.language }}"
+            }
+          ]
+        }
+      },
+      "id": "Set1",
+      "name": "Set Configuration",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        400,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+        "combine": {
+          "mergeBy": "combineAll",
+          "join": "outer"
+        }
+      },
+      "id": "ItemLists1",
+      "name": "Combine Data",
+      "type": "n8n-nodes-base.itemLists",
+      "typeVersion": 2.1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "messages": {
+          "values": [
+            {
+              "content": "=You are a technical writer creating a weekly development summary for a software project. The summary should be concise, informative, and well-structured. Focus on the most important changes and avoid unnecessary details.\n\nPlease write the summary in {{ $json.language == 'FR' ? 'French' : 'English' }}.\n\nHere is the data for this week:\n\nCommits:\n{{ $json.commits.map(c => `- ${c.commit.message.split('\\n')[0]} (${c.author.login})`).join('\\n') }}\n\nMerged PRs:\n{{ $json.prs.map(pr => `- ${pr.title} (#${pr.number}) by ${pr.user.login}`).join('\\n') }}\n\nClosed Issues:\n{{ $json.issues.map(issue => `- ${issue.title} (#${issue.number})`).join('\\n') }}\n\nPlease structure the summary as follows:\n1. A brief introduction (2-3 sentences)\n2. Key Commits (highlight most significant)\n3. Merged Pull Requests\n4. Closed Issues\n5. A brief conclusion (1-2 sentences)\n\nTotal length should be around 300-400 words.",
+              "role": "user"
+            }
+          ]
+        },
+        "options": {
+          "maxTokens": 1000,
+          "temperature": 0.7
+        }
+      },
+      "id": "AnthropicClaudeAPI1",
+      "name": "Generate Summary",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1.1,
+      "position": [
+        1000,
+        300