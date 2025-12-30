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

### 3.5 Directory Resolution Helper

**CRITICAL**: Use multi-tier search to find existing research directories. This handles naming inconsistencies.

Define a helper function to resolve research directories:

```
function resolveResearchDirectory(chapter, section, title):
  # Normalize identifiers (from research-storage skill)
  canonical_chapter = normalizeChapter(chapter)
    # "1" → "01", "01" → "01", "10" → "10"

  canonical_section = normalizeSection(section)
    # "1" → "1", "01" → "1", "02" → "2"

  canonical_slug = generateSlug(title)
    # "Core Concepts" → "core-concepts"
    # "What is React?" → "what-is-react"

  canonical_path = ".research/sections/{canonical_chapter}-{canonical_section}-{canonical_slug}/"

  # Tier 1: Exact canonical match
  tier1 = Glob("{canonical_path}research.md")
  if tier1 not empty:
    return { path: canonical_path, existing: true, tier: 1 }

  # Tier 2: Canonical chapter-section, any slug
  tier2 = Glob(".research/sections/{canonical_chapter}-{canonical_section}-*/research.md")
  if tier2 not empty:
    return { path: parent(tier2[0]), existing: true, tier: 2 }

  # Tier 3: Non-padded chapter variation
  raw_chapter = String(parseInt(chapter, 10))  # "01" → "1"
  tier3 = Glob(".research/sections/{raw_chapter}-{canonical_section}-*/research.md")
  if tier3 not empty:
    return { path: parent(tier3[0]), existing: true, tier: 3 }

  # Tier 4: Flexible pattern with first keyword
  keyword = canonical_slug.split('-')[0]
  tier4 = Glob(".research/sections/*-{canonical_section}-*{keyword}*/research.md")
  if tier4 not empty:
    return { path: parent(tier4[0]), existing: true, tier: 4 }

  # No match - use canonical for new directory
  return { path: canonical_path, existing: false, tier: "new" }
```

### 4. Execute Write Loop

For each section in queue:

```
for (i = 1; i <= queue.length; i++) {
  section = queue[i]
  review_status = "SKIPPED"

  // Progress report
  "📝 [{i}/{queue.length}] Starting: {section.title} (domain: {domain})"

  // Extract chapter and section numbers from section.id (e.g., "1.2" or "01-2")
  raw_chapter = extract_chapter(section.id)
  raw_section = extract_section(section.id)

  // Resolve research directory using multi-tier search
  resolution = resolveResearchDirectory(raw_chapter, raw_section, section.title)
  resolved_dir = resolution.path
  existing_research = resolution.existing
  match_tier = resolution.tier

  // Generate canonical identifiers for output paths
  canonical_chapter = normalizeChapter(raw_chapter)
  canonical_section = normalizeSection(raw_section)
  canonical_slug = generateSlug(section.title)

  // Research Phase
  Task(
    subagent_type="dokhak:researcher",
    model="haiku",
    description="Research for {section.title}",
    prompt="""
      <research_request>
        <section>
          <id>{canonical_chapter}-{canonical_section}</id>
          <slug>{canonical_slug}</slug>
          <title>{section.title}</title>
        </section>
        <subtopics>
          <subtopic>{subtopic 1}</subtopic>
          <subtopic>{subtopic 2}</subtopic>
        </subtopics>
        <domain>{domain}</domain>
        <output_dir>{resolved_dir}</output_dir>
        <existing_research>{existing_research}</existing_research>
      </research_request>
    """
  )
  // Agent returns: "research_saved:{resolved_path}\nsources:N\nsubtopics_covered:X/Y\nmatch_tier:T"

  // Parse researcher's confirmation to get actual research path
  actual_research_dir = parse_research_saved_path(researcher_confirmation)

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
        <output_path>docs/{canonical_chapter}-{canonical_section}-{canonical_slug}.md</output_path>
      </writing_request>

      <context_files>
        <persona_path>persona.md</persona_path>
        <project_context_path>project-context.md</project_context_path>
        <research_path>{actual_research_dir}research.md</research_path>
        <sources_path>{actual_research_dir}sources.md</sources_path>
        <init_summary_path>.research/init/summary.md</init_summary_path>
      </context_files>

      Read the context files above. Write the section following persona voice.
    """
  )
  // Agent returns: "document_written:{path}\nlines:{count}"

  // Document path using canonical identifiers
  document_path = "docs/{canonical_chapter}-{canonical_section}-{canonical_slug}.md"

  // Review Phase (if skip_review is false)
  if (!skip_review) {
    Task(
      subagent_type="dokhak:reviewer",
      model="haiku",
      description="Review {section.title}",
      prompt="""
        <review_request>
          <document_path>{document_path}</document_path>
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
            <document_path>{document_path}</document_path>
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
