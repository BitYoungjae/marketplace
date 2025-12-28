---
description: "Diagnose project structure health and interactively fix issues. Checks required files, cross-file consistency, and completion status sync."
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(wc:*), Bash(ls:*), AskUserQuestion
argument-hint: "[--auto | --check]"
model: haiku
skills: project-scaffolder
---

# Project Health Check Command

## Context

- Project files: !`ls -la plan.md task.md persona.md project-context.md CLAUDE.md 2>/dev/null || echo "Some files missing"`
- Docs directory: !`ls -d docs 2>/dev/null && ls docs/*.md 2>/dev/null | wc -l || echo "0 docs"`

## Output Language

Look at the existing project files (plan.md, task.md, persona.md, etc.) and infer the learner's language. Output all messages in that language. If unclear, default to English.

## Arguments

| Argument  | Description                                  |
| --------- | -------------------------------------------- |
| (none)    | Interactive mode - prompt for each fix       |
| `--auto`  | Auto-fix with sensible defaults (no prompts) |
| `--check` | Report only, no fix prompts (for CI)         |

## Task

Diagnose project structure and interactively fix issues found.

---

## Step 1: Check Required Files (Category 1)

Check the existence of these files:

| File                 | Level | Action if Missing                       |
| -------------------- | ----- | --------------------------------------- |
| `plan.md`            | ERROR | Must fix - project cannot function      |
| `task.md`            | ERROR | Must fix - progress tracking impossible |
| `persona.md`         | WARN  | Recommended for consistent voice        |
| `project-context.md` | WARN  | Recommended for research context        |
| `CLAUDE.md`          | WARN  | Recommended for session continuity      |

### For ERROR level (plan.md, task.md missing)

If `$ARGUMENTS` contains "--check":

- Report the error and continue

If `$ARGUMENTS` contains "--auto":

- Suggest running `/init`

Otherwise, use AskUserQuestion:

```
questions: [
  {
    question: "{filename} not found. How would you like to fix this?",
    header: "Missing",
    multiSelect: false,
    options: [
      {
        label: "Run /init (Recommended)",
        description: "Initialize complete project structure"
      },
      {
        label: "Create empty template",
        description: "Create minimal file structure"
      },
      {
        label: "Skip for now",
        description: "Continue without fixing"
      }
    ]
  }
]
```

**Fix Actions:**

- "Run /init": Output message suggesting user run `/init`
- "Create empty template": Use Write tool to create minimal template

### For WARN level (persona.md, project-context.md, CLAUDE.md missing)

If `$ARGUMENTS` contains "--check":

- Report the warning and continue

If `$ARGUMENTS` contains "--auto":

- Skip (warnings don't auto-fix)

Otherwise, use AskUserQuestion:

```
questions: [
  {
    question: "{filename} not found (recommended). Create from template?",
    header: "Recommend",
    multiSelect: false,
    options: [
      {
        label: "Yes, create from template",
        description: "Create file with default structure"
      },
      {
        label: "Skip for now",
        description: "Continue without this file"
      }
    ]
  }
]
```

**Fix Actions:**

- "Yes, create from template": Read the appropriate template from `project-scaffolder` skill and use Write tool

### Template Reference (from project-scaffolder skill)

When creating missing files, Read the corresponding template:

| Missing File         | Template to Read                                        |
| -------------------- | ------------------------------------------------------- |
| `plan.md`            | `skills/project-scaffolder/plan-template.md`            |
| `task.md`            | `skills/project-scaffolder/task-template.md`            |
| `persona.md`         | `skills/project-scaffolder/persona-template.md`         |
| `project-context.md` | `skills/project-scaffolder/project-context-template.md` |
| `CLAUDE.md`          | `skills/project-scaffolder/claude-md-template.md`       |

**Process:**

1. Read the template file from the skill directory
2. Write the template content to the missing file location
3. Inform user that placeholders (e.g., `{PROJECT_TITLE}`) need to be filled in

---

## Step 2: Check Cross-File Consistency (Category 2)

Compare content across files for consistency.

### 2.1 plan.md ↔ task.md Comparison

Read both files and check:

1. **Section Count Match**
   - Count sections in plan.md (pattern: `### X.Y` or numbered items with page counts)
   - Count checkbox items in task.md (pattern: `- [ ]` or `- [x]`)
   - Flag if counts differ

2. **Section ID Match**
   - Extract section IDs from plan.md
   - Extract section references from task.md
   - Find sections in plan.md but not in task.md
   - Find sections in task.md but not in plan.md

3. **Page Allocation Match**
   - Extract page counts from plan.md (pattern: `(Xp)` or `X pages`)
   - Compare with any page references in task.md

### For each inconsistency found

If `$ARGUMENTS` contains "--check":

- Report and continue

If `$ARGUMENTS` contains "--auto":

- Sync from plan.md to task.md (plan.md is source of truth)

Otherwise, use AskUserQuestion:

```
questions: [
  {
    question: "Section {X.Y} exists in plan.md but missing in task.md. How to fix?",
    header: "Sync",
    multiSelect: false,
    options: [
      {
        label: "Add to task.md (Recommended)",
        description: "Sync from plan.md (source of truth)"
      },
      {
        label: "Remove from plan.md",
        description: "Sync from task.md instead"
      },
      {
        label: "Skip",
        description: "Leave inconsistency"
      }
    ]
  }
]
```

**Fix Actions:**

- "Add to task.md": Use Edit tool to add missing section to task.md
- "Remove from plan.md": Use Edit tool to remove section from plan.md

### 2.2 plan.md ↔ CLAUDE.md Comparison (if CLAUDE.md exists)

Check:

- Session count consistency
- Structure description accuracy

For inconsistencies, offer to update CLAUDE.md (it should reflect plan.md).

### 2.3 task.md ↔ CLAUDE.md Comparison (if CLAUDE.md exists)

Check:

- Session boundary comments match
- Section references are accurate

---

## Step 3: Check Completion Status (Category 3)

Compare task.md checkboxes with actual files in docs/.

### 3.1 Task Marked Complete but File Missing

For each `[x]` in task.md:

- Extract expected filename (pattern: `{chapter}-{section}-{slug}.md`)
- Check if `docs/{filename}` exists
- Flag if file missing

If `$ARGUMENTS` contains "--check":

- Report and continue

If `$ARGUMENTS` contains "--auto":

- Uncheck the task in task.md

Otherwise, use AskUserQuestion:

```
questions: [
  {
    question: "Task {X.Y} marked [x] but docs/{filename}.md not found. How to fix?",
    header: "Missing",
    multiSelect: false,
    options: [
      {
        label: "Uncheck task (Recommended)",
        description: "Mark as incomplete in task.md"
      },
      {
        label: "Create empty document",
        description: "Create placeholder file"
      },
      {
        label: "Skip",
        description: "Leave inconsistency"
      }
    ]
  }
]
```

**Fix Actions:**

- "Uncheck task": Use Edit tool to change `[x]` to `[ ]`
- "Create empty document": Use Write tool to create minimal document

### 3.2 File Exists but Task Not Checked

For each `.md` file in docs/:

- Extract section ID from filename
- Check if matching task shows `[x]`
- Flag if task shows `[ ]`

If `$ARGUMENTS` contains "--check":

- Report and continue

If `$ARGUMENTS` contains "--auto":

- Check the task in task.md

Otherwise, use AskUserQuestion:

```
questions: [
  {
    question: "docs/{filename}.md exists but task {X.Y} shows [ ]. How to fix?",
    header: "Unchecked",
    multiSelect: false,
    options: [
      {
        label: "Mark as complete (Recommended)",
        description: "Check [x] in task.md"
      },
      {
        label: "Delete the file",
        description: "Remove docs/{filename}.md"
      },
      {
        label: "Skip",
        description: "Leave inconsistency"
      }
    ]
  }
]
```

**Fix Actions:**

- "Mark as complete": Use Edit tool to change `[ ]` to `[x]`
- "Delete the file": Use Bash to remove the file (with confirmation)

---

## Step 4: Output Summary

After all checks complete, output a summary **in the detected language**.

### English Example

```
=== Project Health Check ===

[1/3] Required Files
      ✓ plan.md
      ✓ task.md
      ✓ persona.md
      ! CLAUDE.md (recommended)
      Fixed: 0 | Skipped: 1

[2/3] Cross-File Consistency
      Comparing plan.md ↔ task.md...
      ✓ Section count matches (15)
      ✓ All sections synced
      Fixed: 0 | Skipped: 0

[3/3] Completion Status
      Progress: 5/15 sections (33%)
      ✓ All completed tasks have files
      ✓ All files have matching tasks
      Fixed: 0 | Skipped: 0

=== Summary ===
Checked: 3 categories
Issues found: 1
Fixed: 0
Skipped: 1 (CLAUDE.md recommended)

Project health: GOOD
```

### Korean Example (한국어)

```
=== 프로젝트 상태 점검 ===

[1/3] 필수 파일
      ✓ plan.md
      ✓ task.md
      ✓ persona.md
      ! CLAUDE.md (권장)
      수정: 0 | 건너뜀: 1

[2/3] 파일 간 일관성
      plan.md ↔ task.md 비교 중...
      ✓ 섹션 수 일치 (15개)
      ✓ 모든 섹션 동기화됨
      수정: 0 | 건너뜀: 0

[3/3] 완료 상태
      진행률: 5/15 섹션 (33%)
      ✓ 완료된 작업에 파일 존재
      ✓ 모든 파일에 작업 항목 존재
      수정: 0 | 건너뜀: 0

=== 요약 ===
점검: 3개 카테고리
발견된 문제: 1개
수정됨: 0개
건너뜀: 1개 (CLAUDE.md 권장)

프로젝트 상태: 양호
```

### Status Indicators

| Status | English                   | 한국어                |
| ------ | ------------------------- | --------------------- |
| ✓      | Check passed              | 확인됨                |
| ✗      | Error found (must fix)    | 오류 발견 (수정 필요) |
| !      | Warning (recommended fix) | 경고 (수정 권장)      |
| →      | Fixed during this run     | 이번 실행에서 수정됨  |

### Health Rating

| English         | 한국어    | Criteria                     |
| --------------- | --------- | ---------------------------- |
| GOOD            | 양호      | No errors, may have warnings |
| NEEDS_ATTENTION | 주의 필요 | Has errors that were skipped |
| CRITICAL        | 심각      | Required files missing       |

---

## Notes

- plan.md is the source of truth for structure
- task.md is the source of truth for completion status
- When in doubt, preserve data (don't delete without confirmation)
- Group related issues when presenting to user
- Be concise but informative in output
