#!/usr/bin/env bash
# changelog.sh — Generate a structured CHANGELOG.md from git history
# Usage: bash changelog.sh [REPO_DIR] [OUTPUT_FILE]
#   REPO_DIR   : path to a git repo (default: current dir)
#   OUTPUT_FILE: output changelog path (default: CHANGELOG.md)

set -eo pipefail

REPO_DIR="${1:-.}"
OUTPUT="${2:-CHANGELOG.md}"

cd "$REPO_DIR"

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: not a git repository" >&2
  exit 1
fi

# Get the latest tag; if none, use the first commit
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD | head -1)

if [ "$LAST_TAG" = "$(git rev-list --max-parents=0 HEAD | head -1)" ] && ! git describe --tags --abbrev=0 &>/dev/null; then
  # No tags exist — use all commits
  COMMITS=$(git log --pretty=format:"%s" --reverse)
  RANGE_DESC="all commits (no tags found)"
else
  COMMITS=$(git log "${LAST_TAG}.." --pretty=format:"%s" --reverse)
  RANGE_DESC="commits since ${LAST_TAG}"
fi

if [ -z "$COMMITS" ]; then
  echo "No new commits found (${RANGE_DESC})" >&2
  exit 0
fi

# Temp files for each category
ADDED_FILE=$(mktemp)
FIXED_FILE=$(mktemp)
CHANGED_FILE=$(mktemp)
REMOVED_FILE=$(mktemp)
OTHER_FILE=$(mktemp)
trap 'rm -f "$ADDED_FILE" "$FIXED_FILE" "$CHANGED_FILE" "$REMOVED_FILE" "$OTHER_FILE"' EXIT

# Categorize each commit
while IFS= read -r line; do
  [ -z "$line" ] && continue
  
  matched=false
  if echo "$line" | grep -qiE "^(add|feat|new|create|introduce)"; then
    echo "$line" >> "$ADDED_FILE"
    matched=true
  fi
  if [ "$matched" = false ] && echo "$line" | grep -qiE "^(fix|patch|resolve|repair|close)"; then
    echo "$line" >> "$FIXED_FILE"
    matched=true
  fi
  if [ "$matched" = false ] && echo "$line" | grep -qiE "^(update|modify|refactor|improve|upgrade|bump|change)"; then
    echo "$line" >> "$CHANGED_FILE"
    matched=true
  fi
  if [ "$matched" = false ] && echo "$line" | grep -qiE "^(remove|delete|drop|deprecate|eliminate)"; then
    echo "$line" >> "$REMOVED_FILE"
    matched=true
  fi
  if [ "$matched" = false ]; then
    echo "$line" >> "$OTHER_FILE"
  fi
done <<< "$COMMITS"

# Count items (handle empty files)
count_lines() {
  if [ -s "$1" ]; then
    wc -l < "$1" | tr -d ' '
  else
    echo "0"
  fi
}

N_ADDED=$(count_lines "$ADDED_FILE")
N_FIXED=$(count_lines "$FIXED_FILE")
N_CHANGED=$(count_lines "$CHANGED_FILE")
N_REMOVED=$(count_lines "$REMOVED_FILE")
N_OTHER=$(count_lines "$OTHER_FILE")

# Generate CHANGELOG.md
{
  echo "# Changelog"
  echo ""
  echo "## Unreleased"
  echo ""
  echo "_${RANGE_DESC}_"
  echo ""
  
  if [ "$N_ADDED" -gt 0 ]; then
    echo "### Added"
    echo ""
    while IFS= read -r item; do
      echo "- ${item}"
    done < "$ADDED_FILE"
    echo ""
  fi
  
  if [ "$N_FIXED" -gt 0 ]; then
    echo "### Fixed"
    echo ""
    while IFS= read -r item; do
      echo "- ${item}"
    done < "$FIXED_FILE"
    echo ""
  fi
  
  if [ "$N_CHANGED" -gt 0 ]; then
    echo "### Changed"
    echo ""
    while IFS= read -r item; do
      echo "- ${item}"
    done < "$CHANGED_FILE"
    echo ""
  fi
  
  if [ "$N_REMOVED" -gt 0 ]; then
    echo "### Removed"
    echo ""
    while IFS= read -r item; do
      echo "- ${item}"
    done < "$REMOVED_FILE"
    echo ""
  fi
  
  if [ "$N_OTHER" -gt 0 ]; then
    echo "### Other"
    echo ""
    while IFS= read -r item; do
      echo "- ${item}"
    done < "$OTHER_FILE"
    echo ""
  fi
} > "$OUTPUT"

echo "CHANGELOG.md generated: ${OUTPUT}"
echo "  - ${N_ADDED} Added, ${N_FIXED} Fixed, ${N_CHANGED} Changed, ${N_REMOVED} Removed, ${N_OTHER} Other"
echo "  - Range: ${RANGE_DESC}"
