# gitkkal

> *Named after Korean "기깔나다" (giggal-nada), meaning stylish or impressive.*

[한국어](./README.ko.md)

A Claude Code plugin that automates Git workflows—branch naming, commit messages, and pull requests.

## Installation

First, add the marketplace (one-time setup):

```
/plugin marketplace add bityoungjae/marketplace
```

Then install the plugin:

```
/plugin install gitkkal@bityoungjae-marketplace
```

## Commands

| Command | Description |
|---------|-------------|
| `/gitkkal:init-gitkkal` | Configure commit style and preferences |
| `/gitkkal:branch` | Create a branch based on your changes |
| `/gitkkal:commit` | Generate commits in your preferred style |
| `/gitkkal:pr` | Create or update a pull request |

## Commit Styles

- **conventional** - `feat(auth): add login support`
- **gitmoji** - `✨ Add login support`
- **simple** - `Add login support`

## Configuration

Stored in `.gitkkal/config.json` (created via `/gitkkal:init-gitkkal`):

```json
{
  "language": "en",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": false
}
```

| Option | Values | Description |
|--------|--------|-------------|
| `language` | `"en"`, `"ko"` | Commit message language |
| `commitPattern` | `"conventional"`, `"gitmoji"`, `"simple"` | Commit message format |
| `branchPattern` | `"type/description"`, `"description-only"` | Branch naming style |
| `splitCommits` | `true`, `false` | Split changes into semantic commits |
| `askOnAmbiguity` | `true`, `false` | Ask user when commit classification is unclear |
| `createPrTemplate` | `true`, `false` | Create `.github/PULL_REQUEST_TEMPLATE.md` on init |

If no config file exists, default settings are used automatically.

## Requirements

- Git repository
- GitHub CLI (`gh`) for PR features
