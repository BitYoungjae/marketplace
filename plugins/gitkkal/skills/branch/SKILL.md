---
name: branch
description: "Analyzes changes and creates an appropriate branch."
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[description]"
---

# gitkkal branch Skill

Analyzes changes and generates an appropriate branch name, then creates the branch.

## Execution Steps

### Step 1: Load Configuration

Read `{project_root}/.gitkkal/config.json` to load settings.

The project root is the top-level directory of the Git repository (use `git rev-parse --show-toplevel` to find it).

- **If exists**: Load settings from the file.
- **If not exists**: Use default settings.

<default_config>

```json
{
  "language": "en",
  "commitPattern": "conventional",
  "branchPattern": "type/description",
  "splitCommits": true,
  "askOnAmbiguity": true,
  "createPrTemplate": false
}
```

</default_config>

When no config file exists, display once: "Using default settings. Run `/gitkkal:init` to customize."

### Step 2: Check Current State

Run the following commands to understand the current state:

```bash
git status --short
git diff --stat
git diff --cached --stat
```

- If no changes: Ask user to provide a branch description directly.
- If changes exist: Analyze the changes.

### Step 3: Determine Change Type

Analyze changed files and content to determine the branch type:

<branch_type_rules>

| Type | Criteria |
|------|----------|
| `feat` | New feature (new files, new functions/classes) |
| `fix` | Bug fix (fixing existing logic, adding error handling) |
| `refactor` | Code refactoring (structural improvements without functional changes) |
| `docs` | Documentation changes (*.md, README, CHANGELOG, etc.) |
| `test` | Test code (*.test.*, *.spec.*, __tests__/) |
| `style` | Formatting, semicolons, code style changes |
| `chore` | Build/config file changes (package.json, tsconfig, etc.) |
| `perf` | Performance improvements |
| `ci` | CI/CD config changes (.github/workflows/, etc.) |

</branch_type_rules>

**When classification is difficult**:
- If multiple types apply, decide based on the most significant change
- If uncertain, default to `feat`

### Step 4: Generate Branch Name

#### Slug Generation Rules

<slug_rules>

1. Use English kebab-case
2. Maximum 50 characters
3. Remove special characters (only alphanumeric and hyphens allowed)
4. Convert spaces to hyphens
5. Collapse consecutive hyphens to single hyphen
6. Remove leading/trailing hyphens
7. Convert to lowercase

</slug_rules>

<slug_examples>

| Input | Output |
|-------|--------|
| `Add user authentication` | `add-user-authentication` |
| `Fix button click bug` | `fix-button-click-bug` |
| `Update README file` | `update-readme-file` |
| Non-English input | Use AskUserQuestion to request English description |

</slug_examples>

#### Branch Name by Pattern

| branchPattern | Format | Example |
|---------------|--------|---------|
| `type/description` | `{type}/{slug}` | `feat/add-user-login` |
| `description-only` | `{slug}` | `add-user-login` |

### Step 5: User Confirmation

Show the generated branch name to the user and ask for confirmation.

Use AskUserQuestion tool with the following:

<confirmation_question>

header: "Branch"
question: "Create this branch?"
options:
  - label: "{generated_branch_name}"
    description: "Create with this branch name"
  - label: "Custom"
    description: "Specify a different branch name"

</confirmation_question>

### Step 6: Create Branch

Create and checkout the confirmed branch:

```bash
git checkout -b {branch_name}
```

### Step 7: Completion Message

Display the branch creation result:

<completion_message>

- Created branch: `{branch_name}`
- Next step: Run `/gitkkal:commit` to commit changes

</completion_message>

## Argument Handling

If user provides arguments (e.g., `/gitkkal:branch add user authentication`):

1. Use the argument as branch description
2. Skip change analysis and determine type based on argument
3. Continue with remaining steps

## Error Handling

<error_cases>

| Situation | Action |
|-----------|--------|
| Not a Git repository | Display "This is not a Git repository" |
| Branch name already exists | Ask for different name or suggest numeric suffix |
| Uncommitted changes on current branch | Warn and confirm before proceeding |

</error_cases>

## Notes

- Check current branch status before creating new branch
- If non-English description is provided, request English description
- If branch name is too long, automatically truncate
