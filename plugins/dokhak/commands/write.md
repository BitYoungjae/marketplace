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

### 3. Resolve Research Directory

**CRITICAL**: Use multi-tier search to find existing research directories. This handles naming inconsistencies from different generation sources.

#### 3.1 Normalize Identifiers

Apply normalization functions from research-storage skill:

```
# Extract chapter and section from section ID (e.g., "1.2" or "01-2")
raw_chapter = extract_chapter(section_id)
raw_section = extract_section(section_id)

# Normalize to canonical format
canonical_chapter = normalizeChapter(raw_chapter)
  # "1" → "01", "01" → "01", "10" → "10"

canonical_section = normalizeSection(raw_section)
  # "1" → "1", "01" → "1", "02" → "2"

canonical_slug = generateSlug(section_title)
  # "Core Concepts" → "core-concepts"
  # "What is React?" → "what-is-react"

canonical_path = ".research/sections/{canonical_chapter}-{canonical_section}-{canonical_slug}/"
```

#### 3.2 Multi-Tier Search

> **⚠️ Glob Returns Files Only**
>
> Glob does NOT return directories. All patterns MUST end with `/research.md`.
>
> | Pattern | Result |
> |---------|--------|
> | `.research/sections/*9-1*` | ❌ Empty |
> | `.research/sections/*9-1*/research.md` | ✅ Works |

Execute searches in order. Stop at first match:

```
# Tier 1: Exact canonical match
tier1_result = Glob("{canonical_path}research.md")

IF tier1_result is not empty:
  resolved_dir = canonical_path
  existing_research = true
  match_tier = 1
ELSE:
  # Tier 2: Canonical chapter-section, any slug
  tier2_result = Glob(".research/sections/{canonical_chapter}-{canonical_section}-*/research.md")

  IF tier2_result is not empty:
    resolved_dir = parent_directory(tier2_result[0])
    existing_research = true
    match_tier = 2
  ELSE:
    # Tier 3: Non-padded chapter variation
    raw_chapter_str = String(parseInt(raw_chapter, 10))  # "01" → "1"
    tier3_result = Glob(".research/sections/{raw_chapter_str}-{canonical_section}-*/research.md")

    IF tier3_result is not empty:
      resolved_dir = parent_directory(tier3_result[0])
      existing_research = true
      match_tier = 3
    ELSE:
      # Tier 4: Flexible pattern with first keyword
      first_keyword = canonical_slug.split('-')[0]  # "core-concepts" → "core"
      tier4_result = Glob(".research/sections/*-{canonical_section}-*{first_keyword}*/research.md")

      IF tier4_result is not empty:
        resolved_dir = parent_directory(tier4_result[0])
        existing_research = true
        match_tier = 4
      ELSE:
        # No existing research found - use canonical path for new directory
        resolved_dir = canonical_path
        existing_research = false
        match_tier = "new"
```

#### 3.3 Resolution Summary

Store the resolution results for use in subsequent steps:

```
resolved_dir = {matched_directory OR canonical_path}
existing_research = {true if any tier matched}
match_tier = {1|2|3|4|new}
```

**IMPORTANT**: Use `resolved_dir` when invoking researcher and writer agents, NOT the originally generated path.

### 4. Research Phase

Invoke the researcher agent to gather information.
Research results are saved to `{resolved_dir}` (from Step 3).

```
Task(
  subagent_type="researcher",
  model="haiku",
  description="Research for {section_title}",
  prompt="""
    <research_request>
      <section>
        <id>{canonical_chapter}-{canonical_section}</id>
        <slug>{canonical_slug}</slug>
        <title>{section_title}</title>
      </section>
      <subtopics>
        <subtopic>{subtopic 1}</subtopic>
        <subtopic>{subtopic 2}</subtopic>
        ...
      </subtopics>
      <domain>{domain}</domain>
      <audience_level>{audience_level}</audience_level>
      <output_dir>{resolved_dir}</output_dir>
      <existing_research>{existing_research}</existing_research>
    </research_request>

    Follow domain-specific search strategy using domain-profiles skill.
    Save results following research-storage skill conventions.
    The researcher will perform its own directory resolution to validate the path.
    Return confirmation message only (not the research content).
  """
)
```

Agent returns confirmation like:
```
research_saved:{resolved_path}
sources:5
subtopics_covered:4/4
match_tier:1
```

**IMPORTANT**: Do NOT store the research content. The confirmation message is sufficient. Parse `research_saved:` to get the actual path used by researcher (may differ if researcher resolved differently).

### 5. Writing Phase

Invoke the writer agent with file PATHS only.
Writer reads context files directly in its isolated context.

**IMPORTANT**: Use the path from researcher's confirmation (`research_saved:`) to ensure consistency. If researcher resolved to a different path, use that path.

```
# Parse researcher's confirmation to get actual research path
actual_research_dir = parse_research_saved_path(researcher_confirmation)
# e.g., "research_saved:.research/sections/01-2-core-concepts/" → ".research/sections/01-2-core-concepts/"

Task(
  subagent_type="writer",
  model="opus",
  description="Write {section_title}",
  prompt="""
    <writing_request>
      <section>
        <title>{section_title}</title>
        <id>{canonical_chapter}-{canonical_section}</id>
        <page_count>{page_count}</page_count>
        <subtopics>{subtopics}</subtopics>
        <part_context>{part_title}</part_context>
        <chapter_context>{chapter_title}</chapter_context>
      </section>
      <domain>{domain}</domain>
      <output_path>docs/{canonical_chapter}-{canonical_section}-{canonical_slug}.md</output_path>
    </writing_request>

    <context_files>
      <persona_path>persona.md</persona_path>
      <project_context_path>project-context.md</project_context_path>
      <research_path>{actual_research_dir}research.md</research_path>
      <sources_path>{actual_research_dir}sources.md</sources_path>
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
document_written:docs/{canonical_chapter}-{canonical_section}-{canonical_slug}.md
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
