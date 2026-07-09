```diff
--- a/README.md
+++ b/README.md
@@ -1,6 +1,6 @@
 # Claude Builders Bounty 🤖
 
-> A community bounty board for Claude Code builders.
+> A community bounty board for Claude Code builders — with automated weekly dev summaries.
 
 Building with Claude Code? Have tasks to delegate?
 Want to get paid for contributing to AI projects?
@@ -39,6 +39,16 @@
 
 ---
 
+## Weekly Dev Summary Workflow
+
+This repo includes an n8n workflow that automatically generates a weekly narrative summary of repo activity using the Claude API.
+
+**Quick setup (5 steps):**
+1. Import `workflows/weekly-dev-summary.json` into your n8n instance
+2. Set the `GitHub Repo`, `Destination Webhook URL`, and `Language` variables in the workflow
+3. Configure your GitHub and Anthropic API credentials in n8n
+4. Activate the workflow — it runs every Friday at 5pm UTC
+5. Receive a beautifully formatted narrative summary via Discord/Slack webhook
+
 ## Community
 
 - 🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
--- /dev/null
+++ b/workflows/weekly-dev-summary.json
@@ -0,0 +1,345 @@
+{
+  "name": "Weekly Dev Summary — Claude API",
+  "nodes": [
+    {
+      "parameters": {
+        "rule": {
+          "interval": [
+            {
+              "field": "cronExpression",
+              "expression": "0 17 * * 5"
+            }
+          ]
+        }
+      },
+      "id": "cron-trigger",
+      "name": "Friday 5pm Cron",
+      "type": "n8n-nodes-base.scheduleTrigger",
+      "typeVersion": 1.1,
+      "position": [250, 300]
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $env.GITHUB_REPO_OWNER }}",
+        "repository": "={{ $env.GITHUB_REPO_NAME }}",
+        "returnAll": true,
+        "options": {
+          "since": "={{ $now.minus({ days: 7 }).toISO() }}"
+        }
+      },
+      "id": "fetch-commits",
+      "name": "Fetch Commits (7 days)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [450, 200],
+      "credentials": {
+        "githubApi": {
+          "id": "1",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $env.GITHUB_REPO_OWNER }}",
+        "repository": "={{ $env.GITHUB_REPO_NAME }}",
+        "returnAll": true,
+        "options": {
+          "state": "closed",
+          "since": "={{ $now.minus({ days: 7 }).toISO() }}"
+        }
+      },
+      "id": "fetch-issues",
+      "name": "Fetch Closed Issues (7 days)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [450, 400],
+      "credentials": {
+        "githubApi": {
+          "id": "1",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "operation": "getAll",
+        "owner": "={{ $env.GITHUB_REPO_OWNER }}",
+        "repository": "={{ $env.GITHUB_REPO_NAME }}",
+        "returnAll": true,
+        "options": {
+          "state": "closed",
+          "sort": "updated",
+          "direction": "desc"
+        }
+      },
+      "id": "fetch-prs",
+      "name": "Fetch Merged PRs (7 days)",
+      "type": "n8n-nodes-base.github",
+      "typeVersion": 1,
+      "position": [450, 600],
+      "credentials": {
+        "githubApi": {
+          "id": "1",
+          "name": "GitHub API"
+        }
+      }
+    },
+    {
+      "parameters": {
+        "jsCode": "// ── Aggregate GitHub data ──────────────────────────────────────────\nconst commits = $input.all()[0].json;\nconst issues = $input.all()[1].json;\nconst prs = $input.all()[2].json;\n\nconst now = new Date();\nconst weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);\n\n// Filter commits within the last 7 days\nconst recentCommits = commits.filter(c => {\n  const d = c.commit?.author?.date || c.commit?.committer?.date;\n  return d && new Date(d) >= weekAgo;\n});\n\n// Filter issues closed within the last 7 days\nconst recentIssues = issues.filter(i => {\n  return i.closed_at && new Date(i.closed_at) >= weekAgo;\n});\n\n// Filter PRs merged within the last 7 days\nconst recentPRs = prs.filter(p => {\n  return p.merged_at && new Date(p.merged_at) >= weekAgo;\n});\n\n// Build a structured summary object\nconst summary = {\n  repo: `${$env.GITHUB_REPO_OWNER}/${$env.GITHUB_REPO_NAME}`,\n  weekStart: weekAgo.toISOString().split('T')[0],\n  weekEnd: now.toISOString().split('T')[0],\n  totalCommits: recentCommits.length,\n  totalIssuesClosed: recentIssues.length,\n  totalPRsMerged: recentPRs.length,\n  commits: recentCommits.slice(0, 20).map(c => ({\n    message: c.commit.message.split('\\n')[0],\n    author: c.commit.author?.name || c.author?.login || 'unknown',\n    date: c.commit.author?.date || c.commit.committer?.date\n  })),\n  issues: recentIssues.slice(0, 20).map(i => ({\n   