# changelog-generator

Generate a structured CHANGELOG.md from git history. Supports both bash script and `/generate-changelog` command patterns.

## Quick start

```bash
bash changelog.sh              # current directory, outputs CHANGELOG.md
bash changelog.sh /path/repo   # specific repo
bash changelog.sh /path/repo /tmp/out.md  # custom output path
```

## How it works

1. Finds the latest git tag (or falls back to first commit if no tags exist)
2. Extracts all commit messages since that tag
3. Auto-categorizes into: **Added** / **Fixed** / **Changed** / **Removed** / Other
4. Writes a properly formatted `CHANGELOG.md`

## Category mapping

| Keyword (commit starts with) | Section |
|---|---|
| `add`, `feat`, `new`, `create`, `introduce` | Added |
| `fix`, `patch`, `resolve`, `repair`, `close` | Fixed |
| `update`, `modify`, `refactor`, `improve`, `upgrade`, `bump`, `change` | Changed |
| `remove`, `delete`, `drop`, `deprecate`, `eliminate` | Removed |
| (anything else) | Other |

## Output format

```markdown
# Changelog

## Unreleased

_commits since v1.2.3_

### Added
- feat: add user profile endpoint

### Fixed
- fix: handle null response from API

### Changed
- update: bump deps

### Removed
- remove: deprecated v1 auth
```

## Dependencies

None. Pure bash. Requires only `git` and `grep`.

## Tested on

- claude-builders-bounty/claude-builders-bounty (sample output included)
