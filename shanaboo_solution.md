```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1154 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "weekday": "5",
+          "hour": "17",
+          "minute": "0"
+        }
+      },
+      "id": "1",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/commits",
+        "options": {
+          "query": {
+            "since": "={{$runIndex === 0 ? $execution.startDate : $prevNode.lastCommitDate}}",
+            "until": "={{$runIndex === 0 ? $execution.startDate : $prevNode.lastCommitDate}}"
+          }
+        },
+        "headerParametersUi": {
+          "parameter": [
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{$parameter[\"githubToken\"]}}"
+            },
+            {
+              "name": "X-GitHub-Api-Version",
+              "value": "2022-11-28"
+            }
+          ]
+        }
+      },
+      "id": "2",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 2.1,
+      "position": [
+        500,
+        200
+      ],
+      "executeOnce": true
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/issues",
+        "options": {
+          "query": {
+            "state": "closed",
+            "since": "={{$runIndex === 0 ? $execution.startDate : $prevNode.lastIssueDate}}"
+          }
+        },
+        "headerParametersUi": {
+          "parameter": [
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{$parameter[\"githubToken\"]}}"
+            },
+            {
+              "name": "X-GitHub-Api-Version",
+              "value": "2022-11-28"
+            }
+          ]
+        }
+      },
+      "id": "3",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 2.1,
+      "position": [
+        500,
+        350
+      ],
+      "executeOnce": true
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/pulls",
+        "options": {
+          "query": {
+            "state": "closed",
+            "sort": "updated",
+            "direction": "desc"
+          }
+        },
+        "headerParametersUi": {
+          "parameter": [
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{$parameter[\"githubToken\"]}}"
+            },
+            {
+              "name": "X-GitHub-Api-Version",
+              "value": "2022-11-28"
+            }
+          ]
+        }
+      },
+      "id": "4",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 2.1,
+      "position": [
+        500,
+        500
+      ],
+      "executeOnce": true
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "=Generate a weekly development summary for the repository {{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}} based on the following activity:\n\nCommits:\n{{$json[\"commits\"]}}\n\nClosed Issues:\n{{$json[\"issues\"]}}\n\nMerged PRs:\n{{$json[\"pulls\"]}}\n\nPlease provide a narrative summary in {{$parameter[\"language\"]}} that highlights the key developments, fixes, and features added during this week. Format the response as a well-structured report with clear sections.",
+        "options": {
+          "max_tokens": 2048,
+          "temperature": 0.7
+        }
+      },
+      "id": "5",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        900,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "const commits = [];\n\nfor (const item of items) {\n  if (item.json && item.json.commit) {\n    commits.push({\n      author: item.json.commit.author.name,\n      message: item.json.commit.message,\n      date: item.json.commit.author.date\n    });\n  }\n}\n\nreturn [{ json: { commits } }];"
+      },
+      "id": "6",
+      "name": "Process Commits",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+        650,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "functionCode": "const issues = [];\n\nfor (const item of items) {\n  if (item.json && item.json.title) {\n    issues.push({\n      title: item.json.title,\n      number: item.json.number,\n      author: item.json.user.login,\n      closedAt: item.json.closed_at\n    });\n  }\n}\n