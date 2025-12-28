---
description: "Continue writing multiple sections. Uses researcher->writer->reviewer pipeline for each section. Supports domain-adaptive content generation (technology, history, science, arts, general)."
allowed-tools: Read, Grep, Glob, Task, Edit
argument-hint: "[count] [--skip-review]"
model: opus
---

# Continue Session

Write the next N incomplete sections (default: 3).

## Context Files

- Persona: @persona.md
- Project Context: @project-context.md

## Current State

- Incomplete tasks: !`grep -c "\[ \]" task.md 2>/dev/null || echo "No task.md found"`

## Process

### 1. Parse Arguments

Extract count and skip_review flag from $ARGUMENTS.

```
count = parseInt($ARGUMENTS.replace("--skip-review", "").trim()) || 3
skip_review = $ARGUMENTS.includes("--skip-review")
```

### 2. Read task.md and Extract Domain

Read task.md and identify all incomplete sections (`[ ]` items).

Read persona.md and extract domain information:

- Domain (from Domain Guidelines section header, e.g., "Domain Guidelines: Technology" → technology)
- If no Domain Guidelines section, default to "technology" for backward compatibility

Domain values: technology, history, science, arts, general

### 3. Build Section Queue

Create a queue of sections to write:

1. Collect first `count` incomplete (`[ ]`) items from task.md
2. Extract section IDs and titles for each queued item

### 4. Execute Write Loop

For each section in queue:

```
for (i = 1; i <= queue.length; i++) {
  section = queue[i]
  review_status = "SKIPPED"

  // Progress report
  "📝 [{i}/{queue.length}] Starting: {section.title} (domain: {domain})"

  // Generate paths
  research_dir = ".research/sections/{section.id}-{slugified_title}/"

  // Check existing research (Glob for existence only)
  existing_research = Glob("{research_dir}research.md") exists ? true : false

  // Research Phase
  Task(
    subagent_type="dokhak:researcher",
    model="haiku",
    description="Research for {section.title}",
    prompt="""
      <research_request>
        <section>
          <id>{section.id}</id>
          <slug>{slugified_title}</slug>
          <title>{section.title}</title>
        </section>
        <subtopics>
          <subtopic>{subtopic 1}</subtopic>
          <subtopic>{subtopic 2}</subtopic>
        </subtopics>
        <domain>{domain}</domain>
        <output_dir>{research_dir}</output_dir>
        <existing_research>{existing_research}</existing_research>
      </research_request>
    """
  )
  // Agent returns: "research_saved:{research_dir}\nsources:N\nsubtopics_covered:X/Y"

  // Writing Phase - Pass FILE PATHS only
  Task(
    subagent_type="dokhak:writer",
    model="opus",
    description="Write {section.title}",
    prompt="""
      <writing_request>
        <section>
          <title>{section.title}</title>
          <page_count>{section.pages}</page_count>
          <subtopics>
            <subtopic>{subtopic 1}</subtopic>
            <subtopic>{subtopic 2}</subtopic>
          </subtopics>
        </section>
        <domain>{domain}</domain>
        <output_path>docs/{section.id}-{slugified_title}.md</output_path>
      </writing_request>

      <context_files>
        <persona_path>persona.md</persona_path>
        <project_context_path>project-context.md</project_context_path>
        <research_path>{research_dir}research.md</research_path>
        <sources_path>{research_dir}sources.md</sources_path>
        <init_summary_path>.research/init/summary.md</init_summary_path>
      </context_files>

      Read the context files above. Write the section following persona voice.
    """
  )
  // Agent returns: "document_written:{path}\nlines:{count}"

  // Review Phase (if skip_review is false)
  if (!skip_review) {
    Task(
      subagent_type="dokhak:reviewer",
      model="haiku",
      description="Review {section.title}",
      prompt="""
        <review_request>
          <document_path>docs/{section.id}-{slugified_title}.md</document_path>
          <persona_path>persona.md</persona_path>
          <previous_section>{previous_section_path or "none"}</previous_section>
          <target_pages>{section.pages}</target_pages>
        </review_request>
      """
    )

    // Revision Phase (if needed) - Pass FILE PATHS only
    if (review_result.status == "NEEDS_REVISION") {
      Task(
        subagent_type="dokhak:writer",
        model="opus",
        description="Revise {section.title}",
        prompt="""
          <revision_request>
            <document_path>docs/{section.id}-{slugified_title}.md</document_path>
            <domain>{domain}</domain>
            <review_feedback>
              {revision_suggestions from review_result}
            </review_feedback>
          </revision_request>

          <context_files>
            <persona_path>persona.md</persona_path>
            <project_context_path>project-context.md</project_context_path>
          </context_files>

          Read the document and context files. Apply the review feedback.
          Focus ONLY on issues in feedback. Maintain structure and voice.
        """
      )
      // Agent returns: "document_written:{path}\nlines:{count}"
      review_status = "REVISED"
    } else {
      review_status = "PASS"
    }
  }

  // Update task.md
  Change `[ ]` to `[x]` for this section

  // Progress report
  "✓ [{i}/{queue.length}] Completed: {section.title} (Review: {review_status})"
}
```

### 5. Stop Conditions

Stop the loop when ANY of these occur:

1. **Count reached**: Completed `count` sections
2. **Queue empty**: No more incomplete sections

## Output

Final summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Session Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 Domain: {domain}
🔍 Review: {enabled|skipped}

✓ Completed: {completed_count} sections
  - {section_1_title} [{PASS|REVISED|SKIPPED}]
  - {section_2_title} [{PASS|REVISED|SKIPPED}]
  - ...

📁 Files created:
  - docs/{file_1}.md
  - docs/{file_2}.md
  - ...

📋 Remaining: {remaining_count} sections
   Next: {next_section_title or "All sections completed"}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Handling

- If researcher fails for a section: Continue with writer using LLM knowledge
- If writer fails: Stop loop, do NOT update task.md for failed section, report error
- If reviewer fails for a section: Log warning, proceed to completion (treat as --skip-review for that section)
- If revision fails: Stop loop, do NOT update task.md for failed section, report error with original review feedback
- If task.md is missing: Error and exit
- If plan.md is missing: Error and exit
- If domain cannot be determined: Default to "technology" for backward compatibility
