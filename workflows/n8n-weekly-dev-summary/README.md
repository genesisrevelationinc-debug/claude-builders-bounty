# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import → From File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your *GitHub API*, *Claude API*, and *Slack/Email* credentials in n8n
3. **Configure variables**: Open the *Set Config* node and set `repo`, `channel`, and `language`
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Verify**: Click *Execute Workflow* and check your Slack channel/email for the summary

## Required Credentials

| Service | How to Obtain |
|---------|---------------|
| GitHub API | Settings → Developer settings → Personal access tokens |
| Claude API | [console.anthropic.com](https://console.anthropic.com) → API keys |
| Slack Webhook | Slack app → Incoming Webhooks → Add to workspace |

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repo` | GitHub repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
| `channel` | Slack channel or email address | `#dev-updates` or `team@example.com` |
| `language` | Summary language | `EN` or `FR` |

## Workflow Overview

