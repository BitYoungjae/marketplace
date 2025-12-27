---
description: "Add a new section to an existing chapter. Calculates section number (e.g., 5.4), adds subtopic placeholders to plan.md, and updates task.md checklist."
allowed-tools: Read, Write, Edit, Grep, Glob
argument-hint: "<section-title> --chapter <chapter-number> [--pages <number>]"
model: haiku
---

# Add Section to Chapter

Add a new section to an existing chapter in the learning resource project.

## Context

Target chapter structure (use $1 as chapter number from parsed arguments):
!`grep -A 15 "^### Chapter" plan.md 2>/dev/null | head -40 || echo "[ERROR] plan.md not found - run /init-project first"`

Current sections in project:
!`grep -E "^#### [0-9]+\.[0-9]+" plan.md 2>/dev/null | tail -10 || echo "[No sections found]"`

---

## Parse Arguments

Extract from `$ARGUMENTS`:

- **Section Title**: The title for the new section (required)
- **Chapter Number**: Target chapter with `--chapter` (required)
- **Pages**: Page allocation if specified with `--pages` (default: 8)

Examples:

```
/add-section "Container Networking" --chapter 12 --pages 10
/add-section "Error Recovery" --chapter 5
```

---

## Workflow

### Step 1: Validate Project Structure

1. Check if `plan.md` exists
2. Check if `task.md` exists
3. If either is missing, report error:

   ```
   Error: Project not initialized. Run /init-project first.
   ```

### Step 2: Validate Chapter Exists

1. Read `plan.md` to find Chapter N
2. If chapter not found, report error:

   ```
   Error: Chapter {N} not found in plan.md.
   Available chapters: Chapter 1, Chapter 2, ...
   ```

### Step 3: Analyze Current Chapter Structure

1. Find all existing sections in target chapter:
   - Pattern: `#### {N}.{M} ...`
   - Extract section numbers

2. Calculate next section number:
   - Find highest section number M in Chapter N
   - New section = N.(M+1)

3. Determine insertion point:
   - Find line before next chapter OR next part OR end of current chapter's practice section

### Step 4: Create Section Content

Generate section structure for `plan.md`:

```markdown
#### {N}.{M} {SECTION_TITLE} ({PAGES} pages)

- {N}.{M}.1 {SUBTOPIC_1}
- {N}.{M}.2 {SUBTOPIC_2}
- {N}.{M}.3 {SUBTOPIC_3}
```

Generate subtopic suggestions based on section title:

- First subtopic: "Introduction to {concept}" or "Understanding {concept}"
- Second subtopic: "Key principles" or "Core mechanisms"
- Third subtopic: "Practical considerations" or "Implementation details"

### Step 5: Update plan.md

Use Edit tool to insert the new section at the appropriate location within the chapter.

Ensure proper placement:

- After existing sections
- Before "Practice {N}" if it exists
- Before next chapter header

### Step 6: Update task.md

Find the corresponding chapter section in `task.md` and add:

```markdown
- [ ] {N}.{M} {SECTION_TITLE} ({PAGES}p) → [plan.md](plan.md)
```

Insert after existing sections, before any chapter-level practice items.

### Step 7: Update Page Counts

1. Update chapter's total page count in plan.md:
   - Find `### Chapter {N}: ... ({OLD_PAGES} pages)`
   - Update to `### Chapter {N}: ... ({OLD_PAGES + NEW_PAGES} pages)`

2. Update Part's total if applicable

3. Update progress table in task.md if it exists

---

## Completion Report

After successful addition:

```
=== Section Added ===

Chapter {N}: {CHAPTER_TITLE}
  └── {N}.{M} {SECTION_TITLE} ({PAGES}p)
      ├── {N}.{M}.1 {SUBTOPIC_1}
      ├── {N}.{M}.2 {SUBTOPIC_2}
      └── {N}.{M}.3 {SUBTOPIC_3}

Files Updated:
  ✓ plan.md - Section structure added, chapter pages updated
  ✓ task.md - 1 new task added

Chapter {N} now has {TOTAL_SECTIONS} sections ({TOTAL_PAGES}p)

Next: Use /write-doc to start writing, or /add-section to add more sections.
```

---

## Error Handling

### Missing Required Argument

```
Error: --chapter is required.
Usage: /add-section "<title>" --chapter <N> [--pages <N>]
```

### Chapter Not Found

```
Error: Chapter {N} not found in plan.md.
Available chapters:
  - Chapter 1: Introduction to Linux
  - Chapter 2: File Systems
  - Chapter 3: Processes
```

### No Project Files

```
Error: plan.md not found. Initialize project with /init-project first.
```

### Invalid Section Title

```
Error: Section title is required.
Usage: /add-section "<title>" --chapter <N> [--pages <N>]
```

---

## Examples

### Example 1: Add to Chapter 5

```
/add-section "Advanced Error Handling" --chapter 5 --pages 12
```

Result in plan.md:

```markdown
#### 5.4 Advanced Error Handling (12 pages)

- 5.4.1 Understanding Error Patterns
- 5.4.2 Recovery Strategies
- 5.4.3 Implementation Guidelines
```

### Example 2: Add with Default Pages

```
/add-section "Memory Optimization" --chapter 8
```

Result in plan.md:

```markdown
#### 8.3 Memory Optimization (8 pages)

- 8.3.1 Understanding Memory Usage
- 8.3.2 Optimization Techniques
- 8.3.3 Practical Considerations
```
