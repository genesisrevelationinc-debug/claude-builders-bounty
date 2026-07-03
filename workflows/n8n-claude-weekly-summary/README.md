# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import** `workflow.json` into your n8n instance (Settings → Workflows → Import)
2. **Set credentials**: Add your GitHub token, Claude API key, and email/SMTP or webhook credentials in n8n
3. **Configure variables**: Edit the `Set Config` node with your repo, destination, and language (EN/FR)
4. **Activate** the workflow toggle in n8n
5. **Test** manually or wait for the weekly cron trigger (Fridays at 5pm)

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key
- **Delivery**: SMTP credentials (email) or webhook URL (Discord/Slack)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `owner/repo-name` |
| `destination` | Email address or webhook URL | `dev-updates@company.com` |
| `language` | Summary language | `EN` or `FR` |

## Workflow Overview

