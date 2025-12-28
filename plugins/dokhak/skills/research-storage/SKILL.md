---
name: research-storage
description: "Research file storage conventions and templates for dokhak agents. Use when: (1) saving research results from research-collector or researcher agents, (2) reading cached research files, (3) checking if research exists for a section. Provides directory structure, file format templates, and naming conventions."
allowed-tools: Read, Write, Glob
---

# Research Storage Skill

This skill defines conventions for storing and retrieving research data collected by dokhak agents. Research files are cached to enable reuse and reduce redundant web searches.

## Directory Structure

```
project-root/
├── .research/                          # Research cache directory
│   ├── init/                           # /init command research
│   │   ├── summary.md                  # Structured research summary
│   │   └── sources.md                  # Source registry with reliability
│   │
│   └── sections/                       # /write command section research
│       ├── 01-1-introduction/
│       │   ├── research.md             # Section research results
│       │   └── sources.md              # Section sources
│       ├── 01-2-core-concepts/
│       │   ├── research.md
│       │   └── sources.md
│       └── {chapter}-{section}-{slug}/
│           ├── research.md
│           └── sources.md
```

## Naming Convention

### Section Directory Pattern

Format: `{chapter}-{section}-{slug}`

| Component | Format                | Example                         |
| --------- | --------------------- | ------------------------------- |
| chapter   | Zero-padded 2 digits  | `01`, `02`, `10`                |
| section   | Single digit          | `1`, `2`, `3`                   |
| slug      | Kebab-case from title | `introduction`, `core-concepts` |

**Examples**:

- Chapter 1, Section 2, "Core Concepts" → `01-2-core-concepts`
- Chapter 3, Section 1, "Getting Started" → `03-1-getting-started`
- Chapter 10, Section 3, "Advanced Patterns" → `10-3-advanced-patterns`

### Slug Generation Rules

1. Convert title to lowercase
2. Replace spaces with hyphens
3. Remove special characters (except hyphens)
4. Collapse multiple hyphens to single hyphen

```
"Core Concepts" → "core-concepts"
"What is React?" → "what-is-react"
"Setup & Installation" → "setup-installation"
```

## File Path Generation

### For /init Research

```
.research/init/summary.md
.research/init/sources.md
```

### For Section Research

```
.research/sections/{chapter}-{section}-{slug}/research.md
.research/sections/{chapter}-{section}-{slug}/sources.md
```

**Example**: Section 1.2 "Core Concepts"

```
.research/sections/01-2-core-concepts/research.md
.research/sections/01-2-core-concepts/sources.md
```

## File Format Templates

### summary.md (for /init)

```markdown
# Research Summary

> Generated: {YYYY-MM-DD}
> Topic: {topic}
> Domain: {domain}

## Key Concepts

### {Concept 1}

- **Definition**: {clear definition}
- **Importance**: {why it matters}
- **Source**: [{source name}]({url})

### {Concept 2}

- **Definition**: {clear definition}
- **Importance**: {why it matters}
- **Source**: [{source name}]({url})

## Learning Path

1. **Prerequisites**: {comma-separated list}
2. **Fundamentals**: {comma-separated list}
3. **Core Skills**: {comma-separated list}
4. **Advanced Topics**: {comma-separated list}

## Current Trends ({current_year})

- {trend 1 with source link}
- {trend 2 with source link}

## Domain-Specific Information

{domain-specific sections based on domain-profiles skill}
```

### sources.md (for both /init and sections)

```markdown
# Source Registry

> Section: {section_id or "init"}
> Generated: {YYYY-MM-DD}

## Primary Sources (High Reliability)

| Source | URL   | Type          | Last Verified |
| ------ | ----- | ------------- | ------------- |
| {name} | {url} | Official Docs | {YYYY-MM-DD}  |
| {name} | {url} | Official Docs | {YYYY-MM-DD}  |

## Secondary Sources (Medium Reliability)

| Source | URL   | Type     | Notes   |
| ------ | ----- | -------- | ------- |
| {name} | {url} | Tutorial | {notes} |
| {name} | {url} | Blog     | {notes} |

## Rejected Sources

| Source | Reason            |
| ------ | ----------------- |
| {name} | Outdated (year)   |
| {name} | Unreliable author |
```

### research.md (for sections)

````markdown
# Research: {Section Title}

> Section: {chapter}.{section} {title}
> Target Pages: {N}p
> Generated: {YYYY-MM-DD}

## Scope

{Brief description of what this section covers}

## Key Concepts

### {Concept 1}

- **Definition**: {definition}
- **Source**: [{name}]({url})

### {Concept 2}

- **Definition**: {definition}
- **Source**: [{name}]({url})

## Code Examples

### {Example Title}

```{language}
{code}
```

> Source: [{name}]({url})

## Common Pitfalls

1. **{Pitfall 1}**: {description}
   - **Cause**: {why it happens}
   - **Solution**: {how to avoid}

2. **{Pitfall 2}**: {description}
   - **Cause**: {why it happens}
   - **Solution**: {how to avoid}

## Practical Insights

- {insight 1 with source link}
- {insight 2 with source link}

## Subtopic Coverage

| Subtopic | Status   | Source            |
| -------- | -------- | ----------------- |
| {name}   | Complete | [{source}]({url}) |
| {name}   | Partial  | [{source}]({url}) |
| {name}   | Missing  | -                 |
````

## Usage Patterns

### Checking Existing Research

Use Glob to check if research exists before conducting new research:

```
Glob(".research/sections/{chapter}-{section}-{slug}/research.md")
```

Returns file path if exists, empty if not.

### Reading Research Files

When consuming research, read files directly in agent context:

```
Read(".research/init/summary.md")
Read(".research/sections/01-2-core-concepts/research.md")
```

### Saving Research Results

Agents should Write files following the templates above:

```
Write(".research/init/summary.md", content)
Write(".research/sections/01-2-core-concepts/research.md", content)
```

## Agent-Specific Guidelines

### research-collector Agent

- Outputs to: `.research/init/summary.md`, `.research/init/sources.md`
- Creates directory if not exists
- Returns confirmation only: `research_saved:.research/init/`

### researcher Agent

- Outputs to: `.research/sections/{id}/research.md`, `.research/sections/{id}/sources.md`
- Checks existing research via Subtopic Coverage table
- Appends to existing if partial coverage
- Returns confirmation only: `research_saved:{output_dir}`

### Consumer Agents (structure-designer, writer)

- Receive file paths in prompt
- Read files directly in their own context
- Do not modify research files

## Error Handling

| Scenario                       | Action                              |
| ------------------------------ | ----------------------------------- |
| `.research/` directory missing | Auto-create on first write          |
| Research file not found        | Conduct fresh research              |
| Read failure                   | Log warning, conduct fresh research |
| Write failure                  | Report error, do not update task.md |

## .gitignore Recommendation

Research files are regenerable and should typically be ignored:

```gitignore
# Research cache (regenerable)
.research/
```
