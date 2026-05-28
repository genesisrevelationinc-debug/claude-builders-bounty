```diff
--- /dev/null
+++ b/n8n-workflow.json
@@ -0,0 +1,1059 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "04694bc6-8d10-41e7-8a44-20d4701ad017",
+      "name": "Start",
+      "type": "n8n-nodes-base.manualTrigger",
+      "typeVersion": 1,
+      "position": [
+        340,
+        340
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "weekday": "5",
+          "hour": 17
+        }
+      },
+      "id": "a1b2c3d4-5678-90ab-cdef-1234567890ab",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1.1,
+      "position": [
+        340,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "httpMethod": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/commits",
+        "options": {
+          "queryParameters": {
+            "parameters": [
+              {
+                "name": "since",
+                "value": "={{$parameter[\"startDate\"]}}"
+              },
+              {
+                "name": "until",
+                "value": "={{$parameter[\"endDate\"]}}"
+              }
+            ]
+          }
+        },
+        "headerParametersJson": "={\"Authorization\": \"Bearer {{$parameter[\"githubToken\"]}}\"}"
+      },
+      "id": "b2c3d4e5-6789-01ab-cdef-2345678901bc",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.2,
+      "position": [
+        600,
+        100
+      ]
+    },
+    {
+      "parameters": {
+        "httpMethod": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/issues",
+        "options": {
+          "queryParameters": {
+            "parameters": [
+              {
+                "name": "state",
+                "value": "closed"
+              },
+              {
+                "name": "since",
+                "value": "={{$parameter[\"startDate\"]}}"
+              }
+            ]
+          }
+        },
+        "headerParametersJson": "={\"Authorization\": \"Bearer {{$parameter[\"githubToken\"]}}\"}"
+      },
+      "id": "c3d4e5f6-7890-12ab-cdef-3456789012cd",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.2,
+      "position": [
+        600,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "httpMethod": "GET",
+        "url": "=https://api.github.com/repos/{{$parameter[\"repoOwner\"]}}/{{$parameter[\"repoName\"]}}/pulls",
+        "options": {
+          "queryParameters": {
+            "parameters": [
+              {
+                "name": "state",
+                "value": "closed"
+              },
+              {
+                "name": "sort",
+                "value": "updated"
+              },
+              {
+                "name": "direction",
+                "value": "desc"
+              }
+            ]
+          }
+        },
+        "headerParametersJson": "={\"Authorization\": \"Bearer {{$parameter[\"githubToken\"]}}\"}"
+      },
+      "id": "d4e5f6g7-8901-23ab-cdef-4567890123de",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 4.2,
+      "position": [
+        600,
+        400
+      ]
+    },
+    {
+      "parameters": {
+        "content": "={{$json}}"
+      },
+      "id": "e5f6g7h8-9012-34ab-cdef-5678901234ef",
+      "name": "Set Dates",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 3.2,
+      "position": [
+        460,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{$parameter[\"prompt\"]}}",
+        "systemPrompt": "={{$parameter[\"systemPrompt\"]}}",
+        "maxTokens": 2048,
+        "temperature": 0.7
+      },
+      "id": "f6g7h8i9-0123-45ab-cdef-6789012345fg",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1.1,
+      "position": [
+        900,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{$parameter[\"fromEmail\"]}}",
+        "toEmail": "={{$parameter[\"toEmail\"]}}",
+        "subject": "={{$parameter[\"subject\"]}}",
+        "text": "={{$parameter[\"text\"]}}"
+      },
+      "id": "g7h8i9j0-1234-56ab-cdef-