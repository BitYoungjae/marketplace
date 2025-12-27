# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace repository (`bityoungjae-marketplace`) containing the **dokhak** plugin - a self-learning resource creation tool. The plugin uses a context-isolated pipeline architecture where specialized agents generate technical documents while keeping main session context minimal.

## Repository Structure

```
dokhak/
├── .claude-plugin/marketplace.json    # Marketplace definition
├── plugins/dokhak/                    # Main plugin
│   ├── .claude-plugin/plugin.json     # Plugin metadata (version here)
│   ├── commands/                      # Slash commands (/init-project, /write-doc, etc.)
│   ├── agents/                        # Subagent definitions (researcher, writer, reviewer)
│   ├── skills/                        # Reusable skill modules
│   │   ├── project-scaffolder/        # Templates for plan.md, task.md, persona.md
│   │   ├── project-interview/         # Interview flow and conversation patterns
│   │   └── domain-profiles/           # Domain-specific strategies (technology, history, etc.)
│   └── contexts/                      # Reference documentation
```

## Architecture

### Agent Pipeline

The plugin uses a multi-agent pipeline for document generation:

1. **Project Initialization** (`/init-project`):
   ```
   project-interviewer (opus) → persona.md, interview-data.md
         ↓
   research-collector (haiku) → research_xml
         ↓
   structure-designer (opus) → plan.md, task.md, project-context.md, CLAUDE.md
   ```

2. **Document Writing** (`/write-doc`, `/continue-session`):
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

### File Formats

**Commands** (`commands/*.md`): YAML frontmatter with:
- `allowed-tools`: Whitelisted tools
- `argument-hint`: CLI argument format
- `model`: Default model override

**Agents** (`agents/*.md`): YAML frontmatter with:
- `tools`: Available tools
- `model`: haiku/sonnet/opus
- `permissionMode`: Usually `acceptEdits`
- `skills`: Referenced skills

**Skills** (`skills/*/SKILL.md`): Entry point with `allowed-tools` and usage documentation.

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

### Version Updates

Update version in both files when releasing:
- `plugins/dokhak/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`

### Adding New Commands

1. Create `commands/{command-name}.md` with YAML frontmatter
2. Define the command workflow in markdown
3. Reference agents using `Task(subagent_type="dokhak:{agent-name}", ...)`

### Adding New Agents

1. Create `agents/{agent-name}.md` with YAML frontmatter
2. Define input/output format using XML structure
3. Specify `tools`, `model`, `permissionMode`, and `skills` in frontmatter

### Adding Domain Profiles

1. Create `skills/domain-profiles/{domain}.md`
2. Include: Search Strategy, Special Fields, Terminology Policy, Content Structure
3. Update `SKILL.md` to list the new profile

## Key Conventions

- **Output file naming**: `docs/{chapter}-{section}-{slug}.md` (zero-padded: `01-2-introduction.md`)
- **Page count**: 1 page ≈ 40-50 lines of content
- **Session grouping**: 3-5 sections or 20-40 pages per session in task.md
- **Task status**: `[ ]`/`[x]` checkboxes with `<!-- Session N: ... -->` boundaries
- **Domain values**: `technology`, `history`, `science`, `arts`, `general`
