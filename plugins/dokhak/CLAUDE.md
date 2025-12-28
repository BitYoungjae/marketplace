# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dokhak is a Claude Code plugin for creating self-learning resources. It uses a context-isolated pipeline architecture where specialized agents (researcher → writer → reviewer) generate technical documents while keeping main session context minimal. The project supports multiple domains (technology, history, science, arts, general) with adaptive content strategies.

## Architecture

### Document Writing Pipeline

```
Main Session
     │
     ├─▶ Task(researcher, haiku) ──▶ XML+MD research (<1000 tokens)
     │                                     │
     └─▶ Task(writer, opus) ◀──────────────┘
              │
              └─▶ docs/{XX}-{Y}-{slug}.md
                         │
     └─▶ Task(reviewer, haiku) ◀───────────┘
              │
              ├─▶ PASS → Update task.md
              └─▶ NEEDS_REVISION → Task(writer, opus) → Update task.md
```

### Project Initialization Pipeline

```
/init
     │
     ├─▶ Task(project-interviewer, opus) ──▶ persona.md + interview-data.md
     │                                              │
     ├─▶ Task(research-collector, haiku) ◀─────────┘
     │              │
     │              └─▶ research_xml
     │                      │
     └─▶ Task(structure-designer, opus) ◀──────────┘
                    │
                    └─▶ plan.md + task.md + project-context.md + CLAUDE.md
```

### Agent Roles

| Agent | Model | Input | Output |
|-------|-------|-------|--------|
| `project-interviewer` | opus | User conversation | persona.md, interview-data.md, project_metadata XML |
| `research-collector` | haiku | Topic + domain | research_summary XML |
| `structure-designer` | opus | Research + metadata | plan.md, task.md |
| `researcher` | haiku | Section info | XML+MD research (<1000 tokens) |
| `writer` | opus | Persona + research | docs/{file}.md directly |
| `reviewer` | haiku | Document + persona | review_result XML (PASS/NEEDS_REVISION) |

### Agent Communication Format

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

### Domain-Adaptive System

All agents adapt behavior based on domain:
- Domain profiles: `skills/domain-profiles/{domain}.md`
- Domain values: `technology`, `history`, `science`, `arts`, `general`
- Affects: search strategy, writing style, XML sections, terminology

## Key Files

### Plugin Definition
- `.claude-plugin/plugin.json` - Plugin metadata and version

### Commands (`commands/`)
YAML frontmatter fields:
- `allowed-tools` - Whitelisted tools for the command
- `argument-hint` - CLI argument format
- `model` - Default model override

### Agents (`agents/`)
YAML frontmatter fields:
- `tools` - Available tools for the agent
- `model` - Model to use (haiku/sonnet/opus)
- `permissionMode` - Usually `acceptEdits`
- `skills` - Referenced skills (e.g., `domain-profiles`)

### Skills (`skills/`)
- `project-scaffolder/` - Templates for plan.md, task.md, persona.md, CLAUDE.md
- `project-interview/` - Interview flow, conversation examples, interview-data template
- `domain-profiles/` - Domain-specific search and writing strategies

## Output File Naming

Documents use the pattern: `docs/{chapter}-{section}-{slug}.md`
- Chapter/section are zero-padded: `01-2-introduction.md`
- Slug is kebab-case from title

## Task Tracking

task.md uses `[ ]`/`[x]` checkboxes with session boundaries:
```markdown
<!-- Session 1: Part 1 Foundations -->
- [ ] 1.1 Introduction (8p)
- [x] 1.2 Core Concepts (7p)

<!-- Session 2: Part 1 Architecture -->
```

Session grouping: 3-5 sections or 20-40 pages per session.

## Page Count Convention

1 page ≈ 40-50 lines of content. Page allocations in plan.md should sum to total target.
