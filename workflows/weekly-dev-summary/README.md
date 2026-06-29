# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Settings* → *Credentials*

3. **Configure variables**: Open the workflow and edit the *Set Variables* node with your repo, destination, and language

4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test it**: Click *Execute Workflow* to run manually and verify the output

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configurable Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Target repository (owner/repo) | `claude-builders-bounty/claude-builders-bounty` |
| `destinationWebhook` | Email/Discord/Slack webhook URL | `https://hooks.slack.com/services/...` |
| `language` | Output language: `EN` or `FR` | `EN` |

## Output Example

