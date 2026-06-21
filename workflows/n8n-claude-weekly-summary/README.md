# n8n + Claude Weekly Dev Summary Workflow

Automatically generate and deliver a weekly narrative summary of your GitHub repo's activity using n8n and the Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`

2. **Set credentials**: Add your **Claude API** and **GitHub** credentials in *Settings → Credentials*

3. **Configure variables**: Open the `Set Config` node and edit:
   - `repoOwner` / `repoName` — target GitHub repository
   - `webhookUrl` — your Discord/Slack webhook URL
   - `language` — `EN` or `FR`

4. **Activate the workflow**: Toggle the workflow to *Active* — it runs every Friday at 5 PM

5. **Test manually**: Click *Execute Workflow* to verify, then check your Discord/Slack channel

---

## What It Does

- **Trigger**: Weekly cron (Fridays at 17:00)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
- **Generates**: Narrative summary via Claude API (`claude-sonnet-4-20250514`)
- **Delivers**: Formatted message to Discord/Slack webhook

## Required Credentials

| Service | How to Obtain |
|---------|---------------|
| Claude API | [Anthropic Console](https://console.anthropic.com) → API Keys |
| GitHub | [GitHub Settings](https://github.com/settings/tokens) → Personal Access Tokens → `repo` scope |

## Output Example

> **Weekly Dev Summary — `my-org/my-repo`**
>
> This week saw 12 commits, 3 closed issues, and 2 merged PRs. Key highlights include a major refactor of the auth module and performance improvements reducing load times by 40%.

---

## Screenshot

![Successful n8n execution](screenshot.png)
*Example: Successful workflow execution in n8n*