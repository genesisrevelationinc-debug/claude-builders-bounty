#!/usr/bin/env python3
"""CLI entry point for claude-review."""

import os
import sys

import click

from .reviewer import PRReviewer


@click.command()
@click.option(
    "--pr",
    "pr_url",
    required=True,
    help="GitHub PR URL to review (e.g., https://github.com/owner/repo/pull/123)",
)
@click.option(
    "--output",
    "-o",
    "output_path",
    default=None,
    help="Output file path (default: print to stdout)",
)
@click.option(
    "--model",
    default="claude-3-5-sonnet-20241022",
    help="Claude model to use for review",
)
@click.option(
    "--max-tokens",
    default=4096,
    help="Maximum tokens for Claude response",
)
def main(pr_url: str, output_path: str | None, model: str, max_tokens: int) -> None:
    """
    Review a GitHub PR using Claude and output structured Markdown.
    
    \b
    Example:
        claude-review --pr https://github.com/owner/repo/pull/123
        claude-review --pr https://github.com/owner/repo/pull/123 -o review.md
    """
    # Validate API key
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        click.echo(
            "Error: ANTHROPIC_API_KEY environment variable is required.",
            err=True,
        )
        sys.exit(1)

    # Validate PR URL format
    if not _is_valid_pr_url(pr_url):
        click.echo(
            f"Error: Invalid PR URL format: {pr_url}\n"
            "Expected: https://github.com/owner/repo/pull/123",
            err=True,
        )
        sys.exit(1)

    # Initialize reviewer
    reviewer = PRReviewer(
        api_key=api_key,
        model=model,
        max_tokens=max_tokens,
    )

    # Run review
    try:
        review = reviewer.review_pr(pr_url)
    except Exception as e:
        click.echo(f"Error reviewing PR: {e}", err=True)
        sys.exit(1)

    # Output
    if output_path:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(review)
        click.echo(f"Review written to {output_path}")
    else:
        click.echo(review)


def _is_valid_pr_url(url: str) -> bool:
    """Check if URL matches GitHub PR format."""
    import re
    pattern = r"^https://github\.com/[^/]+/[^/]+/pull/\d+$"
    return bool(re.match(pattern, url))