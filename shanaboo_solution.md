```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,200 @@
+{
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
+        "rule": {
+          "interval": "weeks",
+          "minutes": 5,
+          "hour": 17,
+          "date": 5,
+          "month": "*",
+          "weekday": "5",
+          "year": "*"
+        }
+      },
+      "id": "2",
+      "name": "Cron Job",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{ $parameter[\"repo\"] }}/commits",
+        "authentication": "queryAuth",
+        "queryAuth": "={{ $parameter[\"githubToken\"] }}",
+        "options": {
+          "qs": {
+            "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}",
+            "until": "={{ new Date().toISOString() }}"
+          }
+        }
+      },
+      "id": "3",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "={{ $parameter[\"githubApiUrl\"] }}/repos/{{ $parameter[\"repo\"] }}/issues",
+        "authentication": "queryAuth",
+        "queryAuth": "={{ $parameter[\"githubToken\"] }}",
+        "options": {
+          "qs": {
+            "state": "closed",
+            "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}"
+          }
+        }
+      },
+      "id": "4",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "={{ $parameter[\"githubApiUrl\"] }}/repos/{{ $parameter[\"repo\"] }}/pulls",
+        "authentication": "queryAuth",
+        "queryAuth": "={{ $parameter[\"githubToken\"] }}",
+        "options": {
+          "qs": {
+            "state": "closed",
+            "sort": "updated",
+            "direction": "desc"
+          }
+        }
+      },
+      "id": "5",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ `Human: Generate a ${$parameter[\"language\"] === 'FR' ? 'French' : 'English'} summary of the following GitHub activity for the repository ${$parameter[\"repo\"]}:\n\nCommits:\n${JSON.stringify($input[0].json.body)}\n\nClosed Issues:\n${JSON.stringify($input[1].json.body)}\n\nMerged PRs:\n${JSON.stringify($input[2].json.body)}\n\nPlease create a narrative summary of the week's activity in ${$parameter[\"language\"] === 'FR' ? 'French'  : 'English'}.` }}",
+        "max_tokens": 1000
+      },
+      "id": "6",
+      "name": "Claude API",
+      "type": "claude-ai.Claude",
+      "typeVersion": 1,
+      "position": [
+        1250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "sendTo": "={{ $parameter[\"email\"] }}",
+        "subject": "={{ `Weekly Dev Summary - ${$parameter[\"repo\"]}` }}",
+        "text": "={{ $input[0].json.text }}",
+        "options": {
+          "fromEmail": "={{ $parameter[\"fromEmail\"] }}"
+        }
+      },
+      "id": "7",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1450,
+        300
+      ]
+    }
+  ],
+  "connections": {
+    "Cron Job": {
+      "main": [
+        [
+          {
+            "node": "Get Commits",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Get Commits": {
+      "main": [
+        [
+          {
+            "node": "Get Closed Issues",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Get Closed Issues": {
+      "main": [
+        [
+          {
+            "node": "Get Merged PRs",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Get Merged PRs": {
+      "main": [
+        [
+          {
+            "node": "Claude API",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+   