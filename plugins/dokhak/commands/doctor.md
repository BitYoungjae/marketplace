---
description: "Diagnose project structure and fix issues"
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion
argument-hint: "[--auto | --check]"
model: haiku
skills: project-scaffolder
---

# Project Doctor

Diagnose project structure health and interactively fix issues.

## Arguments

| Arg | Mode |
|-----|------|
| (none) | Interactive - prompt for each fix |
| `--auto` | Auto-fix with defaults |
| `--check` | Report only (for CI) |

## Output Language

Infer from project files. Default to English.

---

## Check 1: Required Files

| File | Level | If Missing |
|------|-------|------------|
| plan.md | ERROR | Project cannot function |
| task.md | ERROR | Progress tracking impossible |
| persona.md | WARN | Recommended for voice |
| project-context.md | WARN | Recommended for context |
| CLAUDE.md | WARN | Recommended for continuity |

**ERROR level**: Prompt to run `/init` or create from template (project-scaffolder skill)
**WARN level**: Prompt to create from template or skip

---

## Check 2: Cross-File Consistency

### plan.md ↔ task.md
- Section count match
- Section IDs match
- Page allocations match

**Source of truth**: plan.md

### plan.md/task.md ↔ CLAUDE.md
- Session count consistency
- Structure description accuracy

---

## Check 3: Completion Status

### task.md ↔ docs/
- `[x]` but file missing → prompt to uncheck or create placeholder
- File exists but `[ ]` → prompt to check or delete file

---

## Output

```
=== Project Health Check ===

[1/3] Required Files
      ✓ plan.md
      ✓ task.md
      ! CLAUDE.md (recommended)

[2/3] Cross-File Consistency
      ✓ Section count matches (15)
      ✓ All sections synced

[3/3] Completion Status
      Progress: 5/15 (33%)
      ✓ All [x] tasks have files
      ✓ All files have matching tasks

=== Summary ===
Issues: 1 | Fixed: 0 | Skipped: 1
Health: GOOD
```

**Health ratings**: GOOD (no errors) | NEEDS_ATTENTION (skipped errors) | CRITICAL (required files missing)

---

## Notes

- plan.md = source of truth for structure
- task.md = source of truth for completion
- Preserve data when in doubt
