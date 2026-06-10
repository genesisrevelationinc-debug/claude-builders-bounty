```diff
--- /dev/null
+++ b/n8n-workflow-dev-summary.json
@@ -0,0 +1,1399 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "cronExpression",
+              "value": "0 17 * * 5"
+            }
+          ]
+        }
+      },
+      "id": "0",
+      "name": "Schedule Trigger",
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
+        "path": "={{ $parameter[\"githubToken\"] }}",
+        "branch": "={{ $parameter[\"repoBranch\"] }}",
+        "commits": {
+          "range": "lastWeek"
+        },
+        "issues": {
+          "state": "closed",
+          "range": "lastWeek"
+        },
+        "pullRequests": {
+          "state": "closed",
+          "range": "lastWeek"
+          }
+      },
+      "id": "1",
+      "name": "Get Repository Data",
+      "type": "custom-nodes.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "httpMethod": "POST",
+        "url": "https://api.anthropic.com/v1/messages",
+        "authentication": "headerAuth",
+        "headers": {
+          "header": [
+            {
+              "name": "anthropic-version",
+              "value": "2023-06-01"
+            },
+            {
+              "name": "content-type",
+              "value": "application/json"
+            }
+          ]
+        },
+        "sendBody": true,
+        "body": {
+          "model": "claude-3-sonnet-20250514",
+          "max_tokens": 1024,
+          "messages": [
+            {
+              "role": "user",
+              "content": "={{ $parameter[\"prompt\"] }}"
+            }
+          ]
+        }
+      },
+      "id": "2",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "sendTo": "={{ $parameter[\"email\"] }}",
+        "subject": "={{ $parameter[\"emailSubject\"] }}",
+        "text": "={{ $json[\"response\"] }}"
+      },
+      "id": "3",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-3-sonnet-20250514",
+        "maxTokens": 1024,
+        "system": "={{ $parameter[\"systemPrompt\"] }}",
+        "prompt": "={{ $parameter[\"userPrompt\"] }}",
+        "options": {}
+      },
+      "id": "4",
+      "name": "Claude Sonnet 4",
+      "type": "nodes-claude.claude",
+      "typeVersion": 1,
+      "position": [
+        650,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "repoOwner",
+              "value": "claude-builders-bounty"
+            },
+            {
+              "name": "repoName",
+              "value": "claude-builders-bounty"
+            },
+            {
+              "name": "githubToken",
+              "value": "your-github-token"
+            },
+            {
+              "name": "claudeKey",
+              "value": "your-claude-api-key"
+            },
+            {
+              "name": "email",
+              "value": "user@example.com"
+            },
+            {
+              "name": "repoBranch",
+              "value": "main"
+            },
+            {
+              "name": "language",
+              "value": "EN"
+            }
+          ]
+        }
+      },
+      "id": "5",
+      "name": "Configuration",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        250,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "keepOnlySet": true
+        },
+        "set": {
+          "entries": [
+            {
+              "name": "repoOwner",
+              "value": "={{ $parameter[\"repoOwner\"] }}",
+              "type": "string"
+            },
+            {
+              "name": "repoName", 
+              "value": "={{ $parameter[\"repoName\"] }}",
+              "type": "string"
+            },
+            {
+              "name": "repoBranch",
+              "value": "={{ $parameter[\"repoBranch\"] }}",
+              "type": "string"
+            },
+            {
+              "name": "language",
+              "value": "={{ $parameter[\"language\"] }}",
+              "type": "string"
+            }
+          ]
+        }
+      },
+      "id": "6",
+      "name": "Set Variables",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        450,
+        500
+      ]
+    },
