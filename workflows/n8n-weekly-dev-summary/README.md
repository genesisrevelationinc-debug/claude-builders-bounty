# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings* → *Credentials*

3. **Configure variables**: Open the *Set Variables* node and set:
   - `githubRepo` — e.g., `owner/repo-name`
   - `destinationWebhook` — your email/Discord/Slack webhook URL
   - `language` — `EN` or `FR`

4. **Activate**: Toggle the workflow to *Active* in the top-right corner

5. **Test**: Click *Execute Workflow* or wait for the weekly cron trigger (Fridays at 5pm UTC)

---

## Workflow Overview

| Node | Purpose |
|------|---------|
| Cron Trigger | Runs every Friday at 5pm UTC |
| GitHub Commits | Fetches commits from the past 7 days |
| GitHub Issues | Fetches closed issues from the past 7 days |
| GitHub PRs | Fetches merged PRs from the past 7 days |
| Merge Data | Combines all GitHub data into one object |
| Claude API | Generates narrative summary via `claude-sonnet-4-20250514` |
| Send Summary | Delivers via webhook (Discord/Slack/Email) |

---

## Required Credentials

- **GitHub Personal Access Token** (no special scopes needed for public repos; `repo` for private)
- **Anthropic API Key** from [console.anthropic.com](https://console.anthropic.com)

---

## Output Example

> 📊 **Weekly Dev Summary for `owner/repo`**
>
> This week, the team merged 12 PRs, closed 8 issues, and pushed 34 commits. The main focus was on refactoring the authentication module and improving test coverage...