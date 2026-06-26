# n8n Weekly Dev Summary Workflow

Automatically generate and deliver a narrative weekly summary of your GitHub repo's activity using Claude API.

## Prerequisites

- n8n instance (cloud or self-hosted)
- GitHub personal access token
- Anthropic API key
- Email SMTP credentials or webhook URL (Discord/Slack)

## Setup (5 steps)

1. **Import the workflow**: In n8n, click *Import* → *From File* and select `workflow.json`
2. **Set credentials**: Open the *GitHub*, *Anthropic*, and *Send Email*/*HTTP Request* nodes and enter your credentials
3. **Configure variables**: Edit the *Set Variables* node — set `repo`, `owner`, `channel`, and `language` (EN/FR)
4. **Set the cron schedule**: The *Schedule Trigger* is pre-configured for Fridays at 5 PM — adjust if needed
5. **Activate and test**: Click *Activate*, then click *Execute Workflow* to run a test

## Workflow Overview

