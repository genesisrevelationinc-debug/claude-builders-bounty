# n8n Weekly Dev Summary Workflow

Automated weekly narrative summary of a GitHub repo's activity, powered by n8n and Claude API.

## Setup (5 steps)

1. **Import the workflow**: In n8n, go to *Workflows → Import from File* and select `weekly-dev-summary.json`.

2. **Set credentials**: Add your **Claude API** and **GitHub** credentials in n8n *Settings → Credentials*.

3. **Configure variables**: Open the workflow and edit the *Set Variables* node:
   - `githubRepo` — e.g. `owner/repo`
   - `destinationWebhook` — your Discord/Slack webhook URL
   - `language` — `EN` or `FR`

4. **Activate the workflow**: Toggle the workflow to *Active* in the top-right corner.

5. **Test it**: Click *Execute Workflow* or wait for the next Friday at 5 PM.

---

## What It Does

- **Trigger**: Weekly cron (Fridays at 5 PM)
- **Fetches**: Commits, closed issues, and merged PRs from the past 7 days
- **Summarizes**: Sends data to Claude API (`claude-sonnet-4-20250514`) for a narrative summary
- **Delivers**: Posts the summary to a Discord or Slack webhook

## Required Environment / Credentials

| Credential | Where to Get |
|------------|-------------|
| Claude API | https://console.anthropic.com/settings/keys |
| GitHub Token | https://github.com/settings/tokens (needs `repo` scope) |

## Output Example

> 📅 **Weekly Dev Summary for `owner/repo`** (May 12 – May 19)
>
> This week saw 12 commits, 3 closed issues, and 2 merged PRs. The team focused on refactoring the authentication layer and fixing critical bugs in the payment flow...

---

## License

MIT