# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your *GitHub API*, *Anthropic Claude API*, and *Email/SMTP* (or *Webhook*) credentials in n8n
3. **Configure variables**: Open the *Set Config* node and edit: `repoOwner`, `repoName`, `language` (`EN` or `FR`), and `destination` (email or webhook URL)
4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM
5. **Test**: Click *Execute Workflow* to run manually and verify the output

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Anthropic Claude API**: API key from [Anthropic Console](https://console.anthropic.com)
- **Email (SMTP)** OR **Webhook**: For delivery — configure one based on your `deliveryMethod` choice

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub organization or user | `claude-builders-bounty` |
| `repoName` | Repository name | `claude-builders-bounty` |
| `language` | Summary language | `EN` or `FR` |
| `deliveryMethod` | `email` or `webhook` | `email` |
| `destination` | Email address or webhook URL | `team@example.com` |

## Workflow Overview

