```diff
--- /dev/null
+++ b/claude-weekly-dev-summary.json
@@ -0,0 +1,700 @@
+{
+  "name": "Claude Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "Schedule",
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
+        "resource": "get",
+        "owner": "={ { $json[\"repo_owner\"] } }",
+        "repo": "={ { $json[\"repo_name\"] } }",
+        "fieldSelectors": [
+          {
+            "field": "commits",
+            "active": true,
+            "operation": "searchCommits",
+            "parameters": {
+              "since": "={ { $json[\"since\"] } }",
+              "until": "={ { $json[\"until\"] } }"
+            }
+          },
+          {
+            "field": "pulls",
+            "active": true,
+            "operation": "getAll",
+            "parameters": {
+              "state": "closed",
+              "sort": "updated",
+              "direction": "desc"
+            }
+          },
+          {
+            "field": "issues",
+            "active": true,
+            "operation": "getAll",
+            "parameters": {
+              "state": "closed",
+              "sort": "updated",
+              "direction": "desc"
+            }
+          }
+        ]
+      },
+      "id": "GitHub",
+      "name": "GitHub",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-3-sonnet-4-20250514",
+        "options": {
+          "maxTokens": 4000,
+          "temperature": 0.7,
+          "topP": 1,
+          "topK": 5
+        },
+        "system_prompt": "={ { $json[\"system_prompt\"] } }",
+        "messages": "=[ {\"role\": \"user\", \"content\": \"={ { $json[\"prompt\"] } }\"} ]",
+        "responseProperty": "claude_response"
+      },
+      "id": "Claude_API",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "subject": "={ { $json[\"email_subject\"] } }",
+        "to": "={ { $json[\"email_to\"] } }",
+        "body": "={ { $json[\"email_body\"] } }"
+      },
+      "id": "Send_Email",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1150,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "repo_owner",
+              "value": "claude-builders-bounty"
+            },
+            {
+              "name": "repo_name",
+              "value": "claude-builders-bounty"
+            },
+            "name": "system_prompt",
+              "value": "You are a helpful assistant that summarizes weekly development activity in a clear, concise, and well-structured way. Please create a summary of the development activity for the week based on the GitHub data provided. Organize it in a narrative format with clear sections for commits, issues, and pull requests. Highlight key changes and contributions."
+            },
+            {
+              "name": "email_to",
+              "value": "team@example.com"
+            },
+            {
+              "name": "email_subject",
+              "value": "Weekly Development Summary - {{new Date().toISOString().split('T')[0]}}"
+            }
+          ]
+        }
+      },
+      "id": "Set",
+      "name": "Set",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        400,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "since",
+              "value": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0] }}"
+            },
+            {
+              "name": "until",
+              "value": "={{ new Date().toISOString().split('T')[0] }}"
+            }
+          ]
+        }
+      },
+      "id": "Date_Helper",
+      "name": "Date Helper",
+      "type": "n8n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+      550,
+      150
+      ]
+    },
+    {
+      "parameters": {
+        "values": {
+          "string": [
+            {
+              "name": "prompt",
+              "value": "Please summarize the following development activity for the week:\n\nCommits:\n{{ $json[\"commits\"] }}\n\nIssues:\n{{ $json[\"issues\"] }}\n\nPull Requests:\n{{ $json[\"pulls\"] }}\n\nCreate a narrative summary organized by category with key highlights and statistics."
+            }
+          ]
+        }
+      },
+      "id": "Prompt_Builder",
+      "name": "Prompt Builder",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        700,
+        300
+      ]
+    },
+    {
+      "parameters