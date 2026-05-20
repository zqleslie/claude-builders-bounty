# Generate CHANGELOG from Git History

Automatically generates a structured CHANGELOG.md from git commit history.

## Setup (3 steps)

```bash
# 1. Clone and make executable
chmod +x changelog/generate-changelog.sh

# 2. Run (defaults to since last tag)
./changelog/generate-changelog.sh

# 3. Or specify a tag
./changelog/generate-changelog.sh v1.0.0
```

## Output

Categories commits into: Added / Fixed / Changed / Removed / Other based on commit message prefixes.

## Sample Output

```
# Changelog

## [Unreleased] - 2026-05-20

### Added
- Support for markdown export
- Add user authentication

### Fixed
- Fix login redirect loop
- Bug: prevent double submission
```
