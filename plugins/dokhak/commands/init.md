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

<communication_rules>
CRITICAL: The interviewer agent communicates DIRECTLY with the user.

- Do NOT add any introduction before launching the interviewer
- Do NOT add transition messages like "Starting interview..." or "Let me start the interview"
- Do NOT summarize or rephrase the agent's output after it completes
- Let the conversation flow naturally as if the interviewer IS the main assistant
- The user should feel they are talking to ONE entity, not being handed off to another

When the interview completes, silently proceed to Phase 2 without announcing completion.
</communication_rules>

### Launch Project Interviewer

```
Task(
  subagent_type="dokhak:project-interviewer",
  model="opus",
  description="Conduct project initialization interview",
  prompt="""
    <role>
    You are a learning experience designer having a direct conversation with the learner.
    You ARE the main assistant - not a separate tool or delegated agent.
    </role>

    <task>
    Conduct an interview for project initialization following the project-interview skill.
    </task>

    <instructions>
    1. Start immediately with your multilingual greeting - no preamble
    2. Have a natural conversation to understand the learner
    3. Generate persona.md and interview-data.md
    4. Return results in project_metadata XML format
    </instructions>

    <output_format>
    Use persona-template.md from project-scaffolder skill when creating persona.md.
    </output_format>
  """
)
```

### Interview Goals

Through natural conversation, understand:

| What to Learn | How to Discover                                |
| ------------- | ---------------------------------------------- |
| Topic         | Open question: "What would you like to learn?" |
| Domain        | Infer from topic, confirm if ambiguous         |
| Motivation    | Ask why they want to learn this                |
| Level         | Ask about background and experience            |
| Preferences   | Discuss desired style and volume               |
| Environment   | For technology: ask about OS/tools             |

Store the returned `project_metadata` XML for subsequent phases.

---

## Phase 2-6: Background Processing

<background_processing_rules>
After the interview completes, execute Phases 2-6 silently in sequence.

- Do NOT announce each phase to the user (e.g., "Now collecting research...")
- Do NOT show progress updates between phases
- Process all phases quietly, then show only the final Completion Report
- If any phase fails, note it in the report rather than interrupting with error messages
  </background_processing_rules>

### Phase 2: Research Collection

Use the research-collector subagent with domain-adaptive strategy.
Research results are saved to `.research/init/` directory.

```
Task(
  subagent_type="dokhak:research-collector",
  model="haiku",
  description="Research {topic} resources",
  prompt="""
    <research_request>
      <topic>{topic}</topic>
      <domain>{domain}</domain>
      <audience_level>{audience}</audience_level>
    </research_request>

    Conduct research appropriate for this domain using the domain-profiles skill.
    Save results to .research/init/ following research-storage skill conventions.
    Return confirmation message only (not the research content).
  """
)
```

Agent returns confirmation like:
```
research_saved:.research/init/
sources:12
concepts:8
```

**IMPORTANT**: Do NOT store the research content. The confirmation message is sufficient.

---

### Phase 3: Create plan.md

Use the structure-designer subagent to create plan.md.
Pass file PATHS only - structure-designer reads files directly.

```
Task(
  subagent_type="dokhak:structure-designer",
  model="opus",
  description="Create plan.md structure",
  prompt="""
    <structure_request>
      <topic>{topic}</topic>
      <domain>{domain}</domain>
      <volume>{pages} pages</volume>
      <language>{lang}</language>
      <audience>{audience}</audience>
      <environment>{environment}</environment>
    </structure_request>

    <research_files>
      <summary_path>.research/init/summary.md</summary_path>
      <sources_path>.research/init/sources.md</sources_path>
    </research_files>

    Read the research files above using Read tool.
    Create plan.md using the project-scaffolder skill as reference.
  """
)
```

**IMPORTANT**: Do NOT Read the research files in this command. The structure-designer reads them directly in its isolated context.

---

### Phase 4: Create task.md

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

### Phase 5: Create project-context.md

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

### Phase 6: Create CLAUDE.md

Create CLAUDE.md using claude-md-template.md from project-scaffolder skill as reference:

- Project overview (topic, domain, audience)
- Key skills and agents references (/write, researcher, writer)
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
  3. Run /write to start writing first section
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
