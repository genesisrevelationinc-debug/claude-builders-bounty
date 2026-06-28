# n8n + Claude Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*
3. **Configure variables**: Open the workflow and edit the `Set Config` node — set `repoOwner`, `repoName`, `webhookUrl`, and `language` (`EN` or `FR`)
4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM UTC
5. **Test manually**: Click *Execute Workflow* to verify — check your Discord/Slack channel for the summary

## Delivery

The workflow posts summaries to a Discord or Slack webhook. Configure `webhookUrl` in the `Set Config` node.

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `repoOwner` | GitHub repository owner | `claude-builders-bounty` |
| `repoName` | GitHub repository name | `claude-builders-bounty` |
| `webhookUrl` | Discord/Slack incoming webhook URL | `https://discord.com/api/webhooks/...` |
| `language` | Summary language | `EN` or `FR` |

## Required n8n Nodes

- **Cron**: Weekly trigger (Friday 5 PM)
- **HTTP Request**: GitHub API (commits, issues, PRs)
- **Set**: Configuration variables
- **Code**: Data transformation
- **Anthropic Chat Model**: Claude API (`claude-sonnet-4-20250514`)
- **HTTP Request**: Webhook delivery

## Screenshot

![Successful Execution](screenshot.png)

*Include a screenshot of a successful execution from your n8n instance here.*

## License

MIT