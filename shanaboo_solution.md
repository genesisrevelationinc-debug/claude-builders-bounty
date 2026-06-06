```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1000 @@
+{
+  "name": "Claude Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "Schedule1",
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
+        "rule": {
+        "interval": "everyWeek",
+        "days": "friday",
+        "at": "17:00"
+      }
+      },
+      "id": "Schedule2",
+      "name": "Weekly Trigger",
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
+        "url": "https://api.github.com/repos/{{$parameter[\"repo\"]}}/commits",
+        "authentication": "oAuth2",
+        "oAuth2Opts": {
+          "grantType": "clientCredentials",
+          "accessTokenUrl": "https://github.com/login/oauth/access_token",
+          "clientId": "={{ $parameter[\"githubClientId\"] }}",
+          "clientSecret": "={{ $parameter[\"githubClientSecret\"] }}",
+          "scope": "repo"
+        },
+        "options": {
+          "queryParameters": {
+            "since": "={{ $parameter[\"since\"] }}",
+            "until": "={{ $parameter[\"until\"] }}"
+          }
+        }
+      },
+      "id": "GitHub1",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        650,
+        200
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{$parameter[\"repo\"]}}/issues",
+        "authentication": "oAuth2",
+        "oAuth2Opts": {
+          "grantType": "clientCredentials",
+          "accessTokenUrl": "https://github.com/login/oauth/access_token",
+          "clientId": "={{ $parameter[\"githubClientId\"] }}",
+          "clientSecret": "={{ $parameter[\"githubClientSecret\"] }}",
+          "scope": "repo"
+        },
+        "options": {
+          "queryParameters": {
+            "state": "closed",
+            "since": "={{ $parameter[\"since\"] }}"
+          }
+        }
+      },
+      "id": "GitHub2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        650,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{$parameter[\"repo\"]}}/pulls",
+        "authentication": "oAuth2",
+        "oAuth2Opts": {
+          "grantType": "clientCredentials",
+          "accessTokenUrl": "https://github.com/login/oauth/access_token",
+          "clientId": "={{ $parameter[\"githubClientId\"] }}",
+          "clientSecret": "={{ $parameter[\"githubClientSecret\"] }}",
+          "scope": "repo"
+        },
+        "options": {
+          "queryParameters": {
+            "state": "closed",
+            "sort": "updated",
+            "direction": "desc"
+          }
+        }
+      },
+      "id": "GitHub3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        650,
+        500
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $parameter[\"prompt\"] }}",
+        "max_tokens": 1024,
+        "temperature": 0.7
+      },
+      "id": "Claude1",
+      "name": "Generate Summary",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        850,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "fromEmail": "={{ $parameter[\"fromEmail\"] }}",
+        "toEmail": "={{ $parameter[\"toEmail\"] }}",
+        "subject": "={{ $parameter[\"subject\"] }}",
+        "text": "={{ $parameter[\"text\"] }}",
+        "html": "={{ $parameter[\"html\"] }}",
+        "attachments": "={{ $parameter[\"attachments\"] }}"
+      },
+      "id": "Email1",
+      "name": "Send Email",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        350
+      ]
+    },
+    {
+      "parameters": {
+        "values": {
+          "repo": "={{ $parameter[\"repo\"] }}",
+          "since": "={{ $parameter[\"since\"] }}",
+          "until": "={{ $parameter[\"until\"] }}",
+          "githubClientId": "={{ $parameter[\"githubClientId\"] }}",
+          "githubClientSecret": "={{ $parameter[\"githubClientSecret\"] }}",
+          "fromEmail": "={{ $parameter[\"fromEmail\"] }}",
+          "toEmail": "={{ $parameter[\"toEmail\"] }}",
+          "subject": "={{ $parameter[\"subject\"] }}",
+          "text": "={{ $parameter[\"text\"] }}",
+          "html": "={{ $parameter[\"html\"] }}",
+          "attachments": "={{ $parameter[\"attachments\"] }}",
+          "prompt": "={{ $parameter[\"