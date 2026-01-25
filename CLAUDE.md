# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace repository (`bityoungjae-marketplace`) containing five plugins:

- **dokhak** - Self-learning resource creation with multi-agent pipeline
- **gitkkal** - Git workflow automation (branch naming, commits, PRs)
- **nvim-doctor** - Neovim configuration diagnostics
- **obsidian-blocks** - Visual content in Obsidian (LaTeX, Desmos, Mermaid, TikZ)
- **omarchy** - Theme management for Hyprland-based Linux desktop

## Repository Structure

```
bityoungjae-marketplace/
├── .claude-plugin/marketplace.json     # Marketplace registry (versions here)
├── plugins/
│   ├── dokhak/                         # Self-learning resource creation
│   │   ├── .claude-plugin/plugin.json  # Plugin metadata (version here)
│   │   ├── commands/                   # /init, /write, /continue, /status, /doctor
│   │   ├── agents/                     # Subagent definitions
│   │   └── skills/                     # Reusable skill modules
│   ├── gitkkal/                        # Git workflow automation
│   │   ├── skills/init-gitkkal/        # Configuration setup
│   │   ├── skills/branch/              # Branch naming
│   │   ├── skills/commit/              # Commit creation
│   │   └── skills/pr/                  # PR generation
│   ├── nvim-doctor/
│   ├── obsidian-blocks/
│   └── omarchy/
├── contexts/                           # Reference documentation
│   └── cc/                             # Claude Code docs (synced from official)
└── scripts/
    └── cc-docs-sync.sh                 # Syncs docs from code.claude.com
```

## Common Commands

### Documentation Sync

```bash
# Preview documentation sync (dry-run)
./scripts/cc-docs-sync.sh --dry-run

# Sync Claude Code docs from official source
./scripts/cc-docs-sync.sh

# Include prompt engineering docs
./scripts/cc-docs-sync.sh --include-prompt-engineering
```

### Plugin Installation (for testing)

```bash
/plugin marketplace add bityoungjae/marketplace
/plugin install dokhak@bityoungjae-marketplace
```

## Version Management

Update versions in **both** files when releasing:
- `.claude-plugin/marketplace.json` (marketplace registry)
- `plugins/{plugin}/.claude-plugin/plugin.json` (plugin level)

## Architecture

### Dokhak Agent Pipeline

The main plugin uses a multi-agent pipeline for document generation:

**Project Initialization** (`/init`):
```
project-interviewer (opus) → persona.md, interview-data.md
      ↓
research-collector (haiku) → research_xml
      ↓
structure-designer (opus) → plan.md, task.md, project-context.md, CLAUDE.md
```

**Document Writing** (`/write`, `/continue`):
```
researcher (haiku) → XML+MD research (<1000 tokens)
      ↓
writer (opus) → docs/{XX}-{Y}-{slug}.md
      ↓
reviewer (haiku) → PASS or NEEDS_REVISION → optional revision loop
```

### Agent Model Assignments

| Agent | Model | Purpose |
|-------|-------|---------|
| `project-interviewer` | opus | Conversational interview for persona creation |
| `research-collector` | haiku | Web research collection |
| `structure-designer` | opus | Curriculum and structure design |
| `researcher` | haiku | Section-specific research |
| `writer` | opus | Document generation |
| `reviewer` | haiku | Quality review |

### Plugin File Formats

**Commands** (`commands/*.md`): YAML frontmatter with `allowed-tools`, `argument-hint`, `model`

**Agents** (`agents/*.md`): YAML frontmatter with `tools`, `model`, `permissionMode`, `skills`

**Skills** (`skills/*/SKILL.md`): Entry point with `allowed-tools` and usage documentation

### Inter-Agent Communication

Agents exchange structured data using XML with Markdown content:
```xml
<research_result domain="technology">
  <authoritative_sources>
    - [Source](url)
  </authoritative_sources>
  <key_concepts>
    - **Term**: Explanation
  </key_concepts>
</research_result>
```

## Development Workflow

### Adding New Commands

1. Create `commands/{command-name}.md` with YAML frontmatter
2. Define the command workflow in markdown
3. Reference agents using `Task(subagent_type="{plugin}:{agent-name}", ...)`

### Adding New Agents

1. Create `agents/{agent-name}.md` with YAML frontmatter
2. Define input/output format using XML structure
3. Specify `tools`, `model`, `permissionMode`, and `skills` in frontmatter

### Adding Domain Profiles (dokhak)

1. Create `skills/domain-profiles/{domain}.md`
2. Include: Search Strategy, Special Fields, Terminology Policy, Content Structure
3. Update `SKILL.md` to list the new profile

## Key Conventions

- **Output file naming** (dokhak): `docs/{chapter}-{section}-{slug}.md` (zero-padded: `01-2-introduction.md`)
- **Page count**: 1 page ≈ 40-50 lines of content
- **Session grouping**: 3-5 sections or 20-40 pages per session in task.md
- **Task status**: `[ ]`/`[x]` checkboxes with `<!-- Session N: ... -->` boundaries
- **Domain values**: `technology`, `history`, `science`, `arts`, `language`, `general`

## Commit Message Style

This repository uses **Conventional Commits with Korean messages**:

```
<type>(<scope>): <subject-in-korean>

<body-in-korean>
```

- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`
- **Language**: Subject/body in Korean only (type/scope in English)
- **Forbidden**: Emojis, English in body, future tense, "Co-Authored-By" lines
