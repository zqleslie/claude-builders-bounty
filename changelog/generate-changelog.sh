#!/bin/bash
# generate-changelog.sh - Generate structured CHANGELOG.md from git history
# Usage: ./generate-changelog.sh [since-tag] [output-file]
# Default: fetches since last tag, outputs to CHANGELOG.md

set -euo pipefail

SINCE_TAG=${1:-$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)}
OUTPUT=${2:-CHANGELOG.md}

# Get commits since tag
COMMITS=$(git log "$SINCE_TAG"..HEAD --pretty=format:"%s" --no-merges)

if [ -z "$COMMITS" ]; then
  echo "No new commits since $SINCE_TAG"
  exit 0
fi

# Initialize categories
ADDED=""
FIXED=""
CHANGED=""
REMOVED=""
OTHER=""

while IFS= read -r line; do
  msg_lower=$(echo "$line" | tr '[:upper:]' '[:lower:]')
  
  if echo "$msg_lower" | grep -qiE '^(feat|feature|add|new)'; then
    ADDED="- ${line#*: }
$ADDED"
  elif echo "$msg_lower" | grep -qiE '^(fix|bugfix|bug|hotfix|patch)'; then
    FIXED="- ${line#*: }
$FIXED"
  elif echo "$msg_lower" | grep -qiE '^(chore|refactor|update|improve|style|perf|optimize)'; then
    CHANGED="- ${line#*: }
$CHANGED"
  elif echo "$msg_lower" | grep -qiE '^(remove|delete|drop|deprecat)'; then
    REMOVED="- ${line#*: }
$REMOVED"
  else
    OTHER="- $line
$OTHER"
  fi
done <<< "$COMMITS"

# Build changelog
{
  echo "# Changelog"
  echo ""
  echo "## [Unreleased] - $(date +%Y-%m-%d)"
  echo ""
  
  if [ -n "$ADDED" ]; then
    echo "### Added"
    echo -e "$ADDED"
    echo ""
  fi
  
  if [ -n "$FIXED" ]; then
    echo "### Fixed"
    echo -e "$FIXED"
    echo ""
  fi
  
  if [ -n "$CHANGED" ]; then
    echo "### Changed"
    echo -e "$CHANGED"
    echo ""
  fi
  
  if [ -n "$REMOVED" ]; then
    echo "### Removed"
    echo -e "$REMOVED"
    echo ""
  fi
  
  if [ -n "$OTHER" ]; then
    echo "### Other"
    echo -e "$OTHER"
    echo ""
  fi
} > "$OUTPUT"

echo "CHANGELOG written to $OUTPUT"
