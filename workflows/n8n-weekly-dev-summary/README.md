# n8n Weekly Dev Summary Workflow

Automatically generates a weekly narrative summary of a GitHub repo's activity using Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings → Credentials*

3. **Configure variables**: Open the workflow and edit the `Configuration` node — set your repo, destination webhook/ email, and language (EN/FR)

4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test manually**: Click *Execute Workflow* to verify; check your email/Discord/Slack for the summary

## Required Credentials

- **GitHub API**: Personal Access Token with `repo` scope
- **Anthropic API**: API key from [console.anthropic.com](https://console.anthropic.com)

## Output Example

