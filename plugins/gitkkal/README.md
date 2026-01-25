# gitkkal

A Claude Code plugin that automates Git workflows—branch naming, commit messages, and pull requests.

## Installation

```
/install gitkkal@bityoungjae-marketplace
```

## Commands

| Command | Description |
|---------|-------------|
| `/gitkkal:init` | Configure commit style and preferences |
| `/gitkkal:branch` | Create a branch based on your changes |
| `/gitkkal:commit` | Generate commits in your preferred style |
| `/gitkkal:pr` | Create or update a pull request |

## Commit Styles

- **conventional** - `feat(auth): add login support`
- **gitmoji** - `✨ Add login support`
- **simple** - `Add login support`

## Configuration

Stored in `.gitkkal/config.json`:

```json
{
  "language": "en",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true
}
```

## Requirements

- Git repository
- GitHub CLI (`gh`) for PR features
