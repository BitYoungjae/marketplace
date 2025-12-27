---
description: "Initialize a new learning resource project through interactive interview. Creates plan.md, task.md, persona.md, project-context.md, interview-data.md, and CLAUDE.md. Supports multiple domains: technology, history, science, arts, and general."
allowed-tools: Read, Write, Edit, Bash, Glob, WebSearch, WebFetch, Task, AskUserQuestion
argument-hint: ""
model: opus
---

# Initialize Self-Learning Resource Project

Interactive interview-based project initialization for learning resources.

---

## Phase 1: Project Interview

Have a natural conversation with the learner to understand their needs.

### 1.1 Launch Project Interviewer

```
Task(
  subagent_type="dokhak:project-interviewer",
  model="opus",
  description="Conduct project initialization interview",
  prompt="""
    Conduct an interview for project initialization.

    Following the project-interview skill guidelines:
    1. Understand the learner through natural conversation
    2. Generate persona.md and interview-data.md
    3. Return results in project_metadata XML format

    Use persona-template.md from project-scaffolder skill when creating persona.md.
  """
)
```

### 1.2 Interview Goals

Through natural conversation, understand:

| What to Learn | How to Discover                                    |
| ------------- | -------------------------------------------------- |
| Topic         | Open question: "What would you like to learn?"     |
| Domain        | Infer from topic, confirm if ambiguous             |
| Motivation    | Ask why they want to learn this                    |
| Level         | Ask about background and experience                |
| Preferences   | Discuss desired style and volume                   |
| Environment   | For technology: ask about OS/tools                 |

### 1.3 Interview Completion

When enough information is gathered:

1. Summarize the profile conversationally
2. Get learner confirmation
3. Apply any corrections
4. Generate outputs (persona.md, interview-data.md, project_metadata XML)

Store the returned `project_metadata` XML for subsequent phases.

---

## Phase 2: Research Collection

Use the research-collector subagent with domain-adaptive strategy.

```
Task(
  subagent_type="dokhak:research-collector",
  model="haiku",
  description="Research {topic} resources",
  prompt="""
    Topic: {topic}
    Domain: {domain}

    Conduct research appropriate for this domain using the domain-profiles skill.
    Return results in research_summary XML format.
  """
)
```

Store the research result as `research_xml`.

---

## Phase 3: Create plan.md

Use the structure-designer subagent to create plan.md.

```
Task(
  subagent_type="dokhak:structure-designer",
  model="opus",
  description="Create plan.md structure",
  prompt="""
    Topic: {topic} | Domain: {domain} | Volume: {pages}p | Language: {lang}
    Audience: {audience} | Environment: {environment}
    Research: {research_xml}

    Create plan.md using the project-scaffolder skill as reference.
  """
)
```

---

## Phase 4: Create task.md

Use the structure-designer subagent to create task.md with session distribution.

```
Task(
  subagent_type="dokhak:structure-designer",
  model="opus",
  description="Create task.md with sessions",
  prompt="""
    Read plan.md and create task.md using the project-scaffolder skill as reference.
    Split into sessions and mark session boundaries with HTML comments.
  """
)
```

---

## Phase 5: Create project-context.md

Create project-context.md with research results and domain-specific information.

```
Using project-context-template.md from project-scaffolder skill as reference,

Create project-context.md with:
- Research results from Phase 2 (authoritative sources)
- Domain-specific context from {domain_specific} XML
- Environment-specific notes (if technology)
- Version information (if applicable)
- Learning path recommendations
- Prerequisites summary
```

---

## Phase 6: Create CLAUDE.md

Create CLAUDE.md using claude-md-template.md from project-scaffolder skill as reference:

- Project overview (topic, domain, audience)
- Key skills and agents references (/write-doc, researcher, writer)
- Document structure guidelines
- Writing persona summary (from persona.md)
- Domain-specific guidelines (from domain-profiles)
- Quality standards

---

## Completion Report

After all phases complete, provide a summary:

```
=== Project Initialization Complete ===

Topic: {topic}
Domain: {domain}
Scope: {pages} pages in {lang}
Audience: {audience}
Environment: {environment} (if applicable)

Files Created:
  ✓ persona.md - Writer/Reader personas with {domain} guidelines
  ✓ interview-data.md - Interview transcript and insights
  ✓ plan.md - X Parts, Y Chapters, Z Sections
  ✓ task.md - N sessions
  ✓ project-context.md - Research and context
  ✓ CLAUDE.md - Project guidelines

Next Steps:
  1. Review plan.md structure
  2. Review persona.md for accuracy
  3. Run /write-doc to start writing first section
  4. Use /status to track progress
```

---

## Variable Mapping

Interview collects and maps the following variables:

| Variable      | Source                     | Notes                                       |
| ------------- | -------------------------- | ------------------------------------------- |
| `topic`       | Conversation               | What the learner wants to learn             |
| `domain`      | Inferred + confirmed       | technology, history, science, arts, general |
| `pages`       | Conversation               | 50 (small), 100 (medium), 200 (large)       |
| `lang`        | Detected from conversation | ko, en, etc.                                |
| `audience`    | Inferred from background   | beginner, intermediate, advanced            |
| `environment` | Conversation (tech only)   | linux, macos, windows, cross-platform       |
| `motivation`  | Conversation               | Why they want to learn                      |
| `preferences` | Conversation               | Learning style preferences                  |

---

## Error Recovery

- If research yields limited results: Proceed with available information, note gaps
- If page allocation doesn't sum correctly: Adjust proportionally
- If any file creation fails: Report specific error, continue with others
- If persona.md already exists: Ask user whether to overwrite or merge
