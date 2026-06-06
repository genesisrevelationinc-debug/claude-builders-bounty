# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click **Add Workflow** → **Import from File** → select `weekly-dev-summary.json`

2. **Set credentials**: Create credentials for:
   - **GitHub API** (personal access token with `repo` scope)
   - **Claude API** (Anthropic API key from [console.anthropic.com](https://console.anthropic.com))

3. **Configure variables**: Open the workflow settings and set:
   - `githubRepo` — target repository (e.g., `owner/repo-name`)
   - `webhookUrl` — Discord/Slack webhook URL for delivery
   - `language` — `EN` or `FR`

4. **Activate the workflow**: Toggle the workflow to **Active** — it runs automatically every Friday at 5 PM

5. **Test it**: Click **Execute Workflow** to run manually and verify the output in your Discord/Slack channel

---

## What It Does

- ⏰ Triggers weekly (cron: `0 17 * * 5`)
- 📊 Fetches commits, closed issues, and merged PRs from the past 7 days
- 🤖 Sends data to Claude API (`claude-sonnet-4-20250514`) for narrative generation
- 📬 Delivers the summary via webhook (Discord/Slack)

## Required Scopes

- **GitHub**: `repo` (for private repos) or no scope (public repos)
- **Claude API**: Standard API key with message access

## Customization

Edit the **Prompt Template** node to adjust the summary style, tone, or add sections.

---

*Part of the Claude Builders Bounty program*