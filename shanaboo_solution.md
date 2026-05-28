```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1056 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "triggerAtDay": 5,
+          "triggerAtHour": 17,
+          "triggerAtMinute": 0
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
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "filters": {
+          "state": "all",
+          "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}",
+          "until": "={{ new Date().toISOString() }}"
+        }
+      },
+      "id": "GitHub1",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        200
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "filters": {
+          "state": "closed",
+          "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}",
+          "until": "={{ new Date().toISOString() }}"
+        }
+      },
+      "id": "GitHub2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        350
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"repoOwner\"] }}",
+        "repository": "={{ $parameter[\"repoName\"] }}",
+        "filters": {
+          "state": "closed",
+          "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}",
+          "until": "={{ new Date().toISOString() }}",
+          "type": "pr"
+        }
+      },
+      "id": "GitHub3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        500
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+        "options": {
+          "mergeBy": "index"
+        }
+      },
+      "id": "ItemLists1",
+      "name": "Combine Data",
+      "type": "n8n-nodes-base.itemLists",
+      "typeVersion": 2.1,
+      "position": [
+        650,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-3-sonnet-20240229",
+        "messages": {
+          "values": [
+            {
+              "role": "user",
+              "content": "={{ `Generate a narrative summary of the following GitHub activity for the past week. The summary should be in ${$parameter[\"language\"] === \"FR\" ? \"French\" : \"English\"} and include:\n\n1. A brief overview of the week's activity\n2. Highlights of important commits\n3. Summary of closed issues\n4. Summary of merged pull requests\n5. Overall progress and next steps\n\nActivity data:\nCommits: ${JSON.stringify($json[\"commits\"])}\n\nClosed Issues: ${JSON.stringify($json[\"issues\"])}\n\nMerged PRs: ${JSON.stringify($json[\"pulls\"])}\n\nKeep the summary concise but informative.` }}"
+            }
+          ]
+        },
+        "options": {
+          "maxTokens": 1500,
+          "temperature": 0.7
+        }
+      },
+      "id": "AnthropicClaude1",
+      "name": "Generate Summary",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        850,
+        350
+      ],
+      "credentials": {
+        "anthropicApi": "Anthropic API"
+      }
+    },
+    {
+      "parameters": {
+        "sendTo": "={{ $parameter[\"emailRecipient\"] }}",
+        "subject": "=Weekly Development Summary for {{ $parameter[\"repoName\"] }}",
+        "text": "=Hi team,\n\nPlease find below the weekly development summary for the {{ $parameter[\"repoName\"] }} repository.\n\n{{ $json[\"response\"] }}\n\nBest regards,\nn8n Automation"
+      },
+      "id": "Email1",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        350
+      ],
+      "credentials": {
+        "smtp": "SMTP"
+      }
+    },
+    {
+      "parameters": {
+        "httpMethod": "POST",
+        "url": "={{ $parameter[\"webhookUrl\"] }}",
+        "options": {
+          "allowUnauthorizedCerts": true
+        },
+        "headerParametersUi": {
+          "parameter": [
+            {
+              "name": "Content-Type",
+