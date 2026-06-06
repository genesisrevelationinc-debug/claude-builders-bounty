# n8n + Claude Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and email/SMTP or webhook credentials in n8n *Settings* → *Credentials*
3. **Configure variables**: Open the workflow and edit the *Set Variables* node — set `repoOwner`, `repoName`, `destinationChannel`, and `language`
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test run**: Click *Execute Workflow* to verify, or wait for the next Friday at 5 PM

## Delivery Options

The workflow supports two delivery methods (configured via `deliveryMethod` variable):

- **email**: Sends via SMTP (configure SMTP credentials in n8n)
- **webhook**: Posts to a Discord or Slack webhook URL

Set `deliveryMethod` to `email` or `webhook` in the *Set Variables* node.

## Required Credentials

| Service | Credential Type | How to Obtain |
|---------|----------------|-------------|
| GitHub | `githubApi` | [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens) |
| Claude | `claudeApi` | [Anthropic Console → API keys](https://console.anthropic.com/settings/keys) |
| SMTP (for email) | `smtp` | Your email provider's SMTP settings |
| Webhook | None needed | Paste URL directly in variables |

## Workflow Overview

