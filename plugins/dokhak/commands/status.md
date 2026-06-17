---
description: "Show project progress and statistics"
allowed-tools: Read, Grep, Glob
model: haiku
---

# Project Status

Display progress report for the learning resource project.

## Context

- Completed: !`grep -c "\[x\]" task.md 2>/dev/null || echo "0"`
- Pending: !`grep -c "\[ \]" task.md 2>/dev/null || echo "0"`

---

## Process

### 1. Check Prerequisites

If task.md or plan.md missing:
```
Error: {file} not found. Run /init first.
```

### 2. Extract Information

From plan.md: title, audience, total pages
From task.md: completion status per Part/Chapter

### 3. Calculate Progress

For each Part:
- Count `[x]` and `[ ]` items
- Calculate percentage
- Estimate pages done (completed sections × planned pages)

### 4. List Next Tasks

First 3-5 incomplete `[ ]` items from task.md.

---

## Output

```
=== Project Status ===

Topic: {title}
Progress: {done}/{total} sections ({percent}%)
Pages: ~{done_pages}/{total_pages}

Part 1: {Complete|In Progress|Pending} ({n}/{m})
Part 2: {Complete|In Progress|Pending} ({n}/{m})

Next:
  [ ] {id} {title} ({pages}p)
  [ ] {id} {title} ({pages}p)
  [ ] {id} {title} ({pages}p)
```
