# Generate Changelog

<skill>
<name>Generate Changelog</name>
<description>Generates a structured CHANGELOG.md from git history</description>
<author>claude://view-iconic/1</author>
</skill>

<command>
  <name>generate-changelog</name>
  <description>Generate a structured CHANGELOG.md from git history</description>
  <action>
    <type>run-script</type>
    <script>
#!/bin/bash

# Get the previous tag
PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "v0.0.0")

# Get commit messages since last tag
COMMITS=$(git log --oneline "$PREV_TAG..HEAD" --pretty=format:"%s")

# Categorize commits
ADDED=""
CHANGED=""
FIXED=""
REMOVED=""

echo "$COMMITS" | while read -r line; do
  if [[ $line == *"fix:"* ]] || [[ $line == *"fixed"* ]]; then FIXED="$FIXED- $line\n"; fi
  if [[ $line == *"add:"* ]] || [[ $line == *"feat:"* ]]; then ADDED="$ADDED- $line\n"; fi
  if [[ $line == *"change:"* ]] || [[ $line == *"refactor:"* ]] || [[ $line == *"update:"* ]]; then CHANGED="$CHANGED- $line\n"; fi
  if [[ $line == *"remove:"* ]] || [[ $line == *"revert:"* ]]; then REMOVED="$REMOVED- $line\n"; fi
done

echo -e "## Added\n$ADDED\n## Changed\n$CHANGED\n## Fixed\n$FIXED\n## Removed\n$REMOVED" > CHANGELOG.md
    </script>
  </action>
</command>
</skill>