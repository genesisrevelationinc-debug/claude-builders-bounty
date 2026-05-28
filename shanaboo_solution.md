```diff
--- a/README.md
+++ b/README.md
@@ -1,30 +1,3 @@ README.md
-# Claude Builders Bounty 🤖
-
-> A community bounty board for Claude Code builders.
-
-Building with Claude Code? Have tasks to delegate?
-Want to get paid for contributing to AI projects?
-You're in the right place.
-
----
-
-## How it works
-
-**To post a bounty**
-1. Open a GitHub issue with a clear description and acceptance criteria
-2. Comment `/opire create $XXX` in the issue to set the reward
-3. Share the link — contributors will find it
-
-**To claim a bounty**
-1. Browse the open issues below
-2. Comment `/opire try` in the issue you want to work on
-3. Submit a PR — payment is automatic on merge ✅
-
----
-
-## Active Bounties
-
-| # | Task | Amount | Status |
-|---|------|--------|--------|
-| [#1](../../issues/1) | SKILL: Generate a CHANGELOG from git history | $50 | 🟢 Open |
-| [#2](../../issues/2) | TEMPLATE: CLAUDE.md for a Next.js + SQLite project | $75 | 🟢 Open |
-| [#3](../../issues/3) | HOOK: Block destructive bash commands in Claude Code | $100 | 🟢 Open |
-| [#4](../../issues/4) | AGENT: PR reviewer with structured Markdown output | $150 | 🟢 Open |
-| [#5](../../issues/5) | WORKFLOW: n8n + Claude API — automated weekly dev summary | $200 | 🟢 Open |
-
-## Rules
-
-- Tasks must be related to Claude Code or AI tooling
-- Every issue must have clear acceptance criteria before a bounty is activated
-- Payment is handled by [Opire](https://opire.dev) (Stripe)
-- Quality over speed — a solid PR beats a fast one
-
-## Community
-
-🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
-📧 Contact: claudebounty@gmail.com
-
-*Started by the Claude builder community · March 2026 · MIT License*
+{
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": "5",
+          "unit": "minutes"
+        }
+      },
+      "id": "1",
+      "name": "Cron",
+      "type": "n8n-nodes-base.cron",
+      "typeVersion": 1,
+      "position": [
+        420,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{ $json.githubRepo }}/commits",
+        "options": {
+          "responseFormat": "json",
+          "queryParameters": {
+            "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+            "until": "={{ new Date().toISOString() }}",
+            "per_page": 100
+          }
+        }
+      },
+      "id": "2",
+      "name": "GitHub Commits",
+      "type": "n8n-nodes-base.httpRequest",
+      "typeVersion": 1,
+      "position": [
+        580,
+        300
+      ]
+    },
+    {
+      "parameters": {
+        "method": "GET",
+        "url": "https://api.github.com/repos/{{ $json.githubRepo }}/issues",
+        "options": {
+          "responseFormat": "json",
+          "queryParameters": {
+            "state": "closed",
+            "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+            "per_page": 100
+          }
+        }
+      },
+      "id": "3",
+        "name": "GitHub Issues",
+        "type": "n8n-nodes-base.httpRequest",
+        "typeVersion": 1,
+        "position": [
+          740,
+          300
+        ]
+      },
+      {
+        "parameters": {
+          "method": "GET",
+          "url": "https://api.github.com/repos/{{ $json.githubRepo }}/pulls",
+          "options": {
+            "responseFormat": "json",
+            "queryParameters": {
+              "state": "closed",
+              "since": "={{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}",
+              "per_page": 100
+            }
+          }
+        },
+        "id": "4",
+        "name": "GitHub Pull Requests",
+        "type": "n8n-nodes-base.httpRequest",
+        "typeVersion": 1,
+        "position": [
+          900,
+          300
+        ]
+      },
+      {
+        "parameters": {
+          "model": "claude-sonnet-4-20250514",
+          "messages": [
+            {
+              "role": "user",
+              "content": "Create a summary of the following GitHub activity:\n\nCommits: {{ $json.commits }}\n\nIssues: {{ $json.issues }}\n\nPRs: {{ $json.prs }}"
+            }
+          ],
+          "maxTokens": 1000
+        },
+        "id": "5",
+        "name": "Claude API",
+        "type": "n8n-nodes-base.anthropic",
+        "typeVersion": 1,
+        "position": [
+          1060,
+          300
+        ]
+      },
+      {
+        "parameters": {
+          "subject": "=Weekly GitHub Summary for {{ $json.githubRepo }}",
+          "to": "={{ $json.email }}",
+          "text": "={{ $json.claudeResponse }}",
+          "contentType": "text"
+        },
+        "id": "6",
+        "name": "Email",
+        "type": "n8n-nodes-base.emailSend",
+        "typeVersion": 1,
