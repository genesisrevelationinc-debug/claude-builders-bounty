# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the *Set Variables* node with your repo, destination, and language
4. **Activate the schedule**: Toggle the workflow *Active* — it runs Fridays at 5pm automatically
5. **Test manually**: Click *Execute Workflow* to verify, then check your email/Discord for the summary

## Required Credentials

- **GitHub Personal Access Token** (classic or fine-grained with `repo` scope)
- **Anthropic API Key** (from [console.anthropic.com](https://console.anthropic.com))

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full GitHub repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destinationChannel` | Email or webhook URL | `https://hooks.discord.com/...` |
| `language` | Summary language | `EN` or `FR` |
| `summaryStyle` | Narrative style | `executive`, `detailed`, or `bullet` |

## Delivery Options

- **Email**: Set `destinationChannel` to an email address; configure SMTP credentials in n8n
- **Discord/Slack**: Set `destinationChannel` to a webhook URL; the workflow auto-detects the format

## Workflow Overview

