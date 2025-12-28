---
description: "Write the next document section using researcher->writer->reviewer pipeline. Identifies next incomplete task, gathers research, writes document, and reviews quality. Supports domain-adaptive content generation (technology, history, science, arts, general)."
allowed-tools: Read, Grep, Glob, Task, Edit
argument-hint: "[section-id] [--skip-review]"
model: opus
---

# Write Document

Write the next incomplete section from task.md, or a specific section if provided via $ARGUMENTS.

## Context Files

- Persona: @persona.md
- Project Context: @project-context.md

## Current State

- Next task: !`grep -m1 "\[ \]" task.md 2>/dev/null || echo "No task.md found"`

## Process

### 1. Identify Target Section

If $ARGUMENTS is provided, use it as the section ID.
Otherwise, parse task.md for the first `[ ]` item.

Extract:

- Section ID (e.g., "3.2")
- Section title

### 2. Get Section Details and Domain

Read plan.md and extract details for the target section:

- Full title
- Estimated page count
- Subtopics to cover
- Part/Chapter context

Read persona.md and extract domain information:

- Domain (from Domain Guidelines section header, e.g., "Domain Guidelines: Technology" → technology)
- If no Domain Guidelines section, default to "technology" for backward compatibility

Domain values: technology, history, science, arts, general

### 3. Check Existing Research

Check if research already exists for this section using Glob (existence check only).

```
research_dir = .research/sections/{chapter}-{section}-{slug}/
existing_research = false

If Glob(".research/sections/{chapter}-{section}-{slug}/research.md") exists:
  existing_research = true
```

**IMPORTANT**: Only check file existence. Do NOT Read the research files here.

### 4. Research Phase

Invoke the researcher agent to gather information.
Research results are saved to `.research/sections/{chapter}-{section}-{slug}/` directory.

```
Task(
  subagent_type="researcher",
  model="haiku",
  description="Research for {section_title}",
  prompt="""
    <research_request>
      <section>
        <id>{chapter}-{section}</id>
        <slug>{slug}</slug>
        <title>{section_title}</title>
      </section>
      <subtopics>
        <subtopic>{subtopic 1}</subtopic>
        <subtopic>{subtopic 2}</subtopic>
        ...
      </subtopics>
      <domain>{domain}</domain>
      <audience_level>{audience_level}</audience_level>
      <output_dir>.research/sections/{chapter}-{section}-{slug}/</output_dir>
      <existing_research>{existing_research}</existing_research>
    </research_request>

    Follow domain-specific search strategy using domain-profiles skill.
    Save results following research-storage skill conventions.
    Return confirmation message only (not the research content).
  """
)
```

Agent returns confirmation like:
```
research_saved:.research/sections/{chapter}-{section}-{slug}/
sources:5
subtopics_covered:4/4
```

**IMPORTANT**: Do NOT store the research content. The confirmation message is sufficient.

### 5. Writing Phase

Invoke the writer agent with file PATHS only.
Writer reads context files directly in its isolated context.

```
Task(
  subagent_type="writer",
  model="opus",
  description="Write {section_title}",
  prompt="""
    <writing_request>
      <section>
        <title>{section_title}</title>
        <id>{section_id}</id>
        <page_count>{page_count}</page_count>
        <subtopics>{subtopics}</subtopics>
        <part_context>{part_title}</part_context>
        <chapter_context>{chapter_title}</chapter_context>
      </section>
      <domain>{domain}</domain>
      <output_path>docs/{section_id}-{slugified_title}.md</output_path>
    </writing_request>

    <context_files>
      <persona_path>persona.md</persona_path>
      <project_context_path>project-context.md</project_context_path>
      <research_path>.research/sections/{chapter}-{section}-{slug}/research.md</research_path>
      <sources_path>.research/sections/{chapter}-{section}-{slug}/sources.md</sources_path>
      <init_summary_path>.research/init/summary.md</init_summary_path>
    </context_files>

    Read the context files above using Read tool (priority order: persona → research → sources → project_context → init_summary).

    Instructions:
    - Adopt the persona completely
    - Match the project's language
    - Respect the page count (1 page ≈ 50-70 lines, excluding frontmatter)
    - Apply domain-specific writing style
    - Follow Domain Guidelines from persona.md
    - Structure is YOUR decision based on content
    - Write the file directly using Write tool
    - Return confirmation message only (not the document content)
  """
)
```

Agent returns confirmation like:
```
document_written:docs/{section_id}-{slugified_title}.md
lines:{line_count}
```

**IMPORTANT**: Do NOT Read the context files in this command. The writer reads them directly in its isolated context.

### 6. Review Phase (if --skip-review not set)

If $ARGUMENTS contains "--skip-review":
- Skip to Step 8 (Update Task Status)

Otherwise, invoke the reviewer agent:

```
Task(
  subagent_type="reviewer",
  model="haiku",
  description="Review {section_title}",
  prompt="""
    <review_request>
      <document_path>docs/{section_id}-{slugified_title}.md</document_path>
      <persona_path>persona.md</persona_path>
      <previous_section>{previous_section_path or "none"}</previous_section>
      <target_pages>{page_count}</target_pages>
    </review_request>
  """
)
```

Store the result as `review_result`.

### 7. Revision Phase (if needed)

Parse `review_result` XML and check `<summary status="...">`:

**If status="NEEDS_REVISION":**

Extract `<revision_suggestions>` and invoke writer agent for revision:

```
Task(
  subagent_type="writer",
  model="opus",
  description="Revise {section_title}",
  prompt="""
    ## Persona
    {full content of persona.md}

    ## Project Context
    {full content of project-context.md}

    ## Domain
    {domain}

    ## Original Document
    {content of docs/{section_id}-{slugified_title}.md}

    ## Review Feedback
    {revision_suggestions from review_result}

    ## Instructions
    - Focus ONLY on the issues listed in revision suggestions
    - Do NOT rewrite the entire document
    - Apply fixes for high-priority items first
    - Maintain existing structure and voice
    - Write the revised file directly using Write tool
  """
)
```

**Important:** Only ONE revision is allowed to prevent infinite loops. After revision, proceed directly to Step 8.

**If status="PASS":**
- Proceed to Step 8

### 8. Update Task Status

After successful writing (and optional review/revision):

1. Find the completed task line in task.md
2. Change `[ ]` to `[x]`
3. Report completion to user

## Output

Report the completion:

```
✓ {section_id} {section_title} written
  Domain: {domain}
  File: docs/{filename}.md
  Review: {PASS|REVISED|SKIPPED}
  Next: {next_incomplete_section or "All sections complete"}
```

## Error Handling

- If persona.md is missing: Proceed with generic writer persona, default domain to "general"
- If project-context.md is missing: Warn user, proceed with minimal context
- If domain cannot be determined: Default to "technology" for backward compatibility
- If research returns empty: Writer uses LLM knowledge only
- If writer fails: Do NOT update task.md, report error
- If reviewer fails: Log warning, proceed to completion (treat as --skip-review)
- If revision fails: Do NOT update task.md, report error with original review feedback
