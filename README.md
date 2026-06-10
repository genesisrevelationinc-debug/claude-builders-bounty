# Claude Builders Bounty 🤖
<br/>
> A community bounty board for Claude Code builders.

> Building with Claude Code? Have tasks to delegate?
Want to get paid for contributing to AI projects?
You're in the right place.

---

## How it works

**To post a bounty**
1. Open a GitHub issue with a clear description and acceptance criteria
2. Comment `/opire create $XXX` in the issue to set the reward
3. Share the link — contributors will find it

**To claim a bounty**
1. Browse the open issues below
2. Comment `/opire try` in the issue you want to work on
3. Submit a PR — payment is automatic on merge ✅

---

## Active Bounties

| # | Task | Amount | Status |
|---|------|--------|--------|
| [#1](../../issues/1) | SKILL: Generate a CHANGELOG from git history | $50 | 🟢 Open |
| [#2](../../issues/2) | TEMPLATE: CLAUDE.md for a Next.js + SQLite project | $75 | 🟢 Open |
| [#3](../../issues/3) | HOOK: Block destructive bash commands in Claude Code | $100 | 🟢 Open |
| [#4](../../issues/4) | AGENT: PR reviewer with structured Markdown output | $150 | 🟢 Open |
| [#5](../../issues/5) | WORKFLOW: n8n + Claude API — automated weekly dev summary | $200 | 🟢 Open |

---

## Rules

- Tasks must be related to Claude Code or AI tooling
- Every issue must have clear acceptance criteria before a bounty is activated
- Payment is handled by [Opire](https://opire.dev) (Stripe)
- Quality over speed — a solid PR beats a fast one

---

## Community

- 🐦 X: [@ClaudeBounty](https://x.com/ClaudeBounty)
- 📧 Contact: claudebounty@gmail.com


*Started by the Claude builder community · March 2026 · MIT License*

## Automated Weekly Dev Summary Workflow

### Setup Instructions

1. **Import the workflow**  
   - Download the provided n8n workflow JSON file
   - In your n8n instance, go to the Workflows page
   - Click "Import" and select the downloaded JSON file

2. **Configure the GitHub node**  
   - Set your GitHub personal access token in the credentials section
   - Update the repository name in the "Get Weekly Data" node

3. **Set up Claude API**  
   - Add your Claude API key to the "Set Claude API Key" node
   - Adjust the language in the "Set Language" node if needed (default: English)

4. **Configure delivery**  
   - For email: Update the "Send Email" node with your SMTP settings and recipient
   - For Discord: Update the "Send to Discord" node with your webhook URL

5. **Set schedule**  
   - The workflow runs weekly by default on Fridays at 5 PM
   - Adjust the cron expression in the "Schedule Trigger" node if needed

### How it Works

This workflow automatically generates a narrative summary of a GitHub repository's weekly activity using the Claude API. Here's the process:

1. **Schedule Trigger**  
   Fires weekly to start the workflow

2. **Get Weekly Data**  
   Fetches commits, closed issues, and merged PRs from the specified GitHub repository for the past week

3. **Prepare Summary Data**  
   Formats the collected data into a structure suitable for Claude

4. **Generate Prompt**  
   Creates a prompt for Claude with the weekly data

5. **Call Claude API**  
   Sends the prompt to Claude API to generate a narrative summary

6. **Format Summary**  
   Processes Claude's response

7. **Deliver Summary**  
   Sends the summary via email or Discord webhook

### Configuration Variables

- **GitHub Repository**: The repository to summarize (default: `claude-builders-bounty/claude-builders-bounty`)
- **Delivery Method**: Choose between email or Discord/Slack webhook
- **Language**: Choose between English (EN) or French (FR) output

### Prerequisites

- n8n instance (v1.0 or higher)
- GitHub personal access token with repo permissions
- Claude API key
- (Optional) SMTP server details or Discord webhook URL

### Nodes Overview

1. **Schedule Trigger** - Controls when the workflow runs
2. **Get Weekly Data** - GitHub API calls to fetch repository activity
3. **Prepare Summary Data** - Formats data for Claude
4. **Generate Prompt** - Creates the prompt for Claude API
5. **Call Claude API** - Interfaces with Claude Sonnet 4
6. **Format Summary** - Processes Claude's response
7. **Deliver Summary** - Sends the final summary to users

### Customization

- Change the cron expression in the Schedule Trigger node to adjust timing
- Modify the GitHub repository in the "Get Weekly Data" node
- Update delivery settings in the "Deliver Summary" nodes
- Change language in the "Set Language" node

### Testing

The workflow has been tested successfully on a real n8n instance. A test execution showed proper data fetching, Claude API interaction, and delivery.

![Test Execution](./workflow_test.png)

*Note: You'll need to replace the placeholder values with your actual credentials and configuration.*
