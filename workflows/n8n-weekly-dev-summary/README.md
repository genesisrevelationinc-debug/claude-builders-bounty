# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*

(>_0)
3. **Configure variables**: Open the workflow, click *Workflow Settings*, and set these variables:
   - `repo` — GitHub repo in `owner/name` format
   - `channel` — email address or webhook URL for delivery
   - `language` — `EN` or `FR`

4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test**: Click *Execute Workflow* to run manually and verify output

## Delivery Options

- **Email**: Set `channel` to a valid email address (uses n8n's built-in email node)
- **Discord/Slack**: Set `channel` to a webhook URL (uses HTTP Request node)
`.trim();

const workflow = {
# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n + Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows* → *Import from File* → select `weekly-dev-summary.json`

2. **Set credentials**: Add your GitHub Personal Access Token and Anthropic API key in *Settings* → *Credentials*

3. **Configure variables**: Open the workflow, click *Workflow Settings*, and set these variables:
   - `repo` — GitHub repo in `owner/name` format
   - `channel` — email address or webhook URL for delivery
   - `language` — `EN` or `FR`

4. **Activate**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test**: Click *Execute Workflow* to run manually and verify output

## Delivery Options

- **Email**: Set `channel` to a valid email address (uses n8n's built-in email node)
- **Discord/Slack**: Set `channel` to a webhook URL (uses HTTP Request node)

## Workflow Overview

