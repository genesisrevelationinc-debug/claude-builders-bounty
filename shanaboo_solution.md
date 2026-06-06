```diff
--- /dev/null
+++ b/claude-weekly-summary.json
@@ -1,0 +1,1009 @@
+{
+  "name": "Claude Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "f881e248-270a-404d-b4ed-9d90d4e31c3c",
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
+        "resource": "repository",
+        "owner": "={{ $json[\"github_owner\"] }}",
+        "repository": "={{ $json[\"github_repo\"] }}",
+        "filePath": "={{ $json[\"github_token\"] }}",
+        "branch": "={{ $json[\"github_branch\"] }}",
+        "fileContent": "={{ $json[\"github_file_content\"] }}",
+        "commitMessage": "={{ $json[\"github_commit_message\"] }}",
+        "additionalFields": {
+          "state": "all",
+          "since": "={{ $json[\"since_date\"] }}",
+          "until": "={{ $json[\"until_date\"] }}",
+          "per_page": 100
+        }
+      },
+      "id": "4f3b2c9f-8a1b-4c2d-9d8e-0a1b2c3d4e5f",
+      "name": "GitHub",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json[\"claude_prompt\"] }}",
+        "maxTokens": 1024,
+        "temperature": 0.7
+      },
+      "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
+      "name": "Claude",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "send": true,
+        "email": "={{ $json[\"email\"] }}",
+        "subject": "={{ $json[\"subject\"] }}",
+        "text": "={{ $json[\"text\"] }}",
+        "options": {
+          "allowMissingCredentials": false
+        }
+      },
+      "id": "b2c3d4e5-f6a7-8901-2345-678901abcdef",
+      "name": "Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "mode": "runOnce",
+        "options": {
+          "responsePropertyName": "data"
+        }
+      },
+      "id": "c3d4e5f6-7890-1234-5678-901234567890",
+      "name": "Set",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "responsePropertyName": "data"
+        }
+      },
+      "id": "d4e5f6a7-8901-2345-6789-012345678901",
+      "name": "Function",
+      "type": "n80n-nodes-base.function",
+      "typeVersion": 1,
+      "position": [
+        750,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "url": "={{ $json[\"webhook_url\"] }}",
+        "method": "POST",
+        "fieldToCheck": "={{ $json[\"field_to_check\"] }}",
+        "options": {
+          "responsePropertyName": "data"
+        }
+      },
+      "id": "e5f6a7b8-9012-3456-7890-123456789012",
+      "name": "Webhook",
+      "type": "n8n-nodes-base.webhook",
+      "typeVersion": 1,
+      "position": [
+        950,
+        300
+      ]
+    }
+  ],
+  "pinData": {},
+  "connections": {
+    "Start": {
+      "main": [
+        [
+          {
+            "node": "GitHub",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "GitHub": {
+      "main": [
+        [
+          {
+            "node": "Set",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Set": {
+      "main": [
+        [
+          {
+            "node": "Claude",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Claude": {
+      "main": [
+        [
+          {
+            "node": "Email",
+            "type": "main",
+            "index": 0
+          },
+          {
+            "node": "Webhook",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    }
