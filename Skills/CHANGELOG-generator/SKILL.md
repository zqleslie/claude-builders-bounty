# SKILL: Generate a structured CHANGELOG.md from git history

Use this skill to automatically generate a well-structured CHANGELOG.md file from a project's git commit history.

## Activation

In Claude Code, run: `/generate-changelog` or manually execute the script below.

## Execution

```bash
bash changelog.sh [REPO_DIR] [OUTPUT_FILE]
```

- `REPO_DIR`: Path to the git repository (defaults to current directory)
- `OUTPUT_FILE`: Output file path (defaults to `CHANGELOG.md` in current directory)

## What it does

1. **Detects range**: Finds the latest git tag and extracts all commits since then. Falls back to all commits if no tags exist.
2. **Auto-categorizes**: Each commit message is classified by its prefix into one of five sections:
   - **Added** — `add`, `feat`, `new`, `create`, `introduce`
   - **Fixed** — `fix`, `patch`, `resolve`, `repair`, `close`
   - **Changed** — `update`, `modify`, `refactor`, `improve`, `upgrade`, `bump`, `change`
   - **Removed** — `remove`, `delete`, `drop`, `deprecate`, `eliminate`
   - **Other** — anything that doesn't match above patterns
3. **Outputs**: Writes a properly formatted Markdown CHANGELOG.md with sections for each category.

## Constraints

- Zero dependencies — pure bash, works anywhere with `git` and `grep`
- Handles repos with no tags gracefully
- Idempotent — safe to re-run, overwrites existing CHANGELOG.md
