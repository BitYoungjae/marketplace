---
description: >
  Add a new chapter to plan.md and task.md. Calculates next chapter number,
  creates section placeholders, and updates task checklist.
allowed-tools: Read, Write, Edit, Grep, Glob
argument-hint: "<chapter-title> [--part <part-number>] [--pages <number>]"
model: haiku
---

# Add Chapter to Learning Resource

Add a new chapter to the current learning resource project.

## Context

Current plan structure:
!`grep -E "^###? (Part|Chapter)" plan.md 2>/dev/null | head -30 || echo "[ERROR] plan.md not found - run /init-project first"`

Current task structure:
!`grep -E "^## Part|^### Chapter" task.md 2>/dev/null | head -20 || echo "[ERROR] task.md not found - run /init-project first"`

---

## Parse Arguments

Extract from `$ARGUMENTS`:

- **Chapter Title**: The title for the new chapter (required)
- **Part Number**: Target part if specified with `--part` (default: last part)
- **Pages**: Page allocation if specified with `--pages` (default: 20)

Examples:

```
/add-chapter "Advanced Networking" --part 3 --pages 25
/add-chapter "Error Handling"  # Adds to last part with 20 pages
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

### Step 2: Analyze Current Structure

1. Read `plan.md` to find:
   - All existing Parts and their numbers
   - All existing Chapters within target Part
   - Last chapter number in target Part

2. Determine target Part:
   - If `--part N` specified, use Part N
   - Otherwise, use the last Part

3. Calculate next chapter number:
   - Find highest chapter number in target Part
   - New chapter = highest + 1

### Step 3: Determine Insertion Point

1. Find the line in `plan.md` where target Part ends:
   - Look for next Part header OR end of file
   - Insert new chapter before that point

2. Find corresponding location in `task.md`

### Step 4: Create Chapter Content

Generate chapter structure for `plan.md`:

```markdown
### Chapter {N}: {CHAPTER_TITLE} ({PAGES} pages)

#### {N}.1 Introduction to {CHAPTER_TITLE} ({INTRO_PAGES} pages)

- {N}.1.1 Overview
- {N}.1.2 Key Concepts

#### {N}.2 Core Concepts ({CORE_PAGES} pages)

- {N}.2.1 Concept 1
- {N}.2.2 Concept 2

#### {N}.3 Practice ({PRACTICE_PAGES} pages)

- {N}.3.1 Exercise 1
- {N}.3.2 Exercise 2

**Practice {N}**: Hands-on exercise for {CHAPTER_TITLE}
```

Page allocation formula:

- Introduction: ~20% of chapter pages
- Core Concepts: ~50% of chapter pages
- Practice: ~30% of chapter pages

### Step 5: Update plan.md

Use Edit tool to insert the new chapter content at the determined location.

### Step 6: Update task.md

Add corresponding checklist items to `task.md`:

```markdown
### Chapter {N}: {CHAPTER_TITLE}

- [ ] {N}.1 Introduction to {CHAPTER_TITLE} ({INTRO_PAGES}p) → [plan.md](plan.md)
- [ ] {N}.2 Core Concepts ({CORE_PAGES}p) → [plan.md](plan.md)
- [ ] {N}.3 Practice ({PRACTICE_PAGES}p) → [plan.md](plan.md)
```

### Step 7: Update Progress Table

If task.md has a progress summary table, update the totals.

---

## Completion Report

After successful addition:

```
=== Chapter Added ===

Part {PART_NUMBER}: {PART_TITLE}
  └── Chapter {N}: {CHAPTER_TITLE} ({PAGES}p)
      ├── {N}.1 Introduction ({INTRO_PAGES}p)
      ├── {N}.2 Core Concepts ({CORE_PAGES}p)
      └── {N}.3 Practice ({PRACTICE_PAGES}p)

Files Updated:
  ✓ plan.md - Chapter structure added
  ✓ task.md - 3 new tasks added

Next: Use /add-section to add more sections, or /write-doc to start writing.
```

---

## Error Handling

### Part Not Found

```
Error: Part {N} not found in plan.md.
Available parts: Part 1, Part 2, Part 3
```

### No Project Files

```
Error: plan.md not found. Initialize project with /init-project first.
```

### Invalid Arguments

```
Error: Chapter title is required.
Usage: /add-chapter "<title>" [--part <N>] [--pages <N>]
```
