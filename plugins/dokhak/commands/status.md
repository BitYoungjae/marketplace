---
description: "Show project progress and statistics. Displays completion percentage, Part/Chapter breakdown, and next pending tasks."
allowed-tools: Read, Grep, Glob, Bash(grep:*), Bash(head:*), Bash(wc:*)
model: haiku
---

# Project Status Command

## Context

- Completed tasks: !`grep -c "\[x\]" task.md 2>/dev/null || echo "0"`
- Pending tasks: !`grep -c "\[ \]" task.md 2>/dev/null || echo "0"`
- Plan metadata: !`head -20 plan.md 2>/dev/null || echo "No plan.md found"`

## Task

Generate a progress report for this learning resource project.

### Step 1: Check Prerequisites

If task.md does not exist, report:
```
Error: task.md not found.
Run /init-project first to initialize the project.
```

If plan.md does not exist, report:
```
Error: plan.md not found.
Run /init-project first to initialize the project.
```

### Step 2: Extract Project Information

From plan.md, extract:
- Project title (first # heading)
- Target System
- Target Audience
- Total Estimated Pages

### Step 3: Calculate Progress by Part

For each Part in task.md:
1. Count `[x]` (completed) items
2. Count `[ ]` (pending) items
3. Calculate percentage

### Step 4: Identify Next Tasks

List the first 3-5 uncompleted `[ ]` items from task.md.

### Step 5: Output Format

Use this exact format:

```
=== Learning Resource Status ===

Topic: {PROJECT_TITLE}
Progress: {COMPLETED}/{TOTAL} sections ({PERCENTAGE}%)
Pages: ~{ESTIMATED_DONE}/{TOTAL_PAGES} estimated

Part 1: {STATUS} ({DONE}/{TOTAL})
Part 2: {STATUS} ({DONE}/{TOTAL})
...

Next tasks:
  [ ] {SECTION_NUMBER} {SECTION_TITLE} ({PAGES}p)
  [ ] {SECTION_NUMBER} {SECTION_TITLE} ({PAGES}p)
  [ ] {SECTION_NUMBER} {SECTION_TITLE} ({PAGES}p)
```

Status labels:
- "Complete" if all items done
- "In Progress" if some items done
- "Pending" if no items done

### Notes

- Page estimation: assume completed sections contribute their planned pages
- If Part structure is unclear, group by Chapter instead
- Keep output concise and scannable
