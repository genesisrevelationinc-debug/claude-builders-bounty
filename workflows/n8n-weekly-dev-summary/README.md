# n8n Weekly Dev Summary Workflow

Automatically generate a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `workflow.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Claude API key in n8n *Credentials*
3. **Configure variables**: Open the workflow and edit the `Set Config` node — set your repo, destination, and language
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test**: Click *Execute Workflow* or wait for the weekly cron trigger (Fridays at 5pm UTC)

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Claude API**: Anthropic API key from [console.anthropic.com](https://console.anthropic.com)

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destination` | Webhook URL for delivery | `https://hooks.slack.com/services/...` |
| `language` | Summary language | `EN` or `FR` |

## Output Example

