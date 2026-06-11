"""CLI entry point for claude-review."""

import argparse
import sys

from .reviewer import review_pr


def main():
    parser = argparse.ArgumentParser(
        description="Claude Code PR Review Agent",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  claude-review --pr https://github.com/owner/repo/pull/123
  claude-review --pr https://github.com/owner/repo/pull/123 --output review.md
  claude-review --pr https://github.com/owner/repo/pull/123 --confidence high
        """,
    )
    parser.add_argument(
        "--pr",
        required=True,
        help="URL of the GitHub PR to review",
    )
    parser.add_argument(
        "--output",
        "-o",
        help="Path to write the structured review Markdown (default: print to stdout)",
    )
    parser.add_argument(
        "--confidence",
        choices=["low", "medium", "high"],
        default="medium",
        help="Minimum confidence threshold for including suggestions (default: medium)",
    )
    parser.add_argument(
        "--model",
        default="claude-sonnet-4-20250514",
        help="Claude model to use (default: claude-sonnet-4-20250514)",
    )

    args = parser.parse_args()

    try:
        review = review_pr(args.pr, confidence=args.confidence, model=args.model)

        if args.output:
            with open(args.output, "w") as f:
                f.write(review)
        else:
            print(review)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()