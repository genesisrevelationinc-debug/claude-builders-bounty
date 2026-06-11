# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click "Add Workflow" → "Import from File" → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in n8n's "Credentials" section

3. **Configure variables**: Open the "Set Config" node and edit:
   - `repoOwner` / `repoName` — target GitHub repository
   - `webhookUrl` — your Discord/Slack webhook URL
   - `language` — `EN` or `FR`

4. **Activate the workflow**: Toggle the workflow to "Active" — it runs every Friday at 5 PM

5. **Test manually**: Click "Execute Workflow" to verify, then check your Discord/Slack channel

---

## What It Does

- **Trigger**: Cron schedule (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
- **Summarizes**: Claude API (`claude-sonnet-4-20250514`) generates a narrative summary
- **Delivers**: Posts to Discord/Slack via webhook

## Required Credentials

| Service | Type | How to Get |
|---------|------|-----------|
| GitHub | Personal Access Token | [Settings → Developer → Tokens](https://github.com/settings/tokens) |
| Anthropic | API Key | [Console → API Keys](https://console.anthropic.com) |

## Output Example

> 📊 **Weekly Dev Summary** for `owner/repo`
> 
> This week saw **12 commits**, **3 merged PRs**, and **5 closed issues**.
> 
> Highlights include a new authentication flow, performance improvements to the database layer, and bug fixes for edge cases in user onboarding...

---

*Part of the Claude Builders Bounty program*