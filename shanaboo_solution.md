```diff
--- /dev/null
+++ b/n8n-claude-workflow.json
@@ -1,0 +1,395 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "triggerTimes": {
+          "item": [
+            {
+              "mode": "everyWeek",
+              "cronExpression": "0 17 * * 5"
+            }
+          }
+        ]
+      },
+      "id": "0",
+      "name": "Cron Trigger",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        0,
+        0
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getAll commits",
+        "owner": "={{ $parameter[\"owner\"] }}",
+        "repository": "={{ $parameter[\"repository\"] }}",
+        "filters": {
+          "since": "={{ $now.toISODate() }}T00:00:00Z",
+          "until": "={{ $now.toISODate() }}T23:59:59Z"
+        }
+      },
+      "id": "1",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        250,
+        0
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"owner\"] }}",
+        "repository": "={{ $parameter[\"repository\"] }}",
+        "state": "closed",
+        "sort": "updated",
+        "direction": "desc"
+      },
+      "id": "2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        400,
+        0
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"owner\"] }}",
+        "repository": "={{ $parameter[\"repository\"] }}",
+        "state": "closed"
+      },
+      "id": "3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        0
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json[\"prompt\"] }}",
+        "system": "={{ $json[\"system_prompt\"] }}",
+        "max_tokens": 1000
+      },
+      "id": "4",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        700,
+        0
+      ],
+      "credentials": {
+        "claudeApi": "Claude API"
+      }
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{ $parameter[\"fromEmail\"] }}",
+        "toEmail": "={{ $parameter[\"toEmail\"] }}",
+        "subject": "={{ $parameter[\"subject\"] }}",
+        "text": "={{ $json[\"summary\"] }}",
+        "options": {}
+      },
+      "id": "5",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        850,
+        0
+      ],
+      "credentials": {
+        "smtp": "SMTP"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "repository",
+        "operation": "getAll commits",
+        "owner": "={{ $parameter[\"owner\"] }}",
+        "repository": "={{ $parameter[\"repository\"] }}",
+        "filters": {
+          "since": "={{ $now.minus({ weeks: 1 }).toISODate() }}T00:00:00Z",
+          "until": "={{ $now.toISODate() }}T23:59:59Z"
+        }
+      },
+      "id": "6",
+      "name": "Get Commits (Last Week)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        250,
+        150
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issue",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"owner\"] }}",
+        "repository": "={{ $parameter[\"repository\"] }}",
+        "state": "closed",
+        "sort": "updated",
+        "direction": "desc",
+        "filters": {
+          "since": "={{ $now.minus({ weeks: 1 }).toISODate() }}T00:00:00Z",
+          "until": "={{ $now.toISODate() }}T23:59:59Z"
+        }
+      },
+      "id": "7",
+      "name": "Get Closed Issues (Last Week)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        400,
+        150
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+       