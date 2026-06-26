# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your **Claude API** key and **GitHub Personal Access Token** in n8n *Credentials*

3. **Configure variables**: Open the *Set Config* node and edit:
   - `repo` — GitHub owner/repo (e.g., `claude-builders-bounty/claude-builders-bounty`)
   - `channel` — email address or webhook URL for delivery
   - `language` — `EN` or `FR`

4. **Activate**: Toggle the workflow to *Active* — it runs automatically every Friday at 5 PM

5. **Test manually**: Click *Execute Workflow* to run a test and verify output

---

## Delivery Options

The workflow supports **email** (SMTP) or **webhook** (Discord/Slack) delivery. Configure in the *Set Config* node:

- For **email**: set `deliveryMethod` to `email` and `channel` to your email address
- For **webhook**: set `deliveryMethod` to `webhook` and `channel` to your Discord/Slack webhook URL

## Required Credentials

| Service | Credential Type | How to Get |
|---------|----------------|------------|
| Claude API | `anthropicApi` | [Anthropic Console](https://console.anthropic.com) |
| GitHub | `githubApi` | [GitHub Settings → Tokens](https://github.com/settings/tokens) |

## Workflow Overview

1. **Cron Trigger** — Every Friday at 5:00 PM
2. **Set Config** — Define repo, channel, language
3. **GitHub Nodes** — Fetch commits, closed issues, merged PRs (last 7 days)
4. **Claude API** — Generate narrative summary
5. **Deliver** — Send via email or webhook