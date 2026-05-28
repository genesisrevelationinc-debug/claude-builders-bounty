```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1159 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "minutes": 15,
+          "hour": 17,
+          "day": 5
+        }
+      },
+      "id": "Schedule1",
+      "name": "Weekly Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "commit",
+        "owner": "={{ $parameter[\"githubOwner\"] }}",
+        "repository": "={{ $parameter[\"githubRepo\"] }}",
+        "operation": "getAll",
+        "since": "={{ $now.toISO().substring(0, 10) }}",
+        "until": "={{ $now.toISO().substring(0, 10) }}",
+        "additionalFields": {
+          "since": "={{ $now.minus({ weeks: 1 }).toISO().substring(0, 10) }}",
+          "until": "={{ $now.toISO().substring(0, 10) }}"
+        }
+      },
+      "id": "Github1",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "owner": "={{ $parameter[\"githubOwner\"] }}",
+        "repository": "={{ $parameter[\"githubRepo\"] }}",
+        "operation": "getAll",
+        "state": "closed",
+        "additionalFields": {
+          "since": "={{ $now.minus({ weeks: 1 }).toISO().substring(0, 10) }}"
+        }
+      },
+      "id": "Github2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "owner": "={{ $parameter[\"githubOwner\"] }}",
+        "repository": "={{ $parameter[\"githubRepo\"] }}",
+        "operation": "getAll",
+        "state": "closed",
+        "additionalFields": {
+          "sort": "updated",
+          "direction": "desc",
+          "base": "main"
+        }
+      },
+      "id": "Github3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        550
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ `Summarize the following GitHub activity for the week in ${$parameter[\"language\"] === \"FR\" ? \"French\" : \"English\"}.\n\nCommits:\n${JSON.stringify($item(0).json.commits)}\n\nClosed Issues:\n${JSON.stringify($item(0).json.issues)}\n\nMerged PRs:\n${JSON.stringify($item(0).json.prs)}` }}",
+        "max_tokens": 1000,
+        "temperature": 0.5
+      },
+      "id": "Claude1",
+      "name": "Generate Summary",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        850,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "sendTo": "={{ $parameter[\"email\"] }}",
+        "subject": "=Weekly Development Summary for {{ $parameter[\"githubOwner\"] }}/{{ $parameter[\"githubRepo\"] }}",
+        "text": "=Here is the development summary for the week:\n\n{{ $json[\"text\"] }}"
+      },
+      "id": "Email1",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+        "combineBy": "combineAll",
+        "options": {}
+      },
+      "id": "Combine1",
+      "name": "Combine Data",
+      "type": "n8n-nodes-base.combine",
+      "typeVersion": 1,
+      "position": [
+        650,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "commits",
+              "value": "={{ $item(0).json }}"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "Set1",
+      "name": "Set Commits",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        550,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "issues",
+              "value": "={{ $item(0).json }}"
+            }
+          ]
+        },
+        "options": {}
+      },
+      "id": "Set2",
+      "name": "Set Issues",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        55