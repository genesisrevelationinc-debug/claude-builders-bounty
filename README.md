# Claude Builders Bounty 📊

> Automated weekly development summaries powered by Claude API

## 🚀 Quick Start

1. **Import the workflow** to n8n from the JSON file
2. **Set your GitHub token** in the credentials section
3. **Configure the cron schedule** for weekly execution
4. **Set the Claude API key** in the environment variables
5. **Deploy and activate** the workflow

## 📦 What's Included

- `n8n-workflow-Claude_GitHub_Summary.json` - The main n8n workflow file
- `README.md` - This documentation file

## 🎯 Key Features

- **Weekly Summaries**: Get automated development summaries every Friday at 5pm
- **GitHub Integration**: Fetches commits, issues, and PRs for the past week
- **Claude API Integration**: Uses Claude Sonnet 4 model for narrative generation
- **Multi-language support**: Generate summaries in EN or FR
- **Delivery Options**: Get results via Discord

## 📤 Outputs

This workflow delivers summaries via:
- Email (optional)
- Discord (default)

## 🛠 Configuration

To set up this workflow:
1. Set the Claude API key in your n8n environment variables
2. Configure the cron in the workflow settings to run weekly
3. Set the output destination (email/discord) in the workflow
4. Add your preferred notification method (email, Discord, or Slack)
5. Run the installed workflow to generate your custom dev summary

## 📌 Notes

- The workflow runs weekly to generate a development summary
- The summary is generated in both English and French languages
- You can configure the language in the workflow
## 🎯 Deliverables

The workflow will:
- Query the GitHub API for this week's activity
- Generate a natural language summary using Claude API
- Send the summary via email or to a Discord channel

## 🎯 Requirements

To use this workflow:
- Have a valid Claude API key
- Configure the workflow to run on a schedule
- Set environment variables for GitHub repo and destination
- Select 'EN' or 'FR' for the summary language

## 🔄 How to Use

1. Import the workflow from the JSON file
2, Set your Claude API key in the credentials section
3. Configure the cron in the workflow settings
4. Add the repository name in the workflow
5. Set your preferred output destination (email or Discord)

## 📝 Note
This workflow allows you to be more efficient in:
- Automating your weekly dev summaries
- Saving the summary to a file or service

## 🚨 Additional Setup

Before running, you should:
1. Set your Claude API key in the credentials
2. Configure the cron in the workflow settings
3. Set the environment variables for the GitHub repository
4. Select your preferred notification method (email, Discord, or Slack)
5. Add the repository name in the workflow
6. Set the output format (narrative) in the workflow
7. Configure the language (EN/FR) in the workflow
8. Add the access token for GitHub in the workflow
9. Configure the schedule in the workflow
10. Add the repository name in the workflow
11. Set the output format in the workflow
12. Add the notification method in the workflow
1
# Claude Builders Bounty 🤖

> A community bounty board for Claude Code builders.

Building with Claude Code? Have tasks to delegate?
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

---

*Started by the Claude builder community · March 2026 · MIT License*
