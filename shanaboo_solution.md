```diff
--- /dev/null
+++ b/n8n-weekly-dev-summary.json
@@ -1 +1,1079 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Start",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ],
+      "webhookId": "7a1f8c2c-434a-4b2e-8e7f-3987d1e1a851"
+    },
+    {
+      "parameters": {
+        "resource": "issues",
+        "owner": "={{ $json.github_repo_owner }}",
+        "repository": "={{ $json.github_repo_name }}",
+        "authentication": "={{ $json.github_auth_type }}",
+        "personalAccessToken": "={{ $json.github_token }}",
+        "filters": {
+          "state": "closed",
+          "sort": "updated",
+          "direction": "desc",
+          "since": "={{ $json.since_date }}",
+          "until": "={{ $json.until_date }}"
+        }
+      },
+      "id": "2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ],
+      "credentials": {
+        "githubApi": "={{ $json.github_credential }}"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "pulls",
+        "owner": "={{ $json.github_repo_owner }}",
+        "repository": "={{ $json.github_repo_name }}",
+        "authentication": "={{ $json.github_auth_type }}",
+        "personalAccessToken": "={{ $json.github_token }}",
+        "filters": {
+          "state": "closed",
+          "sort": "updated",
+          "direction": "desc",
+          "base": "={{ $json.github_branch }}",
+          "since": "={{ $json.since_date }}",
+          "until": "={{ $json.until_date }}"
+        }
+      },
+      "id": "3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        450
+      ],
+      "credentials": {
+        "githubApi": "={{ $json.github_credential }}"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "commits",
+        "owner": "={{ $json.github_repo_owner }}",
+        "repository": "={{ $json.github_repo_name }}",
+        "authentication": "={{ $json.github_auth_type }}",
+        "personalAccessToken": "={{ $json.github_token }}",
+        "filters": {
+          "since": "={{ $json.since_date }}",
+          "until": "={{ $json.until_date }}",
+          "path": "={{ $json.github_path }}",
+          "author": "={{ $json.github_author }}",
+          "sha": "={{ $json.github_branch }}"
+        }
+      },
+      "id": "4",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        450,
+        600
+      ],
+      "credentials": {
+        "githubApi": "={{ $json.github_credential }}"
+      }
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+        "inputData": "={{ $json.github_data }}",
+        "options": {
+          "mergeBy": "index",
+          "outputFormat": "unpairedItem"
+        }
+      },
+      "id": "5",
+      "name": "Merge Data",
+      "type": "n8n-nodes-base.merge",
+      "typeVersion": 1,
+      "position": [
+        650,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "mode": "combine",
+      },
+      "id": "6",
+      "name": "Merge All Data",
+      "type": "n8n-nodes-base.merge",
+      "typeVersion": 1,
+      "position": [
+        850,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $json.claude_prompt }}",
+        "system": "={{ $json.claude_system_prompt }}",
+        "max_tokens": "={{ $json.claude_max_tokens }}",
+        "temperature": "={{ $json.claude_temperature }}",
+        "stop_sequences": "={{ $json.claude_stop_sequences }}",
+        "top_p": "={{ $json.claude_top_p }}",
+        "top_k": "={{ $json.claude_top_k }}",
+        "anthropic-version": "={{ $json.claude_version }}",
+        "anthropic-api-key": "={{ $json.claude_api_key }}"
+      },
+      "id": "7",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        450
+      ],
+      "credentials": {
+        "claudeApi": "={{ $json.claude_credential }}"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "users",
+        "owner": "={{ $json.github_repo_owner }}",
+        "repository": "={{ $json.github_repo_name }}",
+        "authentication": "={{ $json.github_auth_type }}",
+        "personalAccessToken": "={{ $json.github_token }}",
+        "filters": {
+          "since": "={{ $json.since_date }}",
+          "until": "={{ $json.until_date }}"
+        }
+      },
+      "id": "8",
+      "name": "Get Contributors",
+