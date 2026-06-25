#!/usr/bin/env bash
#
# changelog.sh — Generate a structured CHANGELOG.md from git history
#
# Usage: bash changelog.sh
#
# Fetches commits since the last git tag, auto-categorizes them,
# and appends a new section to CHANGELOG.md.
#

set -euo pipefail

# ── Colors ─────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ── Helpers ──────────────────────────────────────────────────────
log_info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Detect last tag ──────────────────────────────────────────────
get_last_tag() {
    git describe --tags --abbrev=0 2>/dev/null || true
}

# ── Get commits since a given ref ────────────────────────────────
get_commits_since() {
    local ref="$1"
    if [[ -z "$ref" ]]; then
        # No previous tag: list all commits
        git log --pretty=format:"%H|%s" --no-merges
    else
        git log "${ref}..HEAD" --pretty=format:"%H|%s" --no-merges
    fi
}

# ── Categorize a single commit message ───────────────────────────
categorize() {
    local msg="$1"
    local lower
    lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Conventional commit prefixes
    if [[ "$lower" =~ ^feat(\(.+\))?: ]]; then
        echo "added"
        return
    fi
    if [[ "$lower" =~ ^fix(\(.+\))?: ]]; then
        echo "fixed"
        return
    fi
    if [[ "$lower" =~ ^(chore|refactor|perf|style|docs|test|build|ci)(\(.+\))?: ]]; then
        echo "changed"
        return
    fi
    if [[ "$lower" =~ ^(remove|delete|drop|revert)(\(.+\))?: ]]; then
        echo "removed"
        return
    fi

    # Keyword-based fallback
    case "$lower" in
        *"add"* | *"introduce"* | *"implement"* | *"create"* | *"new "*)
            echo "added" ;;
        *"fix"* | *"bug"* | *"resolve"* | *"patch"* | *"correct"* | *"repair"*)
            echo "fixed" ;;
        *"remove"* | *"delete"* | *"drop"* | *"revert"* | *"clean"*)
            echo "removed" ;;
        *"update"* | *"change"* | *"modify"* | *"improve"* | *"refactor"* | *"enhance"*)
            echo "changed" ;;
        *)
            echo "changed" ;;  # default
    esac
}

# ── Main ─────────────────────────────────────────────────────────
main() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not a git repository."
        exit 1
    fi

    local last_tag
    last_tag=$(get_last_tag)

    if [[ -z "$last_tag" ]]; then
        log_warn "No tags found. Using all commits."
        last_tag=""
    else
        log_info "Last tag: $last_tag"
    fi

    local commits
    commits=$(get_commits_since "$last_tag")

    if [[ -z "$commits" ]]; then
        log_info "No new commits since $last_tag."
        exit 0
    fi

    # Prepare categorized lists
    local added=() fixed=() changed=() removed=()

    while IFS='|' read -r hash msg; do
        [[ -z "$msg" ]] && continue
        local cat
        cat=$(categorize "$msg")
        case "$cat" in
            added)   added+=("$msg") ;;
            fixed)   fixed+=("$msg") ;;
            changed) changed+=("$msg") ;;
            removed) removed+=("$msg") ;;
        esac
    done <<< "$commits"

    # Build new changelog section
    local version_name="${last_tag:-$(git rev-parse --short HEAD)}"
    local date_str
    date_str=$(date +%Y-%m-%d)

    {
        echo ""
        echo "## [Unreleased] — $date_str"
        echo ""
        if [[ ${#added[@]}   -gt 0 ]]; then echo "### Added";   printf '- %s\n' "${added[@]}";   echo ""; fi
        if [[ ${#changed[@]} -gt 0 ]]; then echo "### Changed"; printf '- %s\n' "${changed[@]}"; echo ""; fi
        if [[ ${#fixed[@]}  -gt 0 ]]; then echo "### Fixed";   printf '- %s\n' "${fixed[@]}";   echo ""; fi
        if [[ ${#removed[@]} -gt 0 ]]; then echo "### Removed"; printf '- %s\n' "${removed[@]}"; echo ""; fi
    } >> CHANGELOG.md

    log_info "CHANGELOG.md updated with commits since ${last_tag:-'beginning'}."
}

main "$@"