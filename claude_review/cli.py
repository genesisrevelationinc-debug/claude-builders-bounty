"""CLI for the Claude Code PR Review Agent."""

import argparse
import os
import sys

from .reviewer import PRReviewer


def main() -> None:
    """Run the CLI."""
    parser = argparse.ArgumentParser(
        description="Claude Code PR Review Agent - Analyze PRs and generate structured review comments."
    )
    parser.add_argument(
        "--pr",
        required=True,
        help="GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)",
    )
    parser.add_argument(
        "--output",
        "-o",
        help="Output file path (default: print to stdout)",
    )
    parser.add_argument(
        "--model",
        default="claude-3-5-sonnet-20241022",
        help="Claude model to use (default: claude-3-5-sonnet-20241022)",
    )
    parser.add_argument(
        "--max-tokens",
        type=int,
        default=4096,
        help="Maximum tokens for response (default: 4096)",
    )

    args = parser.parse_args()

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print(
            "Error: ANTHROPIC_API_KEY environment variable not set.", file=sys.stderr
        )
        sys.exit(1)

    try:
        reviewer = PRReviewer(
            api_key=api_key,
            model=args.model,
            max_tokens=args.max_tokens,
        )
        review = reviewer.review_pr(args.pr)

        if args.output:
            with open(args.output, "w") as f:
                f.write(review)
            print(f"Review written to {args.output}")
        else:
            print(review)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()