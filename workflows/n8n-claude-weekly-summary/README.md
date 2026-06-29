# n8n + Claude Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n and Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the *Set Config* node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (EN or FR)
4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
5. **Test**: Click *Execute Workflow* to run manually and verify the output

## Workflow Overview

| Node | Purpose |
|------|---------|
| Cron Trigger | Runs weekly (Friday 17:00) |
| Set Config | Defines repo, language, webhook URL |
| GitHub Commits | Fetches commits from the past 7 days |
| GitHub Issues | Fetches closed issues from the past 7 days |
| GitHub PRs | Fetches merged PRs from the past 7 days |
| Merge Data | Combines all GitHub data into one object |
| Build Prompt | Constructs the Claude prompt with context |
| Claude API | Generates narrative summary |
| Send to Discord | Delivers summary via Discord webhook |

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Output Example

> 📊 **Weekly Summary for `owner/repo`** (May 12–18, 2025)
>
> This week saw 12 commits, 5 closed issues, and 3 merged PRs. The team focused on refactoring the authentication module and improving test coverage. Notable PR: #42 — "Add OAuth2 support" by @alice.

## Delivery

The workflow sends summaries to a Discord webhook by default. To use Slack instead, replace the *HTTP Request* node URL with your Slack webhook URL and adjust the payload format.

*Tested on n8n v1.50+*