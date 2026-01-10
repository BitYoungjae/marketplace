---
name: plugin-research
description: "Neovim plugin ecosystem research. Use for: version compatibility, GitHub issues, breaking changes, plugin alternatives. Provides systematic investigation patterns for plugin-related problems."
allowed-tools: Read, Bash, Grep, Glob, WebSearch, WebFetch
---

# Plugin Research Skill

You are investigating Neovim plugin issues. Use this skill to systematically gather information about plugins, their versions, compatibility, and known issues.

## Core Philosophy

### GitHub-First Research

1. **Local state** is authoritative for what's installed
2. **GitHub** is authoritative for what's available and known issues
3. **Combine both** to form complete picture

### Investigation Priority

```
1. Local state (lazy-lock.json, plugin files)
2. GitHub repository (releases, tags, commits)
3. GitHub issues (bugs, breaking changes)
4. Community resources (Reddit, discussions)
```

## Quick Diagnostic Commands

```bash
# Get installed plugin version from lazy-lock.json
cat ~/.config/nvim/lazy-lock.json | grep -A2 '"PLUGIN_NAME"'

# Check if plugin is loaded
nvim --headless -c "lua print(package.loaded['PLUGIN_NAME'] ~= nil)" -c "qa" 2>&1

# Get plugin info from lazy.nvim
nvim --headless -c "lua local l=require('lazy.core.config');print(vim.inspect(l.plugins['PLUGIN_NAME']))" -c "qa" 2>&1

# List plugin files
ls -la ~/.local/share/nvim/lazy/PLUGIN_NAME/

# Check plugin's README for version requirements
cat ~/.local/share/nvim/lazy/PLUGIN_NAME/README.md | head -50
```

## Supporting Documents

| Document | Purpose |
|----------|---------|
| [github-patterns.md](github-patterns.md) | GitHub search queries, release extraction, CHANGELOG parsing |
| [ecosystem-knowledge.md](ecosystem-knowledge.md) | Plugin authors, categories, known conflicts, migration paths |

## Investigation Workflow

### Step 1: Gather Local State

```bash
# 1. Get commit hash from lock file
cat ~/.config/nvim/lazy-lock.json | grep -A2 '"plugin-name"'
# Output: "commit": "abc1234..."

# 2. Check plugin directory
ls ~/.local/share/nvim/lazy/plugin-name/

# 3. Find user's configuration for this plugin
grep -r "plugin-name" ~/.config/nvim --include="*.lua" -l
```

### Step 2: GitHub Research

Use patterns from [github-patterns.md](github-patterns.md):

1. **Find repository** - Search query templates
2. **Get latest version** - WebFetch releases page
3. **Check CHANGELOG** - Parse for breaking changes
4. **Search issues** - Find related bugs/problems

### Step 3: Compare Versions

```
Installed (local)     vs    Latest (GitHub)
─────────────────────────────────────────────
commit: abc1234             commit: def5678
tag: v1.2.0                 tag: v2.0.0
neovim: >= 0.9              neovim: >= 0.10
```

### Step 4: Form Recommendations

Based on comparison:
- **Up to date**: No action needed
- **Minor update**: Safe to upgrade, new features available
- **Major update**: Check breaking changes before upgrading
- **Breaking changes**: Provide migration guide

## Version Comparison Rules

### Semantic Versioning

| Change | Meaning | Risk Level |
|--------|---------|------------|
| MAJOR (X.0.0) | Breaking changes | HIGH - review before upgrade |
| MINOR (0.X.0) | New features | LOW - safe to upgrade |
| PATCH (0.0.X) | Bug fixes | NONE - always safe |

### Commit Hash Mapping

lazy.nvim uses commit hashes, not tags. To map:

```bash
# Find which tag contains a commit
git tag --contains abc1234

# Or check releases page on GitHub
# WebFetch: https://github.com/owner/repo/releases
```

## Output Format

Structure investigation reports using:

```xml
<investigation_report status="{OK|OUTDATED|BREAKING_CHANGES|ERROR}">
  <plugin>
    <name>{plugin-name}</name>
    <installed>{commit or tag}</installed>
    <latest>{from GitHub}</latest>
    <status>{comparison result}</status>
  </plugin>

  <changes_since_installed>
    <breaking>{list}</breaking>
    <features>{list}</features>
    <fixes>{list}</fixes>
  </changes_since_installed>

  <known_issues>
    {relevant GitHub issues}
  </known_issues>

  <compatibility>
    <neovim_required>{version}</neovim_required>
    <dependencies>{list}</dependencies>
    <conflicts>{known conflicts}</conflicts>
  </compatibility>

  <recommendations>
    {actionable advice}
  </recommendations>
</investigation_report>
```

## Common Investigation Patterns

### Pattern: Plugin Not Loading

```
Check order:
1. Is it in lazy-lock.json? (installed)
2. Is directory present in ~/.local/share/nvim/lazy/?
3. Is it enabled in config? (not disabled/cond=false)
4. Are dependencies satisfied?
5. Is it lazy-loaded and trigger not fired?
```

### Pattern: Plugin Broken After Update

```
Check order:
1. What version was installed before?
2. What version is installed now?
3. Are there breaking changes between versions?
4. Does new version require newer Neovim?
5. Did dependencies also need updating?
```

### Pattern: Plugin Conflict

```
Check order:
1. Which plugins are in conflict?
2. Do they modify same functionality? (keymaps, highlights, LSP)
3. Is load order correct?
4. Are there known conflicts in GitHub issues?
5. Can one be lazy-loaded to avoid conflict?
```
