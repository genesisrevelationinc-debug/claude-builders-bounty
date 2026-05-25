#!/bin/bash

# Get the latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# Get the commit hash of the latest tag
latest_tag_commit=$(git rev-list -n 1 $latest_tag 2>/dev/null)

# Get all commits since the last tag
if [ -z "$latest_tag" ] || [ -z "$latest_tag_commit" ]; then
  # If no tags exist, get all commits
  commits=$(git log --pretty=format:"%s|%h|%an|%ad" --date=short)
  echo "No tags found. Using all commits."
else
  # Get commits since the last tag
  commits=$(git log --pretty=format:"%s|%h|%an|%ad" --date=short $latest_tag..HEAD)
fi

# Create a temporary file for processing
tmp_file=$(mktemp)
echo "$commits" > "$tmp_file"

# Initialize sections
added=""
fixed=""
changed=""
removed=""

# Categorize commits
while IFS='|' read -r subject hash author date || [[ -n "$subject" ]]; do
  if [[ $subject == *"add"* ]] || [[ $subject == *"Add"* ]] || [[ $subject == *"feature"* ]]; then
    added+="- $subject ($author, $date) $hash\n"
  elif [[ $subject == *"fix"* ]] || [[ $subject == *"Fix"* ]]; then
    fixed+="- $subject ($author, $date) $hash\n"
  elif [[ $subject == *"remove"* ]] || [[ $subject == *"Remove"* ]] || [[ $subject == *"delete"* ]]; then
    removed+="- $subject ($author, $date) $hash\n"
  else
    changed+="- $subject ($author, $date) $hash\n"
  fi
done < "$tmp_file"

rm "$tmp_file"

# Create CHANGELOG.md
cat > CHANGELOG.md << EOF
# Changelog

## [$(date +'%Y-%m-%d')]
$(if [ -n "$added" ]; then echo -e "### Added\n$added"; fi)
$(if [ -n "$fixed" ]; then echo -e "### Fixed\n$fixed"; fi)
$(if [ -n "$changed" ]; then echo -e "### Changed\n$changed"; fi)
$(if [ -n "$removed" ]; then echo -e "### Removed\n$removed"; fi)
$(if [ -n "$added" ] || [ -n "$fixed" ] || [ -n "$changed" ] || [ -n "$removed" ]; then : ; else echo "### Other"; echo "No changes"; fi)
EOF

echo "CHANGELOG.md has been generated."