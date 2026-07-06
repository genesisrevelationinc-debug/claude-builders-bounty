# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your *Claude API* and *GitHub API* credentials in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the workflow, edit the **Set Config** node and set:
   - `repoOwner` / `repoName` — target GitHub repository
   - `webhookUrl` — Discord/Slack incoming webhook URL
   - `language` — `EN` or `FR`

4. **Activate**: Toggle the workflow *Active* — it runs automatically every Friday at 5 PM

5. **Test manually**: Click *Execute Workflow* to verify, then check your Discord/Slack channel

## Workflow Overview

| Node | Purpose |
|------|---------|
| Cron Trigger | Runs weekly (Fri 17:00) |
| Set Config | Stores repo, webhook, language variables |
| GitHub Commits | Fetches commits from the past 7 days |
| GitHub Issues | Fetches closed issues from the past 7 days |
| GitHub PRs | Fetches merged PRs from the past 7 days |
| Merge Data | Combines all GitHub data into one object |
| Claude API | Generates narrative summary (model: `claude-sonnet-4-20250514`) |
| Send to Discord/Slack | Delivers the formatted summary via webhook |

## Required Credentials

- **Claude API**: Anthropic API key with access to `claude-sonnet-4-20250514`
- **GitHub API**: Personal access token with `repo` scope (public repos work without auth)

## Output Example

> **Weekly Dev Summary — `owner/repo`**
> 
> This week, the team merged 12 PRs, closed 8 issues, and pushed 34 commits. The main focus was on refactoring the authentication module and improving test coverage. Notable contributions include a new OAuth2 flow and several bug fixes for edge cases in payment processing.

---

*Part of the Claude Builders Bounty — MIT License*