#!/usr/bin/env bash
set -euo pipefail

# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh

CHANGELOG_FILE="CHANGELOG.md"
REPO_URL=$(git remote get-url origin 2>/dev/null | sed 's/\.git$//' | sed 's/^git@github\.com:/https:\/\/github.com\//' || echo "")

# Get the latest tag, or empty if no tags exist
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Determine commit range
if [ -n "$LATEST_TAG" ]; then
    COMMIT_RANGE="${LATEST_TAG}..HEAD"
    echo "Generating changelog for commits since tag: $LATEST_TAG"
else
    COMMIT_RANGE="HEAD"
    echo "No tags found. Generating changelog for all commits."
fi

# Get commits with hash, subject, and body
get_commits() {
    git log "$COMMIT_RANGE" --pretty=format:"%H|%s|%b|END" --no-merges 2>/dev/null || true
}

# Categorize a commit based on its message
categorize_commit() {
    local subject="$1"
    local lower_subject
    lower_subject=$(echo "$subject" | tr '[:upper:]' '[:lower:]')

    # Check for conventional commit prefixes first
    if [[ "$lower_subject" =~ ^(feat|add|introduce|implement|create|new) ]]; then
        echo "Added"
    elif [[ "$lower_subject" =~ ^(fix|bugfix|hotfix|patch|resolve|correct) ]]; then
        echo "Fixed"
    elif [[ "$lower_subject" =~ ^(remove|delete|drop|revert|deprecate|clean) ]]; then
        echo "Removed"
    elif [[ "$lower_subject" =~ ^(update|change|modify|refactor|improve|enhance|upgrade|rework|optimize) ]]; then
        echo "Changed"
    else
        # Default categorization based on keywords
        case "$lower_subject" in
            *"add"*|*"feature"*|*"implement"*|*"introduce"*|*"create"*|*"support"*)
                echo "Added"
                ;;
            *"fix"*|*"bug"*|*"resolve"*|*"correct"*|*"patch"*)
                echo "Fixed"
                ;;
            *"remove"*|*"delete"*|*"drop"*|*"deprecate"*|*"clean"*)
                echo "Removed"
                ;;
            *"update"*|*"change"*|*"modify"*|*"refactor"*|*"improve"*|*"enhance"*|*"upgrade"*|*"optimize"*)
                echo "Changed"
                ;;
            *)
                echo "Changed"
                ;;
        esac
    fi
}

# Generate the changelog
generate_changelog() {
    local added=()
    local fixed=()
    local changed=()
    local removed=()

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [ "$line" = "END" ] && continue

        local hash subject body
        hash=$(echo "$line" | cut -d'|' -f1)
        subject=$(echo "$line" | cut -d'|' -f2)
        body=$(echo "$line" | cut -d'|' -f3- | sed 's/|END$//')

        [ -z "$subject" ] && continue

        local category
        category=$(categorize_commit "$subject")

        local commit_link=""
        if [ -n "$REPO_URL" ]; then
            commit_link=" ([${hash:0:7}](${REPO_URL}/commit/${hash}))"
        fi

        case "$category" in
            "Added") added+=("- $subject$commit_link") ;;
            "Fixed") fixed+=("- $subject$commit_link") ;;
            "Changed") changed+=("- $subject$commit_link") ;;
            "Removed") removed+=("- $subject$commit_link") ;;
        esac
    done < <(get_commits | tr '\n' ' ' | sed 's/|END /\n/g' | sed 's/|END//g')

    # Write CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to this project will be documented in this file."
        echo ""
        echo "## [Unreleased] ($(date +%Y-%m-%d))"
        echo ""

        if [ ${#added[@]} -gt 0 ]; then
            echo "### Added"
            printf '%s\n' "${added[@]}"
            echo ""
        fi

        if [ ${#changed[@]} -gt 0 ]; then
            echo "### Changed"
            printf '%s\n' "${changed[@]}"
            echo ""
        fi

        if [ ${#fixed[@]} -gt 0 ]; then
            echo "### Fixed"
            printf '%s\n' "${fixed[@]}"
            echo ""
        fi

        if [ ${#removed[@]} -gt 0 ]; then
            echo "### Removed"
            printf '%s\n' "${removed[@]}"
            echo ""
        fi

        echo "---"
        echo ""
        echo "*Generated automatically by [changelog.sh](changelog.sh)*"
    } > "$CHANGELOG_FILE"

    echo "✅ CHANGELOG.md generated successfully!"
}

generate_changelog