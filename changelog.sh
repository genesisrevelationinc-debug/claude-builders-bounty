#!/bin/bash

# Get the previous tag
PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "v0.0.0")

# Get the commit message since last tag
COMMITS=$(git log --oneline "$PREV_TAG..HEAD")

# Initialize categories
ADDED=""
CHANGED=""
FIXED=""
REMOVED=""

# Process commits and categorize
while read -r line; do
  if [[ $line == *"fix:"* ]] || [[ $line == *"fixed"* ]]; then
    FIXED="$FIXED- $line"$'\n'
  elif [[ $line == *"add:"* ]] || [[ $line == *"feat:"* ]]; then
    ADDED="$ADDED- $line"$'\n'
  elif [[ $line == *"change:"* ]] || [[ $line == *"update:"* ]] || [[ $line == *"refactor:"* ]]; then
    CHANGED="$CHANGED- $line"$'\n'
  elif [[ $line == *"remove:"* ]] || [[ $line == *"revert:"* ]]; then
    REMOVED="$REMOVED- $line"$'\n'
  fi
done <<< "$COMMITS"

# Write the changelog
cat > CHANGELOG.md << EOF
$(if [ -n "$ADDED" ]; then echo "## Added"; echo -e "$ADDED"; fi)
$(if [ -n "$CHANGED" ]; then echo "## Changed"; echo -e "$CHANGED"; fi)
$(if [ -n "$FIXED" ]; then echo "## Fixed"; echo -e "$FIXED"; fi)
$(if [ -n "$REMOVED" ]; then echo "## Removed"; echo -e "$REMOVED"; fi)
EOF

echo "Changelog generated successfully!"