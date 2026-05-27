```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,1074 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Start",
+      "type": "n8n-nodes-base.manualTrigger",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "weeks",
+              "value": 1
+            }
+          ]
+        }
+      },
+      "id": "2",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        150
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"github_owner\"] }}",
+        "repository": "={{ $parameter[\"github_repo\"] }}",
+        "filters": {
+          "state": "closed",
+          "sort": "updated",
+          "direction": "desc"
+        },
+        "options": {
+          "perPage": 100
+        }
+      },
+      "id": "3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
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
+        "owner": "={{ $parameter[\"github_owner\"] }}",
+        "repository": "={{ $parameter[\"github_repo\"] }}",
+        "filters": {
+          "state": "closed",
+          "sort": "updated",
+          "direction": "desc"
+        },
+        "options": {
+          "perPage": 100
+        }
+      },
+      "id": "4",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        300
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "resource": "commit",
+        "operation": "getAll",
+        "owner": "={{ $parameter[\"github_owner\"] }}",
+        "repository": "={{ $parameter[\"github_repo\"] }}",
+        "filters": {
+          "perPage": 100,
+          "since": "={{ new Date(new Date().setDate(new Date().getDate() - 7)).toISOString() }}"
+        }
+      },
+      "id": "5",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        450
+      ],
+      "credentials": {
+        "githubApi": "GitHub API"
+      }
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "={{ $parameter[\"claude_prompt\"] }}",
+        "maxTokens": 2048,
+        "temperature": 0.5
+      },
+      "id": "6",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        1150,
+        300
+      ],
+      "credentials": {
+        "anthropicApi": "Anthropic API"
+      }
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "title",
+              "value": "={{ $json.title }}"
+            },
+            {
+              "name": "url",
+              "value": "={{ $json.html_url }}"
+            },
+            {
+              "name": "author",
+              "value": "={{ $json.user.login }}"
+            }
+          ]
+        }
+      },
+      "id": "7",
+      "name": "Filter PR Fields",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        700,
+        150
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "title",
+              "value": "={{ $json.title }}"
+            },
+            {
+              "name": "url",
+              "value": "={{ $json.html_url }}"
+            },
+            {
+              "name": "author",
+              "value": "={{ $json.user.login }}"
+            }
+          ]
+        }
+      },
+      "id": "8",
+      "name": "Filter Issue Fields",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        700,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "keepOnlySet": true,
+        "values": {
+          "string": [
+            {
+              "name": "message",
+              "value": "={{ $json.commit.message }}"
+            },
+            {
+              "name": "author",
+              "value": "={{ $json.commit.author.name }}"
+            },
+            {
+              "name": "url",
+              "value": "={{ $json.html_url }}"
+            }
+          ]
+        }
+      },
+      "id": "9",
+      "name": "Filter Commit Fields",
+     