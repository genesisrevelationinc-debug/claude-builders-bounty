# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your *GitHub* (Personal Access Token), *Claude API* (Anthropic API key), and *Email/SMTP* or *Webhook* credentials in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the workflow, click the first *Set* node, and edit: `repoOwner`, `repoName`, `language` (`EN` or `FR`), and `destination` (email or webhook URL)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Verify**: Click *Execute Workflow* manually and check the output — you should receive the summary at your configured destination

## Features

- **Trigger**: Runs automatically every Friday at 5:00 PM (cron: `0 17 * * 5`)
- **GitHub API**: Fetches commits, closed issues, and merged PRs from the past 7 days
- **Claude API**: Uses `claude-sonnet-4-20250514` to generate a human-readable narrative summary
- **Delivery**: Sends via email (SMTP) or Discord/Slack webhook — configurable in the `destination` variable
- **Multilingual**: Supports English (`EN`) and French (`FR`) output

## Required Credentials

| Service | Credential Type | How to Obtain |
|---------|----------------|---------------|
| GitHub | OAuth2 or Personal Access Token | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
| Anthropic Claude | API Key | [Anthropic Console](https://console.anthropic.com/) |
| Email/SMTP or Webhook | SMTP or HTTP Request | Your email provider or Discord/Slack webhook URL |

## Workflow Overview

