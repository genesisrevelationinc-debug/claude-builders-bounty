```diff
--- /dev/null
+++ b/n8n-claude-weekly-summary.json
@@ -0,0 +1,1156 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "Cron",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "url": "https://api.github.com/repos/{{ $node['Set'].parameter['repoOwner'] }}/{{ $node['Set'].parameter['repoName'] }}/commits",
+        "options": {
+          "redirect": {
+            "follow": true
+          }
+        }
+      },
+      "id": "GitHub Commits",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "url": "https://api.github.com/repos/{{ $node['Set'].parameter['repoOwner'] }}/{{ $node['Set'].parameter['repoName'] }}/issues",
+        "options": {
+          "redirect": {
+            "follow": true
+          }
+        }
+      },
+      "id": "GitHub Issues",
+      "name": "GitHub Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        450,
+        450
+      ]
+    },
+    {
+      "parameters": {
+        "url": "https://api.github.com/repos/{{ $node['Set'].parameter['repoOwner'] }}/{{ $node['Set'].parameter['repoName'] }}/pulls",
+        "options": {
+          "redirect": {
+            "follow": true
+          }
+        }
+      },
+      "id": "GitHub Pull Requests",
+      "name": "GitHub Pull Requests",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        450,
+        600
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "merge",
+        "parameters": {
+          "commit": {
+            "sha": "={{ $node['GitHub Commits'].data }}",
+            "message": "={{ $node['Set'].parameter['summaryPrompt'] }}",
+            "author": {
+              "name": "={{ $node['Set'].parameter['repoOwner'] }}",
+              "email": "={{ $node['Set'].parameter['repoEmail'] }}"
+            }
+          }
+        }
+      },
+      "id": "Merge Data",
+      "name": "Merge Data",
+      "type": "n8n-nodes-base.merge",
+      "typeVersion": 1,
+      "position": [
+        650,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "transform",
+        "parameters": {
+          "commit": {
+            "sha": "={{ $node['GitHub Commits'].data }}",
+        }
+      },
+      "id": "Transform Data",
+      "name": "Transform Data",
+      "type": "n8n-nodes-base.transform",
+      "typeVersion": 1,
+      "position": [
+        850,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "set",
+        "parameters": {
+          "commit": {
+            "sha": "={{ $node['GitHub Commits'].data }}",
+            "message": "={{ $node['Set'].parameter['summaryPrompt'] }}",
+            "author": {
+              "name": "={{ $node['Set'].parameter['repoOwner'] }}",
+              "email": "={{ $node['Set'].parameter['repoEmail'] }}"
+            }
+          }
+        }
+      },
+      "id": "Set",
+      "name": "Set",
+      "type": "n8n-nodes-base.set",
+      "typeVersion": 1,
+      "position": [
+        1050,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "http",
+        "parameters": {
+          "commit": {
+            "sha": "={{ $node['GitHub Commits'].data }}",
+            "message": "={{ $node['Set'].parameter['summaryPrompt'] }}",
+            "author": {
+              "name": "={{ $node['Set'].parameter['repoOwner'] }}",
+              "email": "={{ $node['Set'].parameter['repoEmail'] }}"
+            }
+          }
+        }
+      },
+      "id": "HTTP Request",
+      "name": "HTTP Request",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        1250,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "claude",
+        "parameters": {
+          "commit": {
+            "sha": "={{ $node['GitHub Commits'].data }}",
+            "message": "={{ $node['Set'].parameter['summaryPrompt'] }}",
+            "author": {
+              "name": "={{ $node['Set'].parameter['repoOwner'] }}",
+              "email": "={{ $node['Set'].parameter['repoEmail'] }}"
+            }
+          }
+        }
+      },
+      "id": "Claude API",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        1450,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "operation": "email",
+        "parameters": {
+          "commit": {
+            "sha": "={{ $node['GitHub Commits'].data }}",
+            "message": "={{ $node['Set'].parameter['summaryPrompt