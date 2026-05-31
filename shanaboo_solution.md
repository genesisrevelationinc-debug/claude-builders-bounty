```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1 +1199 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "0",
+      "name": "Start",
+      "type": "n8n-nodes-base.manualTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        390
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": "weeks",
+          "weeks": 1,
+          "dayOfWeek": "5",
+          "hour": 17,
+          "minute": 0
+        }
+      },
+      "id": "1",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        250
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "issues",
+        "repositories": [
+          {
+            "repo": "={{ $parameter[\"repo\"] }}"
+          }
+        ],
+        "returnAll": true,
+        "options": {
+          "sort": "created",
+          "direction": "desc"
+        },
+        "filters": {
+          "state": "closed",
+          "type": "issue"
+        }
+      },
+      "id": "2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        250
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "1",
+          "name": "GitHub"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "commits",
+        "repositories": [
+          {
+            "repo": "={{ $parameter[\"repo\"] }}"
+          }
+        ],
+        "returnAll": true,
+        "options": {
+          "sort": "created",
+          "direction": "desc"
+        }
+      },
+      "id": "3",
+      "name": "Get Recent Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        390
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "1",
+          "name": "GitHub"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "issues",
+        "repositories": [
+          {
+            "repo": "={{ $parameter[\"repo\"] }}"
+          }
+        ],
+        "returnAll": true,
+        "options": {
+          "sort": "created",
+          "direction": "desc"
+        },
+        "filters": {
+          "state": "closed",
+          "type": "pr"
+        }
+      },
+      "id": "4",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        530
+      ],
+      "credentials": {
+        "githubApi": {
+          "id": "1",
+          "name": "GitHub"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $parameter[\"prompt\"] }}",
+        "maxTokens": 1024,
+        "temperature": 0.7
+      },
+      "id": "5",
+      "name": "Call Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        850,
+        390
+      ],
+      "credentials": {
+        "claudeApi": {
+          "id": "1",
+          "name": "Claude"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "subject": "Weekly Development Summary",
+        "toList": [
+          {
+            "email": "={{ $parameter[\"email\"] }}"
+          }
+        ],
+        "text": "={{ $json[\"response\"] }}",
+        "options": {}
+      },
+      "id": "6",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1150,
+        390
+      ],
+      "credentials": {
+        "smtp": {
+          "id": "1",
+          "name": "SMTP"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "method": "POST",
+        "url": "={{ $parameter[\"webhookUrl\"] }}",
+        "options": {
+          "allowUnauthorizedCerts": true
+        },
+        "bodyContentType": "json",
+        "json": "={{ $json[\"response\"] }}",
+        "responseFormat": "json"
+      },
+      "id": "7",
+      "name": "Send to Webhook",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        1150,
+        530
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "repo",
+              "value": "={{ $parameter[\"repo\"] }}"
+            },
+            {
+              "name": "email",
+              "value": "={{ $parameter[\"email\"] }}"
+            },
+            {
+              "name": "webhookUrl",
+              "value": "