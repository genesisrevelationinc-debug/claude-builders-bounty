# Claude PR Reviewer 🤖

> A Claude Code sub-agent that reviews GitHub PRs and posts structured Markdown comments.

## Features

- **CLI Tool**: Run `claude-review --pr <url>` from your terminal
- **GitHub Action**: Automatically review PRs on pull request events
- **Structured Output**: Summary, risks, suggestions, and confidence score
- **AI-Powered**: Uses Claude Code's built-in analysis capabilities

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated
- Node.js 18+ (for the CLI wrapper)
- GitHub token with `repo` scope (for posting comments)

### Setup

1. Clone this repository:
