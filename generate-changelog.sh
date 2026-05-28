   COMMIT_RANGE="${LAST_TAG}..HEAD"
   echo "Generating changelog from commits since ${LAST_TAG}..."
   COMMIT_RANGE="HEAD"
   echo "Generating changelog from all commits..."
   # Skip empty lines
   [ -z "$line" ] && continue
   
   HASH=$(echo "$line" | cut -d' ' -f1)
   MESSAGE=$(echo "$line" | cut -d' ' -f2-)
   
   # Categorize based on conventional commit prefixes
   if echo "$MESSAGE" | grep -qiE '^feat(\([^)]*\))?:'; then
       ADDED="${ADDED}- ${MESSAGE} (${HASH:0:7})\n"
   elif echo "$MESSAGE" | grep -qiE '^fix(\([^)]*\))?:'; then
       FIXED="${FIXED}- ${MESSAGE} (${HASH:0:7})\n"
   elif echo "$MESSAGE" | grep -qiE '^(refactor|perf|style)(\([^)]*\))?:'; then
       CHANGED="${CHANGED}- ${MESSAGE} (${HASH:0:7})\n"
   elif echo "$MESSAGE" | grep -qiE '^(remove|delete|drop)(\([^)]*\))?:'; then
       REMOVED="${REMOVED}- ${MESSAGE} (${HASH:0:7})\n"
   else
       OTHER="${OTHER}- ${MESSAGE} (${HASH:0:7})\n"
   fi
   echo "# Changelog"
   echo ""
   
   if [ -n "$LAST_TAG" ]; then
       echo "## Unreleased (since ${LAST_TAG})"
   else
       echo "## Unreleased"
   fi
   echo ""
   
   if [ -n "$ADDED" ]; then
       echo "### Added"
       echo ""
       printf "$ADDED"
       echo ""
   fi
   
   if [ -n "$FIXED" ]; then
       echo "### Fixed"
       echo ""
       printf "$FIXED"
       echo ""
   fi
   
   if [ -n "$CHANGED" ]; then
       echo "### Changed"
       echo ""
       printf "$CHANGED"
       echo ""
   fi
   
   if [ -n "$REMOVED" ]; then
       echo "### Removed"
       echo ""
       printf "$REMOVED"
       echo ""
   fi
   
   if [ -n "$OTHER" ]; then
       echo "### Other"
       echo ""
       printf "$OTHER"
       echo ""
   fi
   
   echo "---"
   echo ""
   echo "*Generated automatically from git history*"
   