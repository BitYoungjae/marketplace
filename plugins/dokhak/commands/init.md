---
description: "Initialize a new learning resource project through interactive interview"
allowed-tools: Read, Write, Edit, Glob, WebSearch, WebFetch, Task, AskUserQuestion
argument-hint: ""
model: opus
---

# Initialize Project

Create a new self-learning resource project through interactive interview.

**Output files**: persona.md, interview-data.md, plan.md, task.md, project-context.md, CLAUDE.md

---

## Phase 1: Project Interview

<important>
The interviewer agent communicates DIRECTLY with the user.
- Launch the agent immediately without introduction
- Do NOT add transition messages ("Starting interview...", "Let me begin...")
- Do NOT summarize or rephrase the agent's output
- When interview completes, proceed to Phase 2 silently
</important>

```
Task(
  subagent_type="dokhak:project-interviewer",
  prompt="Conduct project initialization interview following project-interview skill."
)
```

The interviewer will:
1. Greet in user's language
2. Understand topic, motivation, background
3. Infer domain and audience level
4. Discuss scope and preferences
5. Generate persona.md and interview-data.md
6. Return project_metadata XML

---

## Phase 2-6: Background Processing

<important>
Execute all phases silently. No progress updates to user.
Show only the final Completion Report.
</important>

### Phase 2: Research Collection

```
Task(
  subagent_type="dokhak:research-collector",
  model="haiku",
  prompt="""
    <research_request>
      <topic>{topic}</topic>
      <domain>{domain}</domain>
      <audience_level>{audience}</audience_level>
    </research_request>
    Save to .research/init/ following research-storage skill.
  """
)
```

### Phase 3: Create plan.md

```
Task(
  subagent_type="dokhak:structure-designer",
  prompt="""
    <structure_request>
      <topic>{topic}</topic>
      <domain>{domain}</domain>
      <volume>{pages} pages</volume>
      <language>{lang}</language>
      <audience>{audience}</audience>
    </structure_request>
    <research_path>.research/init/</research_path>
    Create plan.md using project-scaffolder skill.
  """
)
```

### Phase 4: Create task.md

```
Task(
  subagent_type="dokhak:structure-designer",
  prompt="Read plan.md, create task.md with session boundaries using project-scaffolder skill."
)
```

### Phase 5: Create project-context.md

Read .research/init/summary.md and create project-context.md using project-context-template.md.

Include: research results, domain context, environment notes, prerequisites.

### Phase 6: Create CLAUDE.md

Create CLAUDE.md using claude-md-template.md with:
- Project overview (topic, domain, audience)
- Document structure guidelines
- Writing persona summary
- Domain-specific guidelines

---

## Completion Report

```
=== Project Initialization Complete ===

Topic: {topic}
Domain: {domain}
Scope: {pages} pages in {lang}
Audience: {audience}

Files Created:
  ✓ persona.md
  ✓ interview-data.md
  ✓ plan.md - {X} Parts, {Y} Chapters, {Z} Sections
  ✓ task.md - {N} sessions
  ✓ project-context.md
  ✓ CLAUDE.md

Next: Run /write to start first section
```

---

## Variable Reference

| Variable      | Source                | Values                                      |
| ------------- | --------------------- | ------------------------------------------- |
| `topic`       | Interview             | User's learning goal                        |
| `domain`      | Inferred + confirmed  | technology, history, science, arts, general |
| `pages`       | Interview             | 50 (small), 100 (medium), 200 (large)       |
| `lang`        | Auto-detected         | ko, en, etc.                                |
| `audience`    | Inferred              | beginner, intermediate, advanced            |
| `environment` | Interview (tech only) | linux, macos, windows, cross-platform       |

---

## Error Handling

| Error | Action |
|-------|--------|
| Research yields limited results | Proceed with available data, note gaps |
| File creation fails | Report error, continue with others |
| persona.md exists | Ask user: overwrite or merge |
