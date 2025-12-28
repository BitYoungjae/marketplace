---
description: "Continue writing multiple sections in current session. Uses researcher->writer->reviewer pipeline for each section. Supports domain-adaptive content generation (technology, history, science, arts, general). Respects session boundaries in task.md."
allowed-tools: Read, Grep, Glob, Task, Edit
argument-hint: "[count] [--skip-review]"
model: opus
---

# Continue Session

Write the next N sections (default: 3) or until session boundary.

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

Read task.md and identify:

- All incomplete sections (`[ ]` items)
- Session boundary markers (`<!-- Session N: ... -->`)
- Current session number

Read persona.md and extract domain information:

- Domain (from Domain Guidelines section header, e.g., "Domain Guidelines: Technology" → technology)
- If no Domain Guidelines section, default to "technology" for backward compatibility

Domain values: technology, history, science, arts, general

### 3. Build Section Queue

Create a queue of sections to write:

1. Start from first `[ ]` item
2. Stop at session boundary marker or when queue reaches `count`
3. Extract section IDs and titles for each queued item

### 4. Execute Write Loop

For each section in queue:

```
for (i = 1; i <= queue.length; i++) {
  section = queue[i]
  review_status = "SKIPPED"

  // Progress report
  "📝 [{i}/{queue.length}] Starting: {section.title} (domain: {domain})"

  // Research Phase
  Task(
    subagent_type="researcher",
    model="haiku",
    description="Research for {section.title}",
    prompt="""
      Research the following topic for a learning document.

      ## Topic
      {section.title}

      ## Domain
      {domain}

      ## Subtopics to Cover
      {section.subtopics}

      ## Target Audience
      Based on project context: {audience_level}

      ## Instructions
      - Follow domain-specific search strategy
      - For technology: Find code examples, official docs
      - For history: Find primary sources, timelines
      - For science: Find equations, experimental data
      - For arts: Find visual examples, techniques
      - Keep output under 1000 tokens
      - Return structured XML+Markdown format with domain-specific sections
    """
  )

  // Writing Phase
  Task(
    subagent_type="writer",
    model="opus",
    description="Write {section.title}",
    prompt="""
      ## Persona
      {full content of persona.md}

      ## Project Context
      {full content of project-context.md}

      ## Domain
      {domain}

      ## Section Information
      - Title: {section.title}
      - Section ID: {section.id}
      - Pages: {section.pages}
      - Subtopics: {section.subtopics}

      ## Research Results
      {research_result}

      ## Output Path
      Write to: docs/{section.id}-{slugified_title}.md

      ## Instructions
      - Adopt the persona completely
      - Match the project's language
      - Respect the page count (1 page ≈ 50-70 lines, excluding frontmatter)
      - Apply domain-specific writing style
      - Follow Domain Guidelines from persona.md
      - Structure is YOUR decision based on content
      - Write the file directly using Write tool
    """
  )

  // Review Phase (if skip_review is false)
  if (!skip_review) {
    Task(
      subagent_type="reviewer",
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

    // Revision Phase (if needed)
    if (review_result.status == "NEEDS_REVISION") {
      Task(
        subagent_type="writer",
        model="opus",
        description="Revise {section.title}",
        prompt="""
          ## Persona
          {full content of persona.md}

          ## Project Context
          {full content of project-context.md}

          ## Domain
          {domain}

          ## Original Document
          {content of docs/{section.id}-{slugified_title}.md}

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
2. **Session boundary**: Encountered `<!-- Session N: ... -->` marker
3. **Queue empty**: No more incomplete sections

When stopping at session boundary:
```
"⏸ Session boundary reached. Next session: {next_session_title}"
```

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
