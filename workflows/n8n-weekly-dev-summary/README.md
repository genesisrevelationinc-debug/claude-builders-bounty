# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your **Claude API** and **GitHub** credentials in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the workflow and edit the *Set Config* node:
   - `repoOwner` / `repoName` — target GitHub repository
   - `webhookUrl` — your Discord/Slack webhook URL
   - `language` — `EN` or `FR`

4. **Activate the workflow**: Toggle the workflow to *Active* — it runs automatically every Friday at 5 PM

5. **Test manually**: Click *Execute Workflow* to run a test and verify the output in your Discord/Slack channel

---

## What It Does

- **Trigger**: Weekly cron (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the formatted summary to Discord or Slack via webhook

## Required Environment Variables / Credentials

| Credential | Where to Get |
|------------|-------------|
| Claude API | https://console.anthropic.com/settings/keys |
| GitHub Personal Access Token | https://github.com/settings/tokens (needs `repo` scope) |

## Output Example

> **Weekly Dev Summary: `owner/repo`**
>
> This week saw 12 commits, 5 closed issues, and 3 merged PRs. Key highlights include a major refactor of the auth module, bug fixes for the payment flow, and documentation updates...

---

## Files

- `weekly-dev-summary.json` — the n8n workflow (import this)
- `README.md` — this file