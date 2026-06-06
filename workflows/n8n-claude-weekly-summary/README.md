# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click ⚙️ → Import → paste `workflow.json`
2. **Set credentials**: Add your GitHub token, Claude API key, and email/SMTP or webhook credentials in n8n
3. **Configure variables**: Edit the `Configuration` node — set repo, destination, and language
4. **Activate**: Toggle the workflow to "Active" in n8n
5. **Verify**: Click "Execute Once" and check your destination for the summary

## Required Credentials

- **GitHub API**: Personal access token with `repo` scope
- **Claude API**: Anthropic API key (https://console.anthropic.com)
- **Delivery**: SMTP credentials OR Slack/Discord webhook URL

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `owner/repo-name` |
| `destination` | Email or webhook URL | `https://hooks.slack.com/...` |
| `language` | Summary language | `EN` or `FR` |

## Workflow Overview

