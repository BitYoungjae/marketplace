---
name: init
description: "Interactive gitkkal setup. Configure Git commit style, PR templates, and more."
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion, Task
user-invocable: true
disable-model-invocation: true
---

# gitkkal Init Skill

Interactively generates configuration files for Git workflow automation.

## Configuration File

**Location**: `{project_root}/.gitkkal/config.json`

The project root is the top-level directory of the Git repository (use `git rev-parse --show-toplevel` to find it).

<config_schema>

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

</config_schema>

### branchPattern Options

| Pattern | Format | Example |
|---------|--------|---------|
| `type/description` | `type/slug` | `feat/add-login`, `fix/button-bug` |
| `description-only` | `slug` | `add-login`, `fix-button-bug` |

## Execution Steps

### Step 1: Check Existing Configuration

Check if `{project_root}/.gitkkal/config.json` exists.

- If exists: Show current settings and ask whether to overwrite.
- If not exists: Create new settings.

### Step 2: Collect Configuration Options

Use AskUserQuestion tool to collect the following items. Maximum 4 questions per batch.

<questions_batch_1>

1. **language**: Commit message language
   - `ko`: Korean
   - `en`: English

2. **commitPattern**: Commit message style
   - `conventional`: `<type>[(scope)]: <description>` format (e.g., `feat(api): add user endpoint`, `fix: resolve null pointer`)
   - `gitmoji`: Emoji-prefixed format `<emoji> [(scope)][:] <message>` (e.g., `✨ Add feature`, `🐛 (auth): Fix login bug`)
   - `simple`: Simple message (e.g., `Add feature`)

3. **branchPattern**: Branch naming style
   - `type/description`: Include type prefix (e.g., `feat/add-login`, `fix/button-bug`)
   - `description-only`: Description only (e.g., `add-login`, `fix-button-bug`)

4. **splitCommits**: Whether to split changes into semantic units
   - `true`: Split semantically cohesive changes into separate commits
   - `false`: All changes in one commit

</questions_batch_1>

<questions_batch_2>

5. **askOnAmbiguity**: Whether to ask when commit classification is ambiguous
   - `true`: Confirm with user when ambiguous
   - `false`: Let Claude decide automatically

6. **createPrTemplate**: Whether to create PR template
   - `true`: Create `.github/PULL_REQUEST_TEMPLATE.md`
   - `false`: Do not create

</questions_batch_2>

### Step 3: Save Configuration File

Save collected information to `{project_root}/.gitkkal/config.json`.

<example_config>

```json
{
  "language": "ko",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": true
}
```

</example_config>

### Step 4: Create PR Template (Optional)

If `createPrTemplate` is `true`:

1. Briefly analyze project structure:
   - Identify language/framework (package.json, Cargo.toml, go.mod, etc.)
   - Check test framework
   - Check CI/CD setup (.github/workflows/)

2. Create `.github/PULL_REQUEST_TEMPLATE.md` appropriate for the project.

<pr_template_example>

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

</pr_template_example>

### Step 5: Completion Message

After setup completion, inform the following:

- Created configuration file path
- Available commands: `/gitkkal:branch`, `/gitkkal:commit`, `/gitkkal:pr`
- How to change settings: Re-run `/gitkkal:init`

## Notes

- If `{project_root}/.gitkkal/config.json` exists, confirm before overwriting
- If `.github/PULL_REQUEST_TEMPLATE.md` already exists, confirm before overwriting
- Suggest reasonable defaults for all options (marked as Recommended)
