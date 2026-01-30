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

## Quick Start

```
/gitkkal:init                      # Configure preferences (first time)
/gitkkal:branch [description]      # Create a new branch
/gitkkal:commit [hint]             # Commit changes
/gitkkal:pr [hint]                 # Create or update PR
```

## Workflow

The typical development workflow with gitkkal:

1. **Start work**
   ```
   /gitkkal:branch add user authentication
   ```
   Creates a new branch based on your changes or description.

2. **Commit changes**
   ```
   /gitkkal:commit
   ```
   Analyzes changes and creates commits in your configured style.

3. **Create PR**
   ```
   /gitkkal:pr
   ```
   Creates a pull request with auto-generated title and description.

4. **Update PR** (after additional commits)
   ```
   /gitkkal:pr emphasize refactoring
   ```
   Updates the existing PR with new changes.

## Commands

| Command | Description |
|---------|-------------|
| `/gitkkal:init` | Configure commit style and preferences |
| `/gitkkal:branch [description]` | Create a branch based on your changes or description |
| `/gitkkal:commit [hint]` | Generate commits in your preferred style |
| `/gitkkal:pr [hint]` | Create or update a pull request |

## Commit Styles

- **conventional** - `feat(auth): add login support`
- **gitmoji** - `✨ Add login support`
- **simple** - `Add login support`

## Configuration

Stored in `.gitkkal/config.json` (created via `/gitkkal:init`):

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
