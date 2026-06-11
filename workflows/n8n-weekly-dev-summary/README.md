# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of GitHub repo activity using n8n + Claude API.

## Setup (5 steps)

1. **Import workflow**: In n8n, click "Add Workflow" → "Import from File" → select `workflow.json`

2. **Set credentials**: Add your GitHub Personal Access Token, Claude API key, and email/SMTP or webhook credentials in n8n "Credentials"

3. **Configure variables**: Open the "Set Config" node and edit: `githubRepo` (e.g., `owner/repo`), `destinationChannel` (email or webhook URL), `language` (`EN` or `FR`)

4. **Activate**: Toggle the workflow to "Active" — it runs Fridays at 5 PM UTC

5. **Test**: Click "Execute Workflow" to run manually and verify output

## Delivery Options

- **Email**: Configure SMTP credentials; summary sent to configured address
- **Discord/Slack**: Set webhook URL in `destinationChannel`; posts to channel

## Workflow Overview

