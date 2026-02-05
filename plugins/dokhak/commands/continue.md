---
description: "Continue writing multiple sections in batch"
allowed-tools: Read, Grep, Glob, Task, Edit
argument-hint: "[count] [--skip-review]"
model: opus
---

# Continue Session

Write the next N incomplete sections (default: 3) using the same pipeline as /write.

**Pipeline per section**: researcher (haiku) → writer (opus) → reviewer (haiku) → [revision]

## Context

- Persona: @persona.md
- Project Context: @project-context.md
- Incomplete tasks: !`grep -c "\[ \]" task.md 2>/dev/null || echo "0"`

---

## Step 1: Parse Arguments

```
skip_review = $ARGUMENTS.includes("--skip-review")
count = parseInt($ARGUMENTS.replace("--skip-review", "").trim()) || 3
```

## Step 2: Build Queue

1. Read task.md, collect first `count` incomplete (`[ ]`) items
2. Extract domain from persona.md (default: "technology")
3. Extract section IDs, titles, page counts from plan.md

---

## Step 3: Execute Loop

For each section in queue:

```
for (i = 1; i <= queue.length; i++) {
  "📝 [{i}/{count}] {section.title}"

  // 1. Resolve research directory (see /write Step 2)
  resolved_dir = resolveResearchDirectory(section)

  // 2. Research
  Task(dokhak:researcher, model="haiku", ...)
  // Returns: research_saved:{path}

  // 3. Write
  Task(dokhak:writer, ...)
  // Returns: document_written:{path}

  // 4. Review (unless --skip-review)
  if (!skip_review) {
    Task(dokhak:reviewer, model="haiku", ...)
    // If NEEDS_REVISION → one revision pass
  }

  // 5. Update task.md: [ ] → [x]
  "✓ [{i}/{count}] {section.title} [{PASS|REVISED|SKIPPED}]"
}
```

<important>
- Track previous_document_path across iterations for coherence review
- Stop on writer/revision failure (do NOT update task.md)
- Continue on researcher/reviewer failure (degrade gracefully)
</important>

---

## Step 4: Stop Conditions

- Count reached: completed `count` sections
- Queue empty: no more incomplete sections

---

## Output

```
=== Session Summary ===

Completed: {n} sections
  ✓ {title_1} [{PASS|REVISED|SKIPPED}]
  ✓ {title_2} [{PASS|REVISED|SKIPPED}]

Files: docs/{file_1}.md, docs/{file_2}.md, ...

Remaining: {m} sections
Next: {next_title or "All complete"}
```

---

## Error Handling

| Error | Action |
|-------|--------|
| task.md missing | Exit with error |
| plan.md missing | Exit with error |
| Researcher fails | Continue with LLM knowledge |
| Writer fails | Stop loop, report error |
| Reviewer fails | Treat as --skip-review |
| Revision fails | Stop loop, report error |
