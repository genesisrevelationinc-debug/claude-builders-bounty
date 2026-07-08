# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Workflows → Import from File* and select `weekly-dev-summary.json`
2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API Key in *Settings → Credentials*
3. **Configure variables**: Open the *Set Config* node and edit: `githubRepo` (e.g., `owner/repo`), `webhookUrl` (Discord/Slack), `language` (`EN` or `FR`)
4. **Activate**: Toggle the workflow to *Active* in the top-right corner
5. **Test**: Click *Execute逃Execute Workflow* or wait for the next Friday at 5 PM

## Delivery

The workflow sends summaries via **Discord/Slack webhook**. Configure the `webhookUrl` variable with your incoming webhook URL.

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic**: API Key from [console.anthropic.com](https://console.anthropic.com)

## Customization

| Variable | Description | Default |
|----------|-------------|---------|
| `githubRepo` | Target repository (`owner/name`) | `claude-builders-bounty/claude-builders-bounty` |
| `webhookUrl` | Discord/Slack incoming webhook | — |
| `language` | Summary language (`EN` or `FR`) | `EN` |

## Screenshot

![Successful Execution](screenshot.png)

*Include a screenshot of a successful execution from your n8n instance here.*

## License

MIT