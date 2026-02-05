---
description: "Write the next document section using researcher→writer→reviewer pipeline"
allowed-tools: Read, Grep, Glob, Task, Edit
argument-hint: "[section-id] [--skip-review]"
model: opus
---

# Write Document

Write the next incomplete section from task.md, or a specific section if provided.

**Pipeline**: researcher (haiku) → writer (opus) → reviewer (haiku) → [revision if needed]

## Context

- Persona: @persona.md
- Project Context: @project-context.md
- Next task: !`grep -m1 "\[ \]" task.md 2>/dev/null || echo "No task.md found"`

---

## Step 1: Parse Arguments

```
skip_review = $ARGUMENTS.includes("--skip-review")
section_id = $ARGUMENTS.replace("--skip-review", "").trim() || first "[ ]" from task.md
```

Extract from task.md and plan.md:
- Section ID, title, page count, subtopics
- Part/Chapter context
- Domain (from persona.md "Domain Guidelines: {domain}" header, default: "technology")

---

## Step 2: Resolve Research Directory

<important>
Use research-storage skill's multi-tier search to find existing research.
Glob patterns MUST end with `/research.md` (Glob returns files only).
</important>

Search order (stop at first match):
1. Exact: `.research/sections/{chapter}-{section}-{slug}/research.md`
2. Any slug: `.research/sections/{chapter}-{section}-*/research.md`
3. Non-padded chapter: `.research/sections/{raw_chapter}-{section}-*/research.md`
4. Keyword match: `.research/sections/*-{section}-*{keyword}*/research.md`

If no match, use canonical path for new directory.

---

## Step 3: Research

```
Task(
  subagent_type="dokhak:researcher",
  model="haiku",
  prompt="""
    <research_request>
      <section id="{chapter}-{section}" title="{title}" />
      <subtopics>{subtopics}</subtopics>
      <domain>{domain}</domain>
      <output_dir>{resolved_dir}</output_dir>
    </research_request>
    Follow domain-profiles skill. Save per research-storage skill.
  """
)
```

Returns: `research_saved:{path}` — use this path for writer.

---

## Step 4: Write

```
Task(
  subagent_type="dokhak:writer",
  prompt="""
    <writing_request>
      <section title="{title}" id="{chapter}-{section}" pages="{pages}" />
      <context>{part_title} > {chapter_title}</context>
      <domain>{domain}</domain>
      <output_path>docs/{chapter}-{section}-{slug}.md</output_path>
    </writing_request>
    <context_files>
      persona.md, project-context.md,
      {research_dir}/research.md, {research_dir}/sources.md,
      .research/init/summary.md
    </context_files>
    Read context files. Write document following persona voice.
    1 page ≈ 50-70 lines.
  """
)
```

Returns: `document_written:{path}`

---

## Step 5: Review (unless --skip-review)

Find previous section for coherence check:
- If section > 1: `docs/{chapter}-{section-1}-*.md`
- If section == 1 and chapter > 1: last section of previous chapter
- Otherwise: "none"

```
Task(
  subagent_type="dokhak:reviewer",
  model="haiku",
  prompt="""
    <review_request>
      <document_path>{document_path}</document_path>
      <persona_path>persona.md</persona_path>
      <previous_section>{previous_path}</previous_section>
      <target_pages>{pages}</target_pages>
      <domain>{domain}</domain>
    </review_request>
  """
)
```

Returns: `<summary status="PASS|NEEDS_REVISION">`

---

## Step 6: Revise (if NEEDS_REVISION)

<important>
Only ONE revision allowed to prevent infinite loops.
</important>

```
Task(
  subagent_type="dokhak:writer",
  prompt="""
    <revision_request>
      <document_path>{document_path}</document_path>
      <feedback>{revision_suggestions}</feedback>
    </revision_request>
    <context_files>persona.md, project-context.md</context_files>
    Focus ONLY on feedback items. Maintain structure and voice.
  """
)
```

---

## Step 7: Update Status

Change `[ ]` to `[x]` in task.md for completed section.

---

## Output

```
✓ {section_id} {title} written
  File: docs/{filename}.md
  Review: {PASS|REVISED|SKIPPED}
  Next: {next_section or "All complete"}
```

---

## Error Handling

| Error | Action |
|-------|--------|
| persona.md missing | Use generic persona, domain="general" |
| project-context.md missing | Warn, proceed with minimal context |
| Research empty | Writer uses LLM knowledge |
| Writer fails | Do NOT update task.md, report error |
| Reviewer fails | Treat as --skip-review |
| Revision fails | Do NOT update task.md, report error |
