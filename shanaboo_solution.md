```diff
--- /dev/null
+++ b/n8n-claude-weekly-summary.json
@@ -0,0 +1,1404 @@
+{
+  "name": "Claude Weekly Dev Summary",
+  "nodes": [
+    {
+      "parameters": {},
+      "id": "1",
+      "name": "Start",
+      "type": "n8n-nodes-base.manualTrigger",
+      "typeVersion": 1,
+      "position": [
+        150,
+        300
+      ],
+      "webhookId": "48395493-1786-41a4-810d-074704257170"
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "searchIssues",
+        "repository": "claude-builders-bounty/claude-builders-bounty",
+        "search": "is:issue is:closed closed:>={{$parameter['closedAfter']}}",
+        "returnAll": true
+      },
+      "id": "2",
+      "name": "Get Closed Issues",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        350,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "search",
+        "repository": "claude-builders-bounty/claude-builders-bounty",
+        "search": "is:pr is:merged merged:>={{$parameter['mergedAfter']}}",
+        "returnAll": true
+      },
+      "id": "3",
+      "name": "Get Merged PRs",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        550,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "commit",
+        "operation": "getAll",
+        "repository": "claude-builders-bounty/claude-builders-bounty",
+        "returnAll": true
+      },
+      "id": "4",
+      "name": "Get Commits",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        750,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "Create a narrative summary of the GitHub activity for the week including:\n\n1. Closed issues:\n\n={$node[\"Get Closed Issues\"].data[\"json\"][\"body\"]}\n\n2. Merged pull requests:\n\n={$node[\"Get Merged PRs\"].data[\"json\"][\"body\"]}\n\n3. Commits:\n\n={$node[\"Get Commits\"].data[\"json\"][\"body\"]}\n\nPlease structure the summary in the following format:\n\n# Weekly Development Summary - Week of\n\n## Highlights\n\n## Issues and Pull Requests\n\n### Closed Issues\n\n### Merged Pull Requests\n\n## Summary\n\n## Next Steps\n\n## Risks and Opportunities\n\nPlease ensure the summary is professional and suitable for a development team's weekly standup meeting.",
+        "system_prompt": "You are a technical writer for a development team's GitHub project. Your role is to summarize the weekly activity to present at the standup meeting.",
+        "max_tokens": 2000,
+        "temperature": 0.7
+      },
+      "id": "5",
+      "name": "Claude API",
+      "type": "n8n-nodes-base.anthropic",
+      "typeVersion": 1,
+      "position": [
+        950,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "search",
+        "operation": "searchIssues",
+        "repository": "claude-builders-bounty/claude-builders-bounty",
+        "search": "is:issue is:closed closed:>={{$parameter['closedAfter']}}",
+        "returnAll": true
+      },
+      "id": "6",
+      "name": "Get Closed Issues (Alternative)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        1150,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "pullRequest",
+        "operation": "search",
+        "repository": "claude-builders-bounty/claude-builders-bounty",
+        "search": "is:pr is:merged merged:>={{$parameter['mergedAfter']}}",
+        "returnAll": true
+      },
+      "id": "7",
+      "name": "Get Merged PRs (Alternative)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        1350,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "resource": "commit",
+        "operation": "getAll",
+        "repository": "claude-builders-bounty/claude-builders-bounty",
+        "returnAll": true
+      },
+      "id": "8",
+      "name": "Get Commits (Alternative)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [
+        1550,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "model": "claude-sonnet-4-20250514",
+        "prompt": "Create a narrative summary of the GitHub activity for the week including closed issues, merged pull requests, and commits. Be sure to highlight the most important changes, and organize the output for a development team's weekly standup meeting.",
+        "system_prompt": "You are a technical writer for a development team's GitHub project. Your role is to summarize the weekly activity to present at the standup meeting.",
+        "max_tokens": 2000,
