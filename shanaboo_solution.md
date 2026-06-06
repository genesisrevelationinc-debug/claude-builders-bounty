```diff
--- /dev/null
+++ b/n8n-github-weekly-summary.json
@@ -0,0 +1,1178 @@
+{
+  "name": "Weekly GitHub Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "0",
+      "name": "Start",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ],
+      "webhookId": "a1b2c3d4-e5f6-7890-ghij-k1l2m3n4o5p6"
+    },
+    {
+      "parameters": {
+        "resource": "commits",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "additionalFields": {
+          "since": "={{ $parameter[\"startDate\"] }}",
+          "until": "={{ $parameter[\"endDate\"] }}"
+        }
+      },
+      "id": "1",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ],
+      "credentials": {
+        "githubApi": "={{ $parameter[\"githubCredentials\"] }}"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "issues",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "options": {
+          "state": "closed",
+          "since": "={{ $parameter[\"startDate\"] }}"
+        }
+      },
+      "id": "2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ],
+      "credentials": {
+        "githubApi": "={{ $parameter[\"githubCredentials\"] }}"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "pulls",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "options": {
+          "state": "closed",
+          "since": "={{ $parameter[\"startDate\"] }}"
+        }
+      },
+      "id": "3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ],
+      "credentials": {
+        "githubApi": "={{ $parameter[\"githubCredentials\"] }}"
+      }
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json[\"prompt\"] }}",
+        "options": {
+          "maxTokensToSample": 1000
+        }
+      },
+      "id": "4",
+      "name": "Claude API",
+      "type": "nodes/claude-ai-plugin.claude",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        300
+      ],
+      "credentials": {
+        "claudeApi": "={{ $parameter[\"claudeCredentials\"] }}"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "send",
+        "data": "={{ $json[\"summary\"] }}",
+        "additionalFields": {
+          "to": "={{ $parameter[\"email\"] }}",
+          "subject": "={{ $parameter[\"emailSubject\"] }}"
+        }
+      },
+      "id": "5",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1250,
+        300
+      ],
+      "credentials": {
+        "smtp": "={{ $parameter[\"emailCredentials\"] }}"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "send",
+      },
+      "id": "6",
+      "name": "Send to Webhook",
+      "type": "n8n-nodes-base.webhook",
+      "typeVersion": 1,
+      "position": [
+        1450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "set",
+        "values": {
+          "repoOwner": "={{ $parameter[\"repoOwner\"] }}",
+          "repoName": "={{ $parameter[\"repoName\"] }}",
+          "startDate": "={{ $parameter[\"startDate\"] }}",
+          "endDate": "={{ $parameter[\"endDate\"] }}",
+          "githubCredentials": "={{ $parameter[\"githubCredentials\"] }}",
+          "claudeCredentials": "={{ $parameter[\"claudeCredentials\"] }}",
+          "email": "={{ $parameter[\"email\"] }}",
+          "emailSubject": "={{ $parameter[\"emailSubject\"] }}",
+          "emailCredentials": "={{ $parameter[\"emailCredentials\"] }}",
+          "language": "={{ $parameter[\"language\"] }}"
+        }
+      },
+      "id": "7",
+      "name": "Set Variables",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        350,
+        100
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "function",
+        "functionCode": "const { DateTime } = require('luxon');\n\nconst now = DateTime.now();\nconst lastWeek = now.minus({ weeks: 1 });\n\nitems[0].json = {\n  startDate: lastWeek.toISO(),\n  endDate: now.toISO(),\n  repoOwner: 'cla