# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your **Claude API** and **GitHub** credentials in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the workflow and edit the *Set Config* node:
   - `repo`: target GitHub repo (`owner/name`)
   - `webhookUrl`: your Discord/Slack webhook URL
   - `language`: `EN` or `FR`

4. **Activate**: Toggle the workflow *Active* and verify the cron schedule (default: Fridays at 5:00 PM)

5. **Test manually**: Click *Execute Workflow* and check your Discord/Slack channel for the summary

---

## What It Does

- **Trigger**: Weekly cron (Fridays 17:00)
- **Fetches**: Commits, closed issues, merged PRs from the past 7 days via GitHub API
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts formatted summary to Discord/Slack webhook

## Required Credentials

| Service | How to Obtain |
|---------|---------------|
| Claude API | [Anthropic Console](https://console.anthropic.com) → API Keys |
| GitHub | [GitHub Settings](https://github.com/settings/tokens) → Personal Access Tokens (classic) with `repo` scope |

## Language Support

Set `language` to `EN` or `FR` in the *Set Config* node. The prompt dynamically adjusts.

---

*Part of the Claude Builders Bounty program.*