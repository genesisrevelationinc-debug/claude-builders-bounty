# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in n8n *Settings → Credentials*
3. **Configure variables**: Edit the `Set Config` node with your repo, webhook URL, and language (EN/FR)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test run**: Click *Execute Workflow* to verify, or wait for the Friday 5pm cron trigger

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Configuration Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `githubRepo` | Full repo path | `claude-builders-bounty/claude-builders-bounty` |
| `destinationWebhook` | Discord/Slack webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Output

The workflow delivers a narrative summary including:
- Commit highlights with authors
- Closed issues summary
- Merged PRs overview
- Overall week-in-review narrative

## Screenshot

![Successful Execution](screenshot.png)

*Include a screenshot of your successful n8n execution here when claiming the bounty.*

## License

MIT
