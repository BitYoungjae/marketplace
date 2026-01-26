---
description: "Interactive gitkkal setup. Configure Git commit style, PR templates, and more."
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion, Task, Bash
---

# gitkkal init

Interactively generates configuration files for Git workflow automation.

## Critical Rules

- ALWAYS confirm before overwriting existing config
- ALWAYS confirm before overwriting existing PR template
- Mark recommended options with "(Recommended)" suffix

## Configuration

**Location**: `{project_root}/.gitkkal/config.json`

```bash
git rev-parse --show-toplevel  # Find project root
```

<schema>
```json
{
  "language": "ko" | "en",
  "commitPattern": "conventional" | "gitmoji" | "simple",
  "branchPattern": "type/description" | "description-only",
  "splitCommits": boolean,
  "askOnAmbiguity": boolean,
  "createPrTemplate": boolean
}
```
</schema>

## Workflow

### 1. Check Existing Configuration

If `{project_root}/.gitkkal/config.json` exists:
- Show current settings
- Ask whether to overwrite via AskUserQuestion

### 2. Collect Options (Batch 1 — max 4 questions)

Use AskUserQuestion with up to 4 questions:

**language** — Commit message language
- `en`: English (Recommended)
- `ko`: Korean

**commitPattern** — Commit message style
- `conventional`: `type(scope): description` (Recommended)
- `gitmoji`: `✨ description`
- `simple`: Plain message

**branchPattern** — Branch naming style
- `type/description`: `feat/add-login` (Recommended)
- `description-only`: `add-login`

**splitCommits** — Split into semantic units
- `true`: Separate commits per logical unit (Recommended)
- `false`: Single commit for all changes

### 3. Collect Options (Batch 2)

**askOnAmbiguity** — Ask on unclear classification
- `true`: Confirm with user (Recommended)
- `false`: Auto-decide

**createPrTemplate** — Create PR template
- `true`: Create `.github/PULL_REQUEST_TEMPLATE.md`
- `false`: Skip (Recommended)

### 4. Save Configuration

Write to `{project_root}/.gitkkal/config.json`:

```json
{
  "language": "ko",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": false
}
```

### 5. Create PR Template (if enabled)

When `createPrTemplate: true`:

1. Analyze project structure briefly:
   - Language/framework (package.json, Cargo.toml, go.mod)
   - Test framework
   - CI/CD setup (.github/workflows/)

2. If `.github/PULL_REQUEST_TEMPLATE.md` exists → confirm before overwriting

3. Create template appropriate for the project:

```markdown
## Summary

<!-- Briefly describe your changes -->

## Changes

-

## Test Plan

- [ ] Verify existing tests pass
- [ ] Add new tests (if applicable)

## Checklist

- [ ] Code style compliance
- [ ] Documentation updated (if applicable)
```

### 6. Output

```
Created: .gitkkal/config.json

Available commands:
- /gitkkal:branch — Create branch from changes
- /gitkkal:commit — Commit with configured style
- /gitkkal:pr — Create or update PR

To reconfigure: /gitkkal:init
```
