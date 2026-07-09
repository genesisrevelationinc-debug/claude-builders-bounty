```diff
--- /dev/null
+++ b/workflows/weekly-dev-summary.json
@@ -0,0 +1,450 @@
+{
+  "name": "Weekly Dev Summary – Claude API",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "cronExpression",
+              "expression": "0 17 * * 5"
+            }
+          ]
+        }
+      },
+      "id": "cron-trigger",
+      "name": "Friday 5pm Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [250, 300]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/commits",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github+json"
+            },
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{ $json.githubToken }}"
+            }
+          ]
+        },
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "since",
+              "value": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-commits",
+      "name": "Fetch Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [450, 300]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/issues",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github+json"
+            },
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{ $json.githubToken }}"
+            }
+          ]
+        },
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "state",
+              "value": "closed"
+            },
+            {
+              "name": "since",
+              "value": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            },
+            {
+              "name": "filter",
+              "value": "all"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-issues",
+      "name": "Fetch Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [450, 500]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "=https://api.github.com/repos/{{ $json.repo }}/pulls",
+        "authentication": "genericCredentialType",
+        "genericAuthType": "httpHeaderAuth",
+        "sendHeaders": true,
+        "headerParameters": {
+          "parameters": [
+            {
+              "name": "Accept",
+              "value": "application/vnd.github+json"
+            },
+            {
+              "name": "Authorization",
+              "value": "=Bearer {{ $json.githubToken }}"
+            }
+          ]
+        },
+        "queryParameters": {
+          "parameters": [
+            {
+              "name": "state",
+              "value": "closed"
+            },
+            {
+              "name": "sort",
+              "value": "updated"
+            },
+            {
+              "name": "direction",
+              "value": "desc"
+            },
+            {
+              "name": "per_page",
+              "value": "100"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "fetch-prs",
+      "name": "Fetch Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.1,
+      "position": [450, 700]
+    },
+    {
+      "parameters": {
+        "jsCode": "// Merge all GitHub data into a single structured payload\nconst commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json;\n\n// Filter PRs to only merged ones (merged_at is not null)\nconst mergedPRs = Array.isArray(prs) ? prs.filter(p => p.merged_at) : [];\n\n// Filter issues to exclude pull requests (issues that have pull_request field)\nconst pureIssues = Array.isArray(issues) ? issues.filter(i => !i.pull_request) : [];\n\n// Extract relevant fields from commits\nconst commitSummaries = Array.isArray(commits) ? commits.slice(0, 20).map(c => ({\n  message: c.commit.message.split('\\n')[0],\n  author: c.commit.author.name,\n  date: c.commit.author.date,\n  sha: c.sha.substring(0, 7)\n})) : [];\n\n// Extract relevant fields from issues\nconst issueSummaries = pureIssues.slice(0, 20).map(i => ({\n  title: i.title,\n  number: i.number,\n  closed_at: i.closed_at,\n  html_url: i.html_url\n}));\n\n// Extract relevant fields from PRs\nconst prSummaries = mergedPRs.slice(0, 20).map(p => ({\n