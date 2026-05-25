```diff
--- /dev/null
+++ b/weekly-dev-summary.json
@@ -0,0 +1,656 @@
+{
+  "name": "Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "0",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        100,
+        300
+      ],
+      "data": {
+        "cronExpression": "0 0 17 * * 5"
+      }
+    },
+    {
+      "parameters": {
+        "httpMethod": "get",
+        "url": "https://api.github.com/repos/{{ $json['repo'] }}/commits",
+        "headers": {
+          "User-Agent": "n8n/claude-weekly-summary"
+        },
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      },
+      "id": "1",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        300,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      },
+      "id": "2",
+      "name": "GitHub Issues",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        500,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      },
+      "id": "3",
+      "name": "GitHub Pull Requests",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        700,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      },
+      "id": "4",
+      "name": "Combine Data",
+      "type": "n8n-nodes-base.merge",
+      "typeVersion": 1,
+      "position": [
+        900,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      },
+      "id": "5",
+      "name": "Format Data",
+      "type": "n8n-nodes-base.code",
+      "typeVersion": 1,
+      "position": [
+        1100,
+        300
+      ],
+      "code": "const formattedData = {\n  repo: $input.first().json.repo,\n  language: $input.first().json.language,\n  since: $input.first().json.since,\n  until: $input.first().json.until\n};\n\nreturn [{ json: formattedData }];"
+    },
+    {
+      "parameters": {
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      },
+      "id": "6",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.claude",
+      "typeVersion": 1,
+      "position": [
+        1300,
+        300
+      ],
+      "parameters": {
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      }
+    },
+    {
+      "parameters": {
+        "options": {
+          "redirect": {
+            "redirect": {
+              "redirect": "redirect"
+            }
+          }
+        }
+      },
+      "id": "7",
+      "name": "Send Summary",
+      "type": "n8n-nodes-base.emailSend",
+      "typeVersion": 1,
+      "position": [
+        1500,
+        300
+      ]
+    }
+  ],
+  "connections": {
+    "Cron": {
+      "main": [
+        [
+          {
+            "node": "GitHub Commits",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "GitHub Commits": {
+      "main": [
+        [
+          {
+            "node": "GitHub Issues",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "GitHub Issues": {
+      "main": [
+        [
+          {
+            "node": "GitHub Pull Requests",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "GitHub Pull Requests": {
+      "main": [
+        [
+          {
+            "node": "Combine Data",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Combine Data": {
+      "main": [
+        [
+          {
+            "node": "Format Data",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Format Data": {
+      "main": [
+        [
+          {
+            "node": "Claude API",
+            "type": "main",
+            "index": 0
+          }
+        ]
+      ]
+    },
+    "Claude API": {
+      "main": [
+        [
+          {
+            "node": "Send Summary