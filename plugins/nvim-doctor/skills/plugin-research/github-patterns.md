# GitHub Research Patterns

This document provides search query templates and extraction patterns for investigating Neovim plugins on GitHub.

## Repository Discovery

### WebSearch Query Templates

```
# Find official repository (most reliable)
"{plugin-name} neovim site:github.com"

# Find with known author
"folke/{plugin-name} github"
"nvim-lua/{plugin-name} github"

# Find when name is ambiguous
"{plugin-name} neovim plugin github -awesome-neovim"

# Find forks/alternatives
"{plugin-name} alternative neovim"
```

### Common Repository Patterns

| Author | URL Pattern | Notable Plugins |
|--------|-------------|-----------------|
| folke | `github.com/folke/{name}` | lazy.nvim, which-key, noice, snacks |
| echasnovski | `github.com/echasnovski/mini.{name}` | mini.nvim ecosystem |
| nvim-lua | `github.com/nvim-lua/{name}` | plenary.nvim |
| nvim-telescope | `github.com/nvim-telescope/{name}` | telescope.nvim |
| hrsh7th | `github.com/hrsh7th/{name}` | nvim-cmp ecosystem |
| neovim | `github.com/neovim/{name}` | nvim-lspconfig |

## Version Information Extraction

### WebFetch Targets

```
# Releases page (best for version history)
https://github.com/{owner}/{repo}/releases

# Tags page (if no releases)
https://github.com/{owner}/{repo}/tags

# CHANGELOG file
https://github.com/{owner}/{repo}/blob/main/CHANGELOG.md
https://github.com/{owner}/{repo}/blob/master/CHANGELOG.md

# README for requirements
https://github.com/{owner}/{repo}/blob/main/README.md
```

### Extracting Version Requirements

Look for these patterns in README:

```markdown
## Requirements
- Neovim >= 0.10.0
- [plenary.nvim](...)

## Prerequisites
Neovim 0.9+ required
```

### Parsing CHANGELOG

Common CHANGELOG formats:

```markdown
# Format 1: Keep a Changelog
## [2.0.0] - 2024-01-15
### Breaking Changes
- Removed deprecated API

## [1.5.0] - 2024-01-01
### Added
- New feature

# Format 2: Release Notes Style
## v2.0.0
**BREAKING**: Changed default behavior

## v1.5.0
- Added new feature

# Format 3: Commit-style
### 2024-01-15
* BREAKING: Renamed function
* feat: Added capability
```

## Issue Search Patterns

### WebSearch Queries

```
# Find breaking change issues
"site:github.com/{owner}/{repo}/issues breaking"

# Find specific error
"site:github.com/{owner}/{repo}/issues {error-message}"

# Find compatibility issues
"site:github.com/{owner}/{repo}/issues neovim 0.10"

# Find recent bugs
"site:github.com/{owner}/{repo}/issues is:open label:bug"
```

### Issue URL Patterns

```
# All issues
https://github.com/{owner}/{repo}/issues

# Open issues only
https://github.com/{owner}/{repo}/issues?q=is%3Aopen

# Issues with label
https://github.com/{owner}/{repo}/issues?q=label%3Abug

# Search in issues
https://github.com/{owner}/{repo}/issues?q={search-term}
```

## Commit Comparison

### Finding Changes Between Versions

```
# Compare tags
https://github.com/{owner}/{repo}/compare/v1.0.0...v2.0.0

# Compare commits
https://github.com/{owner}/{repo}/compare/abc1234...def5678

# Commits since tag
https://github.com/{owner}/{repo}/commits/main?since=2024-01-01
```

### Mapping Commit to Tag

```bash
# If you have the repo cloned locally
cd ~/.local/share/nvim/lazy/{plugin}
git describe --tags --exact-match HEAD 2>/dev/null || git rev-parse --short HEAD

# Check if commit is in a release
git tag --contains {commit-hash}
```

## Breaking Changes Detection

### Keywords to Search

```
breaking, BREAKING
deprecated, DEPRECATED
removed, REMOVED
renamed, RENAMED
changed default
no longer supports
requires neovim
minimum version
migration guide
upgrade guide
```

### Common Breaking Change Patterns

| Pattern | Example | Impact |
|---------|---------|--------|
| Function renamed | `setup()` → `configure()` | Config update needed |
| Option removed | `use_icons` option gone | Remove from config |
| Default changed | `border = "none"` → `border = "single"` | May affect appearance |
| Dependency added | Now requires nvim-web-devicons | Install dependency |
| Neovim version bump | 0.9 → 0.10 required | Upgrade Neovim |

## Plugin Dependencies

### Finding Dependencies

Check these files in plugin repo:

```
# lazy.nvim style
lua/{plugin}/init.lua → look for require()

# Package manifest (rare)
.lazy.lua
rockspec file

# README dependencies section
README.md → "Requirements" or "Dependencies"
```

### Common Dependency Chains

```
telescope.nvim
└── plenary.nvim

nvim-cmp
├── cmp-nvim-lsp
├── cmp-buffer
├── cmp-path
└── LuaSnip (or other snippet engine)

mason.nvim
├── mason-lspconfig.nvim
└── nvim-lspconfig
```

## WebFetch Prompts

### For Releases Page

```
Extract from this GitHub releases page:
1. Latest version tag
2. Release date
3. Whether there are breaking changes mentioned
4. Key changes summary
```

### For CHANGELOG

```
Extract from this CHANGELOG:
1. All versions released after {installed_version}
2. Any breaking changes between versions
3. New features added
4. Bug fixes relevant to {user_problem}
```

### For README

```
Extract from this README:
1. Minimum Neovim version required
2. Required dependencies/plugins
3. Optional dependencies
4. Any known conflicts mentioned
```

### For Issues Page

```
Find issues related to:
1. Error message: {error}
2. Neovim version compatibility
3. Conflicts with {other_plugin}
Return: issue number, title, status (open/closed), and brief summary
```
